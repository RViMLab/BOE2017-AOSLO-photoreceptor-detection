function centroids = findNonOverlappingExtremalRegions(imBw, se, minimumAreaInPixels)
%
% INPUT
%   imBW: 
%     the binary image that is considered.
%
%   se: 
%     the structural element that performs the erosion.
%
%   minimumAreaInPixels:
%     connected components with area less than this number should be
%     ignored.
%
% OUTPUT
%   centroids:
%     the Nx2 array containing the 2D coordinates of N centroids.
%
% AUTHOR
%   Christos Bergeles
%
% DATE
%   2015.11.30
%

  if nargin < 3
    
    error('findNonOverlappingExtremalRegions: Three input arguments are required.');
    
  end
  
  regions  = regionprops(imBw, 'centroid', 'area', 'PixelIdxList');
  centroids = [];
  for rIdx = 1:size(regions, 1)
    
    ccTree = tree();
    parentId = 1;
    ccProperties = regions(rIdx);
    ccTree = recursivelyParseConnectedComponent(imBw, se, ccTree, parentId, ccProperties, minimumAreaInPixels);
    
    emptyTree = isemptynode(ccTree);
    if emptyTree.get(1) && ccTree.nnodes == 1
      
      continue;
      
    end
    
    ccLeaves = findleaves(ccTree);
      
    centroidsNew = zeros(length(ccLeaves), 2);
    for tIdx = 1:length(ccLeaves)
    
      centroidsNew(tIdx, :) = ccTree.get(ccLeaves(tIdx));
      
    end
 
  centroids = [centroids; centroidsNew];
    
 end