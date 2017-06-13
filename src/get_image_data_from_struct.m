function im = get_image_data_from_struct(images, ind, options)
%
% FUNCTION
%   GET_IMAGE_DATA_FROM_STRUCT returns the NxMxK image data of the image
%   at IND in the IMAGES structure. If the data are not present, they are
%   read from the disk.
%
% USAGE
%   IM = GET_IMAGE_DATA_FROM_STRUCT(IMAGE, IND, OPTIONS)
%
% INPUT
%   IMAGES: The array of structures containing the infromation about the
%   images.
%   IND: The index of the image of interest.
%   OPTIONS: A structure directing convertion to grayscale and/or double,
%   or perform histogram equalization.
%
% OUTPUT
%   IM: The data of the image of interest.
%
% AUTHOR
%   Christos Bergeles
%
% DATE
%   14/04/2010
%
% See also: get_image_from_struct.m
%

    if nargin < 3
        disp('GET_IMAGE_DATA_FROM_STRUCT: Setting options {to_double, false}, {to_grayscale, false}, {histeq, false}');
        options.to_double = false;
        options.to_grayscale = false;
        options.histeq = false;
    end
    
    if nargin < 2
        error('GET_IMAGE_DATA_FROM_STRUCT: Two input arguments are required.');
    end
    
    tmp = get_image_from_struct(images, ind);
    
    im = tmp.image_data;
    
    if options.to_double
        im = double(im);
    end
    
    if options.to_grayscale
        if size(im, 3) == 3
            im = rgb2gray(im);
        end
    end
    
    if options.histeq
        im = histeq(im);
    end
    
end