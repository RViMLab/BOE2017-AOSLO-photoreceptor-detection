function [ graphs, mag ] = getAvgOfCurves(abs_fourier_coeff, scale)
%Constructs nine graphs which plot the intensity of fourier coefficients in
%the frequency domain
%
%We make 9 radial lines from the center of the image and then linearly
%interpolate the values of intensities along these lines in the frequency
%domain. Once we have these curves we simply average them and get a single
%graph.
[rows, cols] = size(abs_fourier_coeff);
num_lines = 9;
lines = -pi/9:(2*pi/9)/num_lines:pi/9;
line_index = 1;
%We record the scale as this will be used when finding peaks
for l = lines
    %Get points of a line from center making an angle of l with the
    %horizontal
    [lin, mag] = getLine(abs_fourier_coeff, l, scale);
    for p = 1:length(mag)
        %Get linearly interpolated values again this is not stated in the
        %paper but without it there are many repeat values and my graph
        %does not look like that in the paper
        graphs(line_index, p) = interpn(abs_fourier_coeff, lin(2,p), lin(1,p));
    end 
    line_index = line_index + 1;
end
graphs = mean(graphs);
end

