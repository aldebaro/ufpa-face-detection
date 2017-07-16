function obj=ufd_multiScaleDetection(integralImages, haarCascade, options)
% This function performs object detection in multiple scales,
% calling ufd_detectSingleScale function on each scale.
% (Based on code by D. Kroon)
global debugme;

%calculate the possible scales
ScaleWidth = integralImages.width/haarCascade.size(1);
ScaleHeight = integralImages.height/haarCascade.size(2);
%make sure StartScale is the minimum value between ScaleHeight and ScaleWidth
if(ScaleHeight < ScaleWidth )
    StartScale =  ScaleHeight;
else
    StartScale = ScaleWidth;
end

obj=zeros(100,4); %obj is an array to store the squares corresponding to detected faces
n=0; %number of detected faces up to now

%Find the iterations number based on the number os scales that will be
%explored. The scales will form a geometric series, with the first
%being the largest scale value and the others are multiplied by
%options.ScaleUpdate, such that the series is:
%i = 1:   scale = StartScale
%i = 2:   scale = StartScale*options.ScaleUpdate
%i = 3:   scale = StartScale*(options.ScaleUpdate)^2
%...
%i = itt:   scale = StartScale*(options.ScaleUpdate)^(itt-1)
%
%The idea is to have the last scale equals to 1, that is, the minimum
%scale. Hence, from line i=itt above, the itt value is calculated as
%1 = StartScale*(options.ScaleUpdate)^itt
%where o (itt-1) is not used used now. This can be written as
%1/StartScale = (options.ScaleUpdate)^itt
%which using log in base options.ScaleUpdate and changing the log
%base to use neperian:
itt=ceil(log(1/StartScale)/log(options.ScaleUpdate));

if debugme==1 && StartScale==1 && itt==0 %if debugging with small image
    itt=1;
end
if itt < 1
    error('No scales were found. Choose other options!');
end

%loop goes from largest to smallest scale
for i=1:itt
    Scale =StartScale*options.ScaleUpdate^(i-1); %for i=1, first scale is StartScale*options
    
    %based on the given scale, find the width and length of the Haar feature
    w = floor(haarCascade.size(1)*Scale); %for example, haarCascade.size(1) = 20 pixels
    h = floor(haarCascade.size(2)*Scale); %and haarCascade.size(2) = 20 pixels
    
    %shift in pixels according to the scale, and not less than 2 pixels
    step = floor(max( Scale, 2 ));
    %create a grid with all possible analysis windows given the image size
    %and the chosen "step"    
    %original code had -1 below, but I (AK) think it is not needed
    %[x,y]=ndgrid(0:step:(integralImages.width-w-1),0:step:(integralImages.height-h-1));
    [x,y]=ndgrid(0:step:(integralImages.width-w),0:step:(integralImages.height-h));
    x=x(:); %make it a column vector
    y=y(:); %make it a column vector
    
    if(isempty(x))
        continue; %if empty, skip this scale
    end
    
    %input x,y are the starting positions of the analysis window
    %input x,y are the rectangles top-left corners of the detected faces
    %important: the function below will be called for each scale
    [x,y] = ufd_detectSingleScale( x, y, Scale, integralImages, w, h, haarCascade);
    
    for k=1:length(x) %go over all detected faces
        n=n+1; %update number of detected faces
        obj(n,:)=[x(k) y(k) w h]; %create the rectangle to show the detected face
    end
    
    if(options.Verbose)
        %if verbose, show temporary information
        disp(['In scale: ' num2str(Scale) ', number of detected faces: ' num2str(n)])
    end
    
end

obj=obj(1:n,:); %discard rows that are not used in obj
obj=obj*integralImages.Ratio;        %teoricamente redimensiona os quadrados de acordo com a imagem
