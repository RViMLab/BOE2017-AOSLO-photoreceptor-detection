function fVec = findFeatureVector(img)
%
% findFeatureVector receives an image patch as input and returns the
% feature vector extracted from this image patch. If a black and white
% image is also given, then ray features are extracted. If a reference
% image is given, then the histogram of the grayscale image input is
% matched to that of the reference image.
%
% INPUT
%   img       - The grayscale input image patch.
%
% OUTPUT
%   fVec      - The 1xN feature vector.
%
% AUTHOR
%   Christos Bergeles
%
% DATE
%   2015.12.14
%   2016.09.22
%

  if nargin < 1
    error('findFeatureVector: At least one input argument is required.');
  end
    
  filt = fspecial('gaussian', 12, 5.0);
  img = imfilter(img, filt);
  
  imgRot = imrotate(img, 180);
  
  % imgRot = imgRot - imfilter(img, filt);
  imgRot = imgRot - img;
  imgRotPolar = imgpolarcoord(imgRot);
  imgRotPolar = imgRotPolar(:)';
  
  imgRot90 = imrotate(img, 90);
  imgRot90 = imgRot90 - img;
  imgRot90Polar = imgpolarcoord(imgRot90);
  imgRot90Polar = imgRot90Polar(:);
  
  % Polar coordinates
  imgPolar = imgpolarcoord(img);
  imgPolar = imgPolar(:)';
  
  % Image profiles from centre to edges and centres.
  [gx, gy] = gradient(img);
  g = sqrt(gx.^2 + gy.^2);
  
  gPolar = imgpolarcoord(g);
  gPolar = gPolar(:)';
  
  % Get a small and large circle in the middle of the image. The difference
  % in their histograms captures the spatial encoding.
  rSmall = round(max(size(img))/2); 
  
  cx = size(img, 2)/2;
  cy = size(img, 1)/2;
  [x, y] = meshgrid(1:size(img, 1), 1:size(img, 2));
  idx = sqrt( (x - cx).^2 + (y - cy).^2) < rSmall;
  maskIn = img;
  maskIn(idx) = 0;
  
  maskOut = img;
  maskOut(~idx) = 0;
  
  imgDiff = maskOut - maskIn;
  imgDiff = imgpolarcoord(imgDiff);
  imgDiff = imgDiff(:)';
  
  arg1 = gPolar(1:10:end);
  arg1 = (arg1 - mean(arg1))/std(arg1);
  
  arg2 = imgPolar(1:10:end);
  arg2 = (arg2 - mean(arg2))/std(arg2);
  
  arg3 = imgDiff(1:10:end);
  arg3 = (arg3 - mean(arg3))/std(arg3);
  
  arg4 = imgRotPolar(1:10:end);
  arg4 = (arg4 - mean(arg4))/std(arg4);
  
  arg5 = imgRot90Polar(1:10:end);
  arg5 = (arg5 - mean(arg5))/std(arg5);
  
  fVec = [arg1 arg2 arg3 arg4 arg5']; % to_vector(arg5)]'; % fVecGab(1:10:end)];
  
  % reject NaNs or Inf
  if ~isempty(find(fVec == Inf, 1)) || ~isempty(find(isnan(fVec), 1))
      fVec = [];
  end
  
end