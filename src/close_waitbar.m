function close_waitbar(waitbar_handle)
%
% FUNCTION
%   CLOSE_WAITBAR closes a waitbar give a handle.
%
% USAGE
%   CLOSE_WAITBAR(WAITBAR_HANDLE).
%
% INPUT
%   WAITBAR_HANDLE: Handle to a waitbar.
%
% AUTHOR
%   Christos Bergeles
%
% DATE
%   06/07/2010
%

    if nargin < 1
        error('CLOSE_WAITBAR: One input arguments is required.');
    end
    
    close(waitbar_handle);

end