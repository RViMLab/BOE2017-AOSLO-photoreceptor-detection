function [outputDirectory, imageDirectoryRaw, imageDirectoryAnnotated, markerDirectory, srcDirectory] = prepOutputDirectory(baseDir)
%
% FUNCTION
%   PREPOUTPUTDIRECTORY creates a directory based on the current date
%   and time, and create the necessary folders for the optimization history
%   loging, image loging, and configuration loging.
%
% USAGE
%   [outputDirectory, imageDirectory, markerDirectory, srcDirectory] = prepOutputDirectory(baseDir)
%
% INPUT
%   baseDir -
%     the basic directory where the data will be stored. Subdirectories are
%     created there.
%
% OUTPUT
%   outputDirectory
%   imageDirectoryRaw
%   imageDirectoryAnnotated
%   markerDirectory
%   srcDirectory
%
% AUTHOR
%   Christos Bergeles
%
% DATE
%   2012.07.12
%   2016.09.22
%

  if contains(get_operating_system, 'linux')
    sepChar = '/';
  else
    sepChar = '\';
  end
  id_str = datestr(now, 'yyyymmddTHHMMSS');
  outputDirectory = strcat(baseDir, sepChar, id_str, '-results');
  
  if ~exist(outputDirectory, 'dir')
    [~, ~] = mkdir(outputDirectory);
    warning('prepOutputDirectory: Creating the required directory.');
    fprintf('%s created.\n', outputDirectory);
  end

  imageDirectory = strcat(to_dir(outputDirectory), 'images', sepChar);
  imageDirectoryRaw = [imageDirectory, 'raw', sepChar];
  imageDirectoryAnnotated = [imageDirectory, 'annotated', sepChar];
  if ~exist(imageDirectory, 'dir')
    [~, ~] = mkdir(imageDirectory);
    [~, ~] = mkdir(imageDirectoryRaw);
    [~, ~] = mkdir(imageDirectoryAnnotated);
    warning('prepOutputDirectory: Creating the required images directory.');
    fprintf('%s created.\n', imageDirectory);
  end
  
  markerDirectory = strcat(to_dir(outputDirectory), 'markers', sepChar);
  if ~exist(markerDirectory, 'dir')
    [~, ~] = mkdir(markerDirectory);
    [~, ~] = mkdir([markerDirectory 'cb-algo']);
    warning('prepOutputDirectory: Creating the required markers directory.');
    fprintf('%s created.\n', markerDirectory);
  end
  
  srcDirectory = strcat(to_dir(outputDirectory), 'src', sepChar);
  if ~exist(srcDirectory, 'dir')
    [~, ~] = mkdir(srcDirectory);
    warning('prepOutputDirectory: Creating the required src directory.');
    fprintf('%s created.\n', srcDirectory);
  end
  
  fprintf('Copying main file.\n');
  copyfile('mainScript.m', strcat(srcDirectory, 'mainScript.m'));
  copyfile('setupParameters.m', strcat(srcDirectory, 'setupParameters.m'));
  
  fprintf('Copying cell-finding file.\n');
  copyfile('findCellsInAOImage.m', strcat(srcDirectory, 'findCellsInAOImage.m'));
  
  fprintf('Copying feature vector file.\n');
  copyfile('findFeatureVector.m', strcat(srcDirectory, 'findFeatureVector.m'));
  
end