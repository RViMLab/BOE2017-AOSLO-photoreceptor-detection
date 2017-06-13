function images = get_images_from_dir(directory, ...
                                       mime, ...
                                       path_only, ...
                                       number, ...
                                       recursive)
% FUNCTION
%   GET_IMAGES_FROM_DIR scans a directory for a certain image type, and
%   retrieves all the images. It returns a structure, and has the option to
%   store only the image paths for on-the-fly retrieval. If .xml files are
%   available, their paths are stored too.
%
% USAGE
%   IMAGES = GET_IMAGES_FROM_DIR(DIRECTORY, MIME, PATH_ONLY, NUMBER).
%
% INPUT
%   DIRECTORY: The path to be scanned for images.
%   MIME: The type of images to be retrieved.
%   PATH_ONLY: On-the-fly retrieval {'yes', 'no'}.
%   NUMBER: Start and end number to retrieve.
%   RECURSIVE: If true, then it parses directories recursively. Default
%   [false].
%
% OUTPUT
%   IMAGES: An array of structures containing the image paths (or data),
%   and the paths of xmls files etc.
%
% AUTHOR
%   Christos Bergeles
%
% DATE
%   24/02/2010
%   29/11/2012
%   16/12/2016
%

    if nargin < 5
      recursive = false;
    end
    if nargin < 4
      number = [1 Inf];
    end
    if nargin < 3
        path_only = true;
    end
    if nargin < 2
        error('GET_IMAGES_FROM_DIR: Two arguments are necessary.');
    end
    
    directory = to_dir(directory);
    
    k = 1;
    if recursive
      if contains(get_operating_system, 'linux')
        files = rdir([directory '*/*']);
      else
        files = rdir([directory '*\*']);
      end
    else
      files = dir(directory);
    end
    loaded_xml = false;
    loaded_mask = false;

    [h, wait_time] = start_waitbar('Scanning', 1, length(files));
    for i = 1:length(files)
        
        name = files(i).name;
        
        if strcmp(name, 'Thumbs.db')
            continue;
        end
        if strcmp(name, '.DS_Store')
            continue;
        end
        if strcmp(name(1), '.')
            continue;
        end
        if strcmp(name, '.')
            continue;
        end
        if strcmp(name, '..')
            continue;
        end
        ext = get_extension(name);
        if ~strcmp(ext, mime)
            continue;
        end
        
        if recursive
          image_path = name;
        else
          image_path = strcat(directory, name);
        end
        xml_path = set_extension(image_path, 'xml');
        mask_path = image_path;
        mask_path(end-3:end) = [];
        mask_path = strcat(mask_path, '_mask.', mime);
        
        images(k).image_path = image_path;
        
        if exist(xml_path, 'file')
            images(k).xml_path = xml_path;
            loaded_xml = true;
        end
        if exist(mask_path, 'file')
            images(k).mask_path = mask_path;
            loaded_mask = true;
        end
        
        if ~path_only
            images(k).image_data = imread(image_path);
            images(k).mask_data = imread(mask_path);
        end
    
        k = k + 1;
        
        wait_time = update_waitbar(h, wait_time, 'Scanning', i, length(files));
        
    end
    
    if ~exist('images', 'var')
      fprintf('No images loaded!\n');
    else
      
      if number(2) ~= Inf
        
        images = images(number(1):number(2));
        
      end
      
      fprintf('%d images loaded!\n', length(images));
    end
    
    close_waitbar(h);
    
    if loaded_xml
        fprintf('Loaded xml file for %s.\n', image_path);
    end
    if loaded_mask
        fprintf('Loaded mask for %s.\n', image_path);
    end

end