function ext = get_extension(filename)
%
% FUNCTION
%   GET_EXTENSION gets the extension of the given filename.
%
% USAGE
%   EXT = GET_EXTENSION(FILENAME).
%
% INPUT
%   FILENAME: The string given as filename.
%
% OUTPUT
%   EXT: The extension of the filename (if applicable).
%
% AUTHOR
%   Christos Bergeles
%
% DATE
%   24/02/2010
%

    if nargin < 1
        error('GET_EXTENSION: One argument is required.');
    end
    
    if length(filename) < 4
        warning(strcat('GET_EXTENSION: The given name', [' ' '''' filename], '''  is not a file.'));
        ext = [];
        return
    end
    
    if ~strcmp(filename(end-3), '.')
        warning(strcat('GET_EXTENSION: The given name ', [' ' '''' filename], ''' is not a file.'));
        ext = [];
    else
        ext = filename(end-2:end);
    end
    
end