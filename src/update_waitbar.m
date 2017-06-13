function waitbar_tic = update_waitbar(waitbar_handle, waitbar_tic, title_text, current_loop, final_loop)
%
% FUNCTION
%   UPDATE_WAITBAR updates a waitbar and its text, and provides an estimate
%   of the remaining time.
%
% USAGE
%   WAITBAR_TIC = UPDATE_WAITBAR(WAITBAR_HANDLE, WAITBAR_TIC, TITLE_TEXT,
%   CURRENT_LOOP, FINAL_LOOP).
%
% INPUT
%   WAITBAR_HANDLE: The handle to the created waitbar. Must be created from
%   START_WAITBAR.
%   WAITBAR_TIC: The previous tic (needed for the remaining time).
%   TITLE_TEXT: The text of the waitbar.
%   CURRENT_LOOP: The current index for the waitbar update.
%   FINAL_LOOP: The final index for the waitbar update.
%
% AUTHOR
%   Christos Bergeles
%
% DATE
%   06/07/2010
%
% See also start_waitbar, close_waitbar
%

    if nargin < 5
        error('UPDATE_WAITBAR: Five input arguments are required.');
    end
    if nargout < 1
        error('UPDATE_WAITBAR: One output argument is required.');
    end

    % Time ellapsed since last update
    waitbar_toc = toc(waitbar_tic);
    % Estimate time remaining
    time_remaining = round(waitbar_toc*(final_loop - current_loop)/60); % [mins]

    current_percentage = round(current_loop/final_loop*100);
    s = sprintf('%s %d%%, remaining time: %3d mins', title_text, current_percentage, time_remaining);

    waitbar(current_percentage/100, waitbar_handle, s);

    waitbar_tic = tic;

end