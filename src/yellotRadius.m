function [ out ] = yellotRadius(image)
%Get Fourier coefficients
image = double(image);
coeff = fftshift(fft2(image));
coeff_p = log10(abs(coeff));

%Get yellot radius
out = getYellotRadius(coeff_p, 0, 800);

end

