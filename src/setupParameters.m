%% Setup algorithm parameters

parameters.healthy = true;
parameters.getYellotRadius = parameters.healthy;
parameters.steps.bilateralFilter = true;
parameters.steps.gaussianFilter = true;
parameters.steps.CLAHE = true;
parameters.steps.adaptiveThresholding = true;
parameters.debugFigs = true;

if parameters.getYellotRadius
  
  % Yellot radius
  f = yellot_radius(im);
  parameters.cellSize = round(1.5 * 900 / (2*pi*f));
  
  % Sanity checks
  parameters.cellSize = clamp(parameters.cellSize, 10, 16);
  
else
  
  parameters.cellSize = 12;
  
end

parameters.bfilt.hSize = round(parameters.cellSize/4);
if parameters.healthy
  parameters.bfilt.sigma = parameters.cellSize/30; % 10 % /30;
else
  parameters.bfilt.sigma = parameters.cellSize/8; % 10 % /30;
end
parameters.gaussian.hsize = parameters.bfilt.hSize;
if parameters.healthy
  parameters.gaussian.sigma = parameters.bfilt.sigma;
else
  parameters.gaussian.sigma = 100*parameters.bfilt.sigma;
end

parameters.rectDimHalf = parameters.cellSize;
if parameters.healthy
  parameters.minimumAreaInPixels = parameters.cellSize/10;
else
  parameters.minimumAreaInPixels = parameters.cellSize;
end

if parameters.healthy
  parameters.clahe.clipLimit = 0.02;
else
  parameters.clahe.clipLimit = 0.001;
end
parameters.clahe.distribution = 'rayleigh';
parameters.clahe.numTiles = [4 4];

parameters.erodingElement = strel('disk', 1);

parameters.maximumHeightDifference = parameters.cellSize/1.5; 

parameters.tScore = 0.0;
parameters.threshold = 0.98;

parameters.quantThresh = 0.9; 
