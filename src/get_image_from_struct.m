function image = get_image_from_struct(images, i)
%
% FUNCTION
%   GET_IMAGE_FROM_STRUCT retrieves an image from a given array of
%   sturctures. If the image_data is not loaded, it loads it from the disk.
%
% USAGE
%   IMAGE = GET_IMAGE_FROM_STRUCT(IMAGES, I).
%
% INPUT
%   IMAGES: An array of structures containing the image information.
%   I: The index of the image of interest.
%
% OUTPUT
%   IMAGE: The extracted image, with the corresponding image_data
%
% AUTHOR
%   Christos Bergeles
%
% DATE
%   24/02/2010
%

    if nargin < 2
        error('GET_IMAGE_FROM_STRUCT: Two arguments are required.');
    end
    
    if i > length(images) 
        error('GET_IMAGE_FROM_STRUCT: Given index greater than array length.');
    end
    if i < 1
        error('GET_IMAGE_FROM_STRUCT: Given index less than 1.');
    end
    
    if isfield(images(i), 'image_data')
        image = images(i);
    else
        image = images(i);
        image.image_data = imread(images(i).image_path);
    end
    
end