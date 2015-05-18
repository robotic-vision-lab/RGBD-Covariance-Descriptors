function [r g b] = unpackRGBFloat(rgbfloatdata)
% UNPACKRGBFLOAT Unpack RGB float data into separate color values.

mask = hex2dec('000000FF');
rgb = typecast(rgbfloatdata,'uint32');

r = double(bitand(mask, bitshift(rgb, -16))) / 255;
g = double(bitand(mask, bitshift(rgb, -8))) / 255;
b = double(bitand(mask, rgb)) / 255;

end
