function PixelSum=ufd_sumRect(IntegralImage,x,y,Width,Height)
% This function returns the sum of pixels inside a rectangle, using the integral
% image structure to simplify calculations.
% Inputs: integral image representation and a rectangle defined by the upperleft
% point (x,y) and its width w and height h
% (Based on code by D. Kroon)%
% PixelSum=GetSumRect(IntegralImage,x,y,Width,Height)
%

%Size of IntegralImage in frist dimension
IIWidth=size(IntegralImage,1);

%Sum of pixels
PixelSum  =   IntegralImage((x+Width)*IIWidth + y + Height+1) +  ...
			  IntegralImage(x*IIWidth+y+1) - ...
			  IntegralImage((x+Width)*IIWidth+y+1) - ...
			  IntegralImage(x*IIWidth+y+Height+1);
