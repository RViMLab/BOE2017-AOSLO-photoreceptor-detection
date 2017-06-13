function [peak_interval, peak_height] = getProminents(pks, locs, w, prominence, scale, size_interval, L)
%Finds peak with most prominence in range 0.04 pixel^{-1} to 0.16
%pixel^{-1}
%
%There are some hard bounds for the peak intervals as the found peak may
%continue past our domain of interest and so we cut it off short.
n = numel(locs);
prev_prom = 0;
peak_index = 1;
% for i = 2:n
%     freq = locs(i) * scale * 2* pi / L
%     if freq > 0.04 && freq < 0.16
%         if prominence(i) > prev_prom && prominence(i) > prominence(i+1)
%             peak_index = i;
%             break
%         else
%             prev_prom = prominence(i);
%         end
%     end
% end
[x, peak_index] = max(prominence(1:min(10, numel(prominence))));
peak_location = locs(peak_index);
peak_width = w(peak_index); 
peak_height = pks(peak_index);
peak_interval = max(floor(peak_location - peak_width), 1):min(floor(peak_location + peak_width + 1), size_interval);

end
