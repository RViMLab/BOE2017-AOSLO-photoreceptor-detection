function [yellots_radius] = getYellotRadius(abs_fourier_coeff, should_plot, L)
%Returns size of ring found in fourier domain

%First smooth image to remove noise
abs_fourier_coeff = filter2(1/49 * ones(7,7), abs_fourier_coeff);

%If we want to plot fourier coeff
if should_plot
    subplot(2,4,2);
    imshow(mat2gray(abs_fourier_coeff))
end

%Get 9 lines through center
%I assume we take 9 lines of length min(floor(row/2), floor(col/2))
%Though this isnt stated in the paper.

%line step: we need this later when working out peaks
scale = 0.1;
[graphs, mag] = getAvgOfCurves(abs_fourier_coeff, scale);

%Average the curves and fit exponential. Once we have fit subtract it from
%original data to better reveal peak
x = mag';
y = graphs';
f2 = fit(x, y,'exp2');
subtracted_data = y - f2(x);

%If we want to plot the subtracted data
if should_plot
    subplot(2,4,3);
    plot(f2, x, y)
    subplot(2,4,4);
    plot(x, subtracted_data)
end

%Get all relavent info of specific peak
%Here we use the information about scale
[pks, locs, w, p] = findpeaks(subtracted_data,'WidthReference','halfheight');
[peak_interval, peak_height] = getProminents(pks, locs, w, p, scale, length(subtracted_data), L);

%Extract upper fourth of peak
peak = subtracted_data(peak_interval);
lowest = min(peak);
upper_fourth = peak .* ((peak - lowest) > 0.75 * (peak_height - lowest));

%if we want to plot
if should_plot
    subplot(2,4,5);
    plot(x(peak_interval), upper_fourth)
end

%Get center of mass which is just yellots
M = trapz(upper_fourth);
M_y = trapz(upper_fourth .* x(peak_interval));
yellots_radius = M_y / M;
end
