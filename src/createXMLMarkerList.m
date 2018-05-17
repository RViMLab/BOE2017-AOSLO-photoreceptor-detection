
function fileList = createXMLMarkerList(centroids, images, markerStr, filenameXML)
%
% createXMLMarkerList receives a 2d array of centroids {Nx2}  containing
% coordinates (x, y) of cells, and creates an XML file representing an
% XMarkerList (for MeVisLab).
%
% USAGE
%   fileList = createXMLMarkerList(centroids, images, markerStr, filenameXML).
%
% INPUT
%   centroids
%       - a cell-array containing the centroids of the detected cells.
%
%   images
%       - a struct containing the images and the file paths to build the
%       xml files.
%
%   markerStr
%       - the identified of the marker.
%
% 	filenameXML
%       - a cell-array with the filenames of the output xmls. If not
%       provided, the filename of the images is assumed. 
%
% OUTPUT
%   fileList
%       - the generated filenames.
%
% AUTHOR
%   Christos Bergeles
%
% 2016/09/20
%
  
  if nargin < 3
    error('createXMLMarkerList: three input arguments are required.');
  end
  
  if ~iscell(centroids)
    
    centroids = {centroids};
    
  end
  
  if nargin == 4 && ~iscell(filenameXML)
    
    filenameXML = {filenameXML};
    
  else
    
    filenameXML = cell(1, length(images));
    for fIdx = 1:length(filenameXML)
      
      filenameXML{fIdx} = [images(fIdx).image_path(1:end-4) '_' markerStr '.xml'];
      
    end
    
  end
    
  lenIn = length(centroids);
  lenOut = length(filenameXML);    
  if lenIn ~= lenOut
    error('createXMLMarkerList: length of input and output should be the same.');
  end
  
  for fIdx = 1:lenIn
  
    if isempty(centroids{fIdx})
      numberOfPoints = 0;
    else
      numberOfPoints = length(centroids{fIdx}(:, 1));
    end
    
    fprintf('Handling %s: file %d of %d\n', filenameXML{fIdx}, fIdx, lenIn);
    
    fXML = fopen(filenameXML{fIdx}, 'w', 'native', 'UTF-8');
    
    fprintf(fXML, '<?xml version="1.0" encoding="UTF-8" standalone="no" ?>\n');
    fprintf(fXML, '<MeVis-XML-Data-v1.0>\n\n');
    
    fprintf(fXML, '  <XMarkerList BaseType="XMarkerList" Version="1">\n');
    fprintf(fXML, '    <_ListBase Version="0">\n');
    fprintf(fXML, '      <hasPersistance>1</hasPersistance>\n');
    fprintf(fXML, '      <currentIndex>-1</currentIndex>\n');
    fprintf(fXML, '    </_ListBase>\n');
    fprintf(fXML, '    <ListSize>%d</ListSize>\n', numberOfPoints);
    fprintf(fXML, '    <ListItems>\n');
    
    for pIdx = 1:numberOfPoints
      
      fprintf(fXML, '      <Item Version="0">\n');
      fprintf(fXML, '        <_BaseItem Version="0">\n');
      fprintf(fXML, '            <id>%d</id>\n', pIdx);
      fprintf(fXML, '        </_BaseItem>\n');
      fprintf(fXML, '        <pos>%.1f %.1f 0.5 0 0 0</pos>\n', centroids{fIdx}(pIdx, 1) + 0.5, centroids{fIdx}(pIdx, 2) + 0.5);
      fprintf(fXML, '      </Item>\n');
      
    end
    
    fprintf(fXML, '    </ListItems>\n');
    fprintf(fXML, '  </XMarkerList>\n\n');
    
    fprintf(fXML, '</MeVis-XML-Data-v1.0>\n');
    
    fclose(fXML);
    
  end
  fileList = filenameXML;
  
end