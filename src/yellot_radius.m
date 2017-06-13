function [ out ] = yellot_radius(image)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
%Get Fourier coefficients
image = double(image);
coeff = fftshift(fft2(image));
coeff_p = log10(abs(coeff));

%Get yellot radius
out = getYellotRadius(coeff_p, 0, 800);

end

