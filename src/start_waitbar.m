function [waitbar_handle waitbar_tic] = start_waitbar(title_text, start_loop, final_loop)
%
% FUNCTION
%   START_WAITBAR starts a waitbar that can keep track of the remaining
%   time to finish a task.
%
% USAGE
%   [WAITBAR_HANDLE WAITBAR_TIC] = START_WAITBAR(TITLE_TEXT, START_VALUE,
%   TOTAL_LOOPS).
%
% INPUT
%   TITLE_TEXT: The text of the waitbar.
%   START_LOOP: The start index for the waitbar update.
%   FINAL_LOOP: The final index for the waitbar update.
%
% OUTPUT
%   WAITBAR_HANDLE: Handle to the instantiated waitbar.
%   WAITBAR_TIC: Time value to be used in update_waitbar and estimate the
%   remaining time.
%
% AUTHOR
%   Christos Bergeles
%
% DATE
%   06/07/2010
%
% See also update_waitbar, close_waitbar
%

    if nargin < 3
        error('START_WAITBAR: Three input arguments are required.');
    end
    if nargout < 2
        error('START_WAITBAR: Two output arguments are required.');
    end

    start_percentage = round(start_loop/final_loop*100);
    s = sprintf('%s %d%%', title_text, start_percentage);
    waitbar_handle = waitbar(start_loop/final_loop, s);
    
    waitbar_tic = tic;

end