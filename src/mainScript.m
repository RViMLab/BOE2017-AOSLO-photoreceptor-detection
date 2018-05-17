%
% This script parses each AO image, creates a model of the appearing cell,
% and the proceeds in identifying all cells.
%
% Author:
%   Christos Bergeles
%   Benjamin Davidson
%
% Date:
%   2016.09.19
%   2017.04.04

clc
close all hidden
clear variables

addpath('tree');
iptsetpref('ImshowBorder','tight');

%% Get the directory of images and the data

if contains('linux', get_operating_system) || contains(get_operating_system, 'mac')
  dirChar = '/';
else
  dirChar = '\';
end

if ~exist('direc', 'var')
  direc = uigetdir(['..' dirChar '..' dirChar '..' dirChar 'data-sample' dirChar]);
end

if isempty(direc)
  error('Please select the *PARENT* data directory before continuing.');
end

% Mime of images to be read
mime = 'tif';
% Put as true if you have data in subdirectories of the selected directory
readDirectoriesRecursively = false;
loadOnlyImagePath = true;
images = get_images_from_dir([direc dirChar 'raw-images' dirChar], mime, loadOnlyImagePath, [1 Inf], readDirectoriesRecursively);

% Pre directories
[outputDir, imageDirRaw, imageDirAnnotated, markerDir, ~] = prepOutputDirectory(direc);

% Copy existing files over
for imIdx = 1:length(images) % Copy original file too
  
  copyfile(images(imIdx).image_path, imageDirRaw);
  
end

copyfile([direc dirChar 'markers'], markerDir)

detectedCells = cell(length(images), 1);
kfoldScore = zeros(length(images), 1);
otherInfo = cell(length(images), 1);
  
%% Run the algorithm

close all hidden

[h, wait_time] = start_waitbar('Scanning', 1, length(images));

imageIdxs = 1:length(images);
for imIdx = imageIdxs

  fprintf('\n\n========= Image %d =======\n', imIdx);
  
  im = get_image_from_struct(images, imIdx);
  
  im = im2double(im.image_data);
  if size(im, 3) > 3
    im = im(:, :, 1:3);
  end
  if size(im, 3) ~= 1
    im = rgb2gray(im);
  end

  setupParameters;

  try
    [detectedCells{imIdx}, kfoldScore(imIdx), otherInfo{imIdx}] = findCellsInAOImage(im, parameters);
  catch ME
    fprintf('\nError!!! %s.\n', ME.identifier);
    continue;
  end
 
  if parameters.debugFigs
    
    sz = size(im) + [0 1];
    figure(1);
    set(figure(1), 'Position', [700, 700, sz(2), sz(1)]);
    f1 = getframe(figure(1));
    pause(1);
    close(figure(1));
    
    figure(2);
    set(figure(2), 'Position', [700, 700, sz(2), sz(1)]);
    f2 = getframe(figure(2));
    pause(1);
    close(figure(2));
    
    figure(3);
    set(figure(3), 'Position', [700, 700, sz(2), sz(1)]);
    f3 = getframe(figure(3));
    pause(1);
    close(figure(3));
    
    figure(4);
    set(figure(4), 'Position', [700, 700, sz(2), sz(1)]);
    f4 = getframe(figure(4));
    pause(1);
    close(figure(4));
    
    figure(5);
    imshow(im, 'InitialMagnification', 'fit');
    hold on; 
    plot(detectedCells{imIdx}(:, 1), detectedCells{imIdx}(:, 2), '.r', 'MarkerSize', 20);
    hold off;
    set(gca,'LooseInset',get(gca,'TightInset'))
    set(figure(5), 'Position', [700, 700, sz(2), sz(1)]);
    f5 = getframe(figure(5));
    pause(1);
    
    imProcess = [imresize(f1.cdata, 2*size(f1.cdata(:, :, 1))); 
      imresize(f2.cdata, 2*size(f1.cdata(:, :, 1))); 
      imresize(f3.cdata, 2*size(f1.cdata(:, :, 1))); 
      imresize(f5.cdata, 2*size(f1.cdata(:, :, 1)))];
    
  end
  
  [pathstr, name, ext] = fileparts(images(imIdx).image_path); 
  
  if parameters.debugFigs
    imwrite(imProcess, [imageDirAnnotated name ext]);
  end

  % close(figure(5));
  
  wait_time = update_waitbar(h, wait_time, 'Scanning', imIdx, length(images));

end

close_waitbar(h);

%% Create xml from the results and copy images and results

fileList = createXMLMarkerList(detectedCells, images, 'cb-algo');
for fIdx = 1:length(fileList)
  
    parDir = get_parent_directory(fileList{fIdx});
    movefile(fileList{fIdx}, [markerDir 'cb-algo' dirChar fileList{fIdx}(length(parDir):end)]);

end





