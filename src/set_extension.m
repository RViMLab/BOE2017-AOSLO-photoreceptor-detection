function name = set_extension(filename, ext)
%
% FUNCTION
%   SET_EXTENSION changes the extension (in name only) of a filename.
%
% USAGE
%   NAME = SET_EXTENSION(FILENAME, EXT).
%
% INPUT
%   FILENAME: The string given as filename.
%   EXT: The new extension.
%
% OUTPUT
%   NAME: The new filename (if applicable).
%
% AUTHOR
%   Christos Bergeles
%
% DATE
%   24/02/2010
%

    if nargin < 2
        error('GET_EXTENSION: Two arguments are required.');
    end
    
    if ~strcmp(filename(end-3), '.')
        error('SET_EXTENSION: The given name is not a file with an extension.');
    else
        name = [filename(1:end-3) ext];
    end
    
end