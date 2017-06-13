function [line, mag] = getLine(im, theta, scale)
%Returns an array of points defining a line. And gives us back the
%magnitude as well: this will be usefull in calculating the 9 individual
%curves
[row, col] = size(im);
mag = min(floor(row/2), floor(col/2));
mag = 0:scale:mag;

%Increasing y moves us down a row so we need to flip theta
theta = -theta;
center = [floor(row/2); floor(col/2)];
line = [mag * cos(theta) + center(1); 
          mag * sin(theta) + center(2)];
end

