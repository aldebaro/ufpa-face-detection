function IntegralImages = GetIntergralImages(Picture,Options)
% Make integral image from a Picture
%
%
% Function is written by D.Kroon University of Twente (November 2010)

% Convert the Picture to double 
% (grey-level scaling doesn't influence the result, thus 
% double instead of im2double can also be used)
Picture=im2double(Picture);

% Resize the image to decrease the processing-time
if(Options.Resize)
    if (size(Picture,2) > size(Picture,1)),
        Ratio = size(Picture,2) / 384;
    else
        Ratio = size(Picture,1) / 384;
    end
    Picture = imresize(Picture, [size(Picture,1) size(Picture,2) ]/ Ratio);
else
    Ratio=1;
end

% Convert the picture to greyscale (this line is the same as rgb2gray, see help)
if(size(Picture,3)>1),
    Picture=0.2989*Picture(:,:,1) + 0.5870*Picture(:,:,2)+ 0.1140*Picture(:,:,3);
end

% Make the integral image for fast region sum look up
IntegralImages.ii=cumsum(cumsum(Picture,1),2);
IntegralImages.ii=padarray(IntegralImages.ii,[1 1], 0, 'pre');

% Make integral image to calculate fast a local standard deviation of the
% pixel data
IntegralImages.ii2=cumsum(cumsum(Picture.^2,1),2);
IntegralImages.ii2=padarray(IntegralImages.ii2,[1 1], 0, 'pre');

% Store other data
IntegralImages.width = size(Picture,2);
IntegralImages.height = size(Picture,1);
IntegralImages.Ratio=Ratio;
