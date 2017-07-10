function PixelSum=ufd_sumRect(IntegralImage,x,y,Width,Height)
% This function returns the sum of pixels inside a rectangle, using the integral
% image structure to simplify calculations.
% Inputs: integral image representation and a rectangle defined by the upperleft
% point (x,y) and its width w and height h
% (Based on code by D. Kroon)%
% PixelSum=GetSumRect(IntegralImage,x,y,Width,Height)
%

global debugme;

%Size of IntegralImage in first dimension (number of rows)
IIWidth=size(IntegralImage,1);

if 0
    x=1:49;
    IntegralImage=reshape(x,7,7);
    IIWidth=size(IntegralImage,1);
    x=2;
    y=2;
    Width=2;
    Height=3;
    %x=104, y=52;
    a=(x+Width)*IIWidth + y + Height+1
    b=x*IIWidth+y+1
    c=(x+Width)*IIWidth+y+1
    d=x*IIWidth+y+Height+1
end

%Sum of pixels calculated very efficiently due to the pre-computed
%IntegralImage matrix
%AK
if 1
    PixelSum  =   IntegralImage((x+Width)*IIWidth + y + Height+1) +  ...
        IntegralImage(x*IIWidth+y+1) - ...
        IntegralImage((x+Width)*IIWidth+y+1) - ...
        IntegralImage(x*IIWidth+y+Height+1);
else
    PixelSum  =  IntegralImage(x+Height, y + Width) +  ...
        IntegralImage(x+1,y+1) - ...
        IntegralImage(x+Height,y) - ...
        IntegralImage(x,y+Width);
end
if 0
    if debugme==1
        if PixelSum ~= PixelSum2
            error('PixelSum ~= PixelSum2')
        end
    end
end