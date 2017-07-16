function PixelSum=ufd_sumRect(IntegralImage,x,y,Width,Height)
% This function returns the sum of pixels inside a rectangle, using the integral
% image structure to simplify calculations.
% Inputs: integral image representation and a rectangle defined by the upperleft
% point (x,y) and its width w and height h. The inputs x,y,Width,Height
% can also be arrays. In this case, PixelSum is an array with the
% output for each (x,y,w,h).
% (Based on code by D. Kroon)%
% PixelSum=GetSumRect(IntegralImage,x,y,Width,Height)
%

global debugme; %global variable that is 1 if debugging with a small image

%force Width and Height to have the same dimension as x
%because the current code sometimes calls this function with
%Width and Height being scalars and other times vectors.
if length(x) ~= length(Height)
    Height=Height*ones(size(x));
    Width=Width*ones(size(x));
end

%Size of IntegralImage in first dimension (number of rows)
IIWidth=size(IntegralImage,1); %larger than the image size by 1 column because a colunm of zeros was added

%Sum of pixels calculated very efficiently due to the pre-computed
%IntegralImage matrix. Besides, this approach to find an element
%on the 2-d array IntegralImage as if it was a 1-d vector, allows
%to simultaneously calculate PixelSum for arrays of x, y, Width and Height
%To understand the indices, look at the calculation of PixelSum2 below
PixelSum  =   IntegralImage((x+Width)*IIWidth + y + Height+1) +  ...
    IntegralImage(x*IIWidth+y+1) - ...
    IntegralImage((x+Width)*IIWidth+y+1) - ...
    IntegralImage(x*IIWidth+y+Height+1);

%% The code below will execute only if debugme == 1 and simply
%shows that PixelSum can be obtained in an alternative way, which
%is easier to follow
if debugme == 1
    N=length(x);
    PixelSum2=zeros(size(x));
    for i=1:N %calculate for each (x,y)
        %need to sum 1 because IntegralImage has an extra row of
        %zeros and colum of zeros, such that a pixel at image(m,n)
        %corresponds to IntegralImage(m+1,n+1)
        PixelSum2(i) =  IntegralImage(y(i)+Height(i)+1, x(i)+Width(i)+1) + ...
            IntegralImage(y(i)+1,x(i)+1) - ...
            IntegralImage(y(i)+1,x(i)+Width(i)+1) - ...
            IntegralImage(y(i)+Height(i)+1,x(i)+1);
    end
    for i=1:N %now compare PixelSum and PixelSum2
        if PixelSum(i) ~= PixelSum2(i)
            error('Unexpected: PixelSum ~= PixelSum2 !!!')
        end
    end
end %end of if debugme == 1