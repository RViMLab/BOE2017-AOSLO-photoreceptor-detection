function ccTree = recursivelyParseConnectedComponent(imBw, se, ccTree, parentId, ccProperties, minimumAreaInPixels)
%
% FUNCTION
%   recursivelyParseConnectedComponent repeatedly shrinks the resulting
%   binary image using erosion, and determines the connectivity of the
%   connected components that are created. It creates a tree linking
%   "children" connected components to parents. The stable leafs are
%   the non-fused elements of the original connected component.
%
% USAGE
%   ccTree = recursivelyParseConnectedComponent(imBw, se, ccTree, parentId, ccProperties, minimumAreaInPixels).
%
% INPUT
%   imBW: 
%     the binary image that is considered.
%
%   se: 
%     the structural element that performs the erosion.
%
%   ccTree: 
%     the tree that holds the connectivity of the connected component
%     together.
%
%   parentId:
%     the id of the parent in the "global" tree.
%
%   ccProperties:
%     properties of the connected component currently examined.
%
%   minimumAreaInPixels:
%     connected components with area less than this number should be
%     ignored.
%
% OUTPUT
%   ccTree:
%     the updated tree with all the "stable" components as leaves.
%
% AUTHOR
%   Christos Bergeles
%
% DATE
%   2015.11.30
%

  if nargin < 6
    
    error('recursivelyParseConnectedComponent: Six input arguments are required.');
    
  end

  if ccProperties.Area < minimumAreaInPixels
    
    return;
    
  end
  
  % Add current centroid as node.
  [ccTree, parentId] = ccTree.addnode(parentId, ccProperties.Centroid);
  
  % Erode image.
  imBw = false(size(imBw));
  imBw(ccProperties.PixelIdxList) = true;
  imBw = imerode(imBw, se);
  
  % Find connected components.
  ccProperties = regionprops(imBw, 'centroid', 'area', 'PixelIdxList');
  
  % Scan all and recurse;
  while ~isempty(ccProperties)
    
    if ccProperties(end).Area > minimumAreaInPixels
    
      ccTree = ...
        recursivelyParseConnectedComponent(imBw, se, ccTree, parentId, ccProperties(end), minimumAreaInPixels);

    end
    
    ccProperties(end) = [];
    
  end
  
end