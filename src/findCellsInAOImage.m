function [detectedCells, classLoss, otherInfo] = findCellsInAOImage(image, parameters)
%
% FUNCTION
%   findCellsInAOImage finds the photoreceptor cells in the images by exploiting
%   their split-colour nature.
%
% USAGE
%   [detectedCells, classLoss] = findCellsInAOImage(image, parameters).
%
% INPUT
%   image -
%       the image to be processed.
%   parameters - 
%       size: the expected dimension of the cell in pixels.
% 
% OUTPUT
%   detectedCells -
%       a 2D array of the cells detected in the image.
%   classLoss -
%       the result of the k-fold cross validation.
%   otherInfo -
%       a generic container to pass various outputs.
%
% AUTHOR
%   Christos Bergeles
%
% DATE
%   2016.09.19
%   2017.04.07
%   2018.05.15
%

  if nargin < 2
    error('findCellsInAOImage: Two input arguments are required.');
  end
  
  imageOriginal = image;
 
  %% Preprocessing
   
  if parameters.steps.gaussianFilter
    % Gaussian filter
    filt = fspecial('gaussian', parameters.gaussian.hsize, parameters.gaussian.sigma);
    image = imfilter(image, filt);
  end
  imageGaussian = image;
  
  if parameters.steps.bilateralFilter
    % Bilateral filter
    image = bfilter2(image, parameters.bfilt.hSize, ones(2, 1)*parameters.bfilt.sigma);
  end
  
  % CLAHE
  fprintf('findCellsInAOImage: CLAHE.\n');
  if parameters.steps.CLAHE
    if numel(parameters.clahe.numTiles) == 1
      parameters.clahe.numTiles = ones(1, 2)*parameters.clahe.numTiles;
    end
    image = adapthisteq(image, 'NumTiles', parameters.clahe.numTiles, 'Distribution', parameters.clahe.distribution, 'ClipLimit', parameters.clahe.clipLimit);
  end
  imageCLAHE = image;
  
  fprintf('findCellsInAOImage: Local adaptive thresholding.\n');
  if parameters.steps.adaptiveThresholding
    rectDimHalf = parameters.rectDimHalf;
    
    imWeight = 0*image;
    imAccumulated = 0*image;
    
    for x = 1:round(rectDimHalf):size(imAccumulated, 2)
      for y = 1:round(rectDimHalf):size(imAccumulated, 1)
       
        minX = max(1, x - rectDimHalf);
        maxX = min(size(imAccumulated, 2), x + rectDimHalf);
        
        minY = max(1, y - rectDimHalf);
        maxY = min(size(imAccumulated, 1), y + rectDimHalf);
        
        % Get the image
        imCropped = image(minY:maxY, minX:maxX);
        
        % Auto find the threshold and apply
        h = graythresh(imCropped);
        imCropped = im2bw(imCropped, h);
        
        imAccumulated(minY:maxY, minX:maxX) = ...
          (imCropped + imAccumulated(minY:maxY, minX:maxX).*imWeight(minY:maxY, minX:maxX))./...
          (imWeight(minY:maxY, minX:maxX) + 1);
        
        imWeight(minY:maxY, minX:maxX) = ...
          imWeight(minY:maxY, minX:maxX) + 1;
        
      end
    end
    
    image = imAccumulated;
    
  end
  
  %% Blob segmentation

  fprintf('findCellsInAOImage: Blob segmentation and peak finding.\n');
  imBwLeft = im2bw(image, parameters.threshold);
  imBwRight = im2bw(1 - image, parameters.threshold);
  
  centroidsLeft = findNonOverlappingExtremalRegions(imBwLeft, ...
    parameters.erodingElement, parameters.minimumAreaInPixels);
  centroidsRight = findNonOverlappingExtremalRegions(imBwRight, ...
    parameters.erodingElement, parameters.minimumAreaInPixels);

  if parameters.debugFigs
    
    darkBrightLobes = figure(1);
    imshow(imageCLAHE); 
    hold on; 
    plot(centroidsLeft(:, 1), centroidsLeft(:, 2), '.r', 'MarkerSize', 15); 
    plot(centroidsRight(:, 1), centroidsRight(:, 2), '.w', 'MarkerSize', 15);
    hold off;
    title('Detected bright/dark lobes');
    
  end
  
  % Peak filtering based on connections
  fprintf('findCellsInAOImage: Peak filtering - ');
  
  maxCellDimension = parameters.cellSize*1.2;
  minCellDimension = parameters.cellSize*0.2;
  
  [peakIdx, dist] = knnsearch(centroidsRight, centroidsLeft, ...
    'dist', 'euclidean', 'k', 8);
  
  pairs = [];
  centres = [];
  outlierCentres = [];
  for idx = 1:size(centroidsLeft, 1)
    
    currentPeakIdx = peakIdx(idx, :); % peakIdx(idx, toKeep);
    
    currentPeakRight = centroidsRight(currentPeakIdx, :);
    currentPeakLeft = repmat(centroidsLeft(idx, :), numel(dist(idx, :)), 1);
    
    diffrs = currentPeakRight - currentPeakLeft;
    toKeep = within(minCellDimension, diffrs(:, 1), maxCellDimension) & abs(diffrs(:, 2)) <= parameters.maximumHeightDifference;
    
    % The peaks of the right cell half that much to the "idx" peak of the
    % left cell half
    outlierPeakRight = currentPeakRight(~toKeep, :);
    outlierPeakLeft = currentPeakLeft(~toKeep, :);
   
    currentPeakRight(~toKeep, :) = [];
    currentPeakLeft(~toKeep, :) = [];

    pairs = [pairs; currentPeakLeft currentPeakRight];
    
    centres = [centres; (currentPeakLeft + currentPeakRight)/2];
    outlierCentres = [outlierCentres; (outlierPeakLeft + outlierPeakRight)/2];
    
  end
  
  fprintf('Found %d pairs.\n', size(pairs, 1));
  
  if parameters.debugFigs
    
    connectedLobes = figure(2);
    imshow(imageCLAHE); 
    hold on; 
    for pairIdx = 1:size(pairs, 1)
      plot([pairs(pairIdx, 1) pairs(pairIdx, 3)], [pairs(pairIdx, 2), pairs(pairIdx, 4)], 'w');
    end
    for centreIdx = 1:size(centres, 1)
      plot(centres(centreIdx, 1), centres(centreIdx, 2), '+r');
    end
    hold off;
    title('Connected Bright/Dark Lobes');
    
  end
   
  %% Create SVM model
   
  % Establish cell centres and crop cells - get positive data
  fprintf('findCellsInAOImage: Establish cell centres via SVM.\n');
  
  image = imageCLAHE;
  cropsInAColumn = [];
  
  averageCellSize = ceil(1.6*mean(sqrt( sum( (pairs(:, 1:2) - pairs(:, 3:4) ).^2, 2) ) ) );
  
  for ptIdx = 1:size(centres, 1)
  
    [idxX, idxY, toProcess] = findImageIndices(centres(ptIdx, :), averageCellSize, image);
    
    if ~toProcess
      
      continue;
      
    end
    
    reg = image(idxY, idxX);
    cropsInAColumn = [cropsInAColumn; reg];
    
  end
    
  % Classifier training
  fprintf('findCellsInAOImage: Training SVD classifier.\n');
  inliersFeaturesVec = [];
  
  for stp = 1:size(reg, 2):size(cropsInAColumn, 1)
    
    currentCell = cropsInAColumn(stp:stp+size(reg, 2)-1, :);
    
    inliersFeaturesVec = [inliersFeaturesVec; findFeatureVector(currentCell)];
    
  end
  
  % Preliminary "model" to cast out false negatives
  [U, ~, ~] = svd(inliersFeaturesVec', 0);
  U = U(:, 1:min([10, size(U, 2)]));
  
  % Get overall behaviour for good ones
  svdScore = (inliersFeaturesVec' - U*(U'*inliersFeaturesVec'));
  svdScore = sqrt(sum( svdScore'.^2, 2));
  quants = quantile(svdScore, parameters.quantThresh); %0.9
  
  %% Find stable cell centres
  
  fprintf('findCellsInAOImage: Finding stable cell centres - ');
  
  templateScore = quants(1);
  
  score = [];
  
  svdSelectedCentres = centres;
  
  centresToExamine = centroidsLeft + repmat([round(averageCellSize/3) 0], size(centroidsLeft, 1), 1);
  centresToExamine = [centresToExamine; centroidsRight + repmat([-round(averageCellSize/3) 0], size(centroidsRight, 1), 1)];
  for ptIdx = 1:size(centresToExamine, 1)
    
    [idxX, idxY, toProcess] = findImageIndices(centresToExamine(ptIdx, :), ...
      averageCellSize, image);
    
    if ~toProcess  
      continue;    
    end
    
    reg = image(idxY, idxX);
    
    currentFeaturesVec = findFeatureVector(reg);
    if isempty(currentFeaturesVec)
      continue
    end
    score = [score norm(currentFeaturesVec' - U*(U'*currentFeaturesVec'))];
    
    % Stricter criteria if it was considered an outlier before
    if score(end) < templateScore % 1.2
      
      inliersFeaturesVec = [inliersFeaturesVec; currentFeaturesVec];  
     % inlierCrops = [inlierCrops reg];
     
      svdSelectedCentres = [svdSelectedCentres; centresToExamine(ptIdx, :)];

      if parameters.debugFigs
        
        figure(connectedLobes);
        hold on;
        plot(centresToExamine(ptIdx, 1), centresToExamine(ptIdx, 2), 'xr');
        hold off;
        
      end
    end  
    
  end
  
  fprintf('Found %d pairs.\n', size(inliersFeaturesVec, 1));
  
  %% Find unstable points
  
  if parameters.debugFigs
    
    outlierLobes = figure(3);
    imshow(imageCLAHE);
    title('Outlier centres');
    
  end
  
  outlierFeaturesVec = [];
    score = [];
  
  for ptIdx = 1:size(outlierCentres, 1)
    
    [idxX, idxY, toProcess] = findImageIndices(outlierCentres(ptIdx, :), ...
      averageCellSize, image);
    
    if ~toProcess  
      continue;    
    end
    
    reg = image(idxY, idxX);
    
    currentFeaturesVec = findFeatureVector(reg);
    if isempty(currentFeaturesVec)
      continue
    end
    score = [score norm(currentFeaturesVec' - U*(U'*currentFeaturesVec'))];
    
    % Stricter criteria if it was considered an outlier before
    if score(end) > templateScore % 1.2
      
      outlierFeaturesVec = [outlierFeaturesVec; currentFeaturesVec];   
      
      if parameters.debugFigs
        
        figure(outlierLobes);
        hold on;
        plot(outlierCentres(ptIdx, 1), outlierCentres(ptIdx, 2), '.y');
        hold off;
        
      end
      
    end      
    
  end
 
  % Balanced the sets a bit
  setSizeDiff = abs(size(inliersFeaturesVec, 1) - size(outlierFeaturesVec, 1));
  if setSizeDiff > min([size(inliersFeaturesVec, 1), size(outlierFeaturesVec, 1)])
    if size(inliersFeaturesVec, 1) > size(outlierFeaturesVec, 1)
      inliersFeaturesVec = inliersFeaturesVec(1:size(inliersFeaturesVec, 1) - setSizeDiff/2, :);
    else
      outlierFeaturesVec = outlierFeaturesVec(1:size(outlierFeaturesVec, 1) - round(setSizeDiff/2), :);
    end
  end
  
  %% Train classification SVM
  
  fprintf('findCellsInAOImage: Training support vector machine.\n');
  
  packedFeaturesVec = [inliersFeaturesVec; outlierFeaturesVec];

  classAssignment = [categorical(cellstr(repmat('cell', size(inliersFeaturesVec, 1), 1)));
    categorical(cellstr(repmat('noise', size(outlierFeaturesVec, 1), 1)))];

  SVMModel = fitcsvm(packedFeaturesVec, classAssignment, 'Standardize', true, 'KernelScale', 'auto', 'OutlierFraction', 0.05, 'KernelFunction', 'linear');
  CVSVMModel = crossval(SVMModel, 'Kfold', 10);

  classLoss = kfoldLoss(CVSVMModel);
  otherInfo.numberOfPositiveSVMSamples = size(inliersFeaturesVec, 1);
  otherInfo.numberOfNegativeSVMSamples = size(outlierFeaturesVec, 1);
  
  % Rescan images
  fprintf('findCellsInAOImage: Rescanning images - ');
  
  % Shift to the right by half average
  cL = centroidsLeft + repmat([round(averageCellSize/4) 0], size(centroidsLeft, 1), 1);
  % Shift to the left by half average
  cR = centroidsRight + repmat([-round(averageCellSize/4) 0], size(centroidsRight, 1), 1);
  
  allCentroidsApproximate = [cL; cR];
   
  reps = 0;
  idx = 1;
  score = [1 1];
  selectedCellCentroids = [];
  while isempty(selectedCellCentroids)
    for blobIdx = 1:size(allCentroidsApproximate, 1)

      x = round(allCentroidsApproximate(blobIdx, 1));
      y = round(allCentroidsApproximate(blobIdx, 2));

      [idxX, idxY, toProcess] = findImageIndices(allCentroidsApproximate(blobIdx, :), averageCellSize, image);

      if ~toProcess
        continue;
      end

      imCropped = image(idxY, idxX);

      newFeaturesVec = findFeatureVector(imCropped);

      if size(imCropped, 1) ~= size(imCropped, 2)
        continue;
      end

      if isempty(newFeaturesVec)
          continue;
      end

      [~, score(idx, :)] = predict(SVMModel, newFeaturesVec);

      if score(idx, 1) > parameters.tScore %0.0 %strcmp(cellstr(label(idx)), 'cell')

        selectedCellCentroids = [selectedCellCentroids; [x y 1] ];
        
        % Check if cell is too close to another cell, and, if yes, merge
        [cellIdx, dist] = knnsearch(selectedCellCentroids, ...
          selectedCellCentroids(end, :), ...
          'dist', 'euclidean', 'k', 3);
        
        toMerge = find(dist < averageCellSize/2.1);
        if ~isempty(cellIdx)
          
          selectedCellCentroids(cellIdx(toMerge(1)), :) = mean(selectedCellCentroids(cellIdx(toMerge), :), 1);
          cellIdx = cellIdx(toMerge(2:end));
          selectedCellCentroids(cellIdx, :) = [];
          
        end
         
        
      end

      idx = idx + 1;

    end
     
    reps = reps + 1;
    if reps > 50
      
      break;
      
    end
    
    % Not more than 20 per diseased case
    if ~parameters.healthy 
      if size(selectedCellCentroids, 1) > 1.5*size(inliersFeaturesVec, 1)
        selectedCellCentroids = [];
        parameters.tScore =  parameters.tScore + 0.05;
      elseif size(selectedCellCentroids, 1) < 0.5*size(inliersFeaturesVec, 1)
        selectedCellCentroids = [];
        parameters.tScore =  parameters.tScore - 0.05;
      end
    end
    
  end
  
  detectedCells = selectedCellCentroids;

  if parameters.debugFigs
    
    svmFig = figure;
    imshow(imageCLAHE);
    hold on;
    plot(detectedCells(:, 1), detectedCells(:, 2), '.r', 'MarkerSize', 15); 
    hold off;
    
  end
  
  fprintf('Found %d pairs.\n', size(detectedCells, 1));
  
end













