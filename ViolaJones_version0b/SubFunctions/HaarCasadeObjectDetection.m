function Objects= HaarCasadeObjectDetection(IntegralImages,HaarCasade,Options)
% Objects= HaarCasadeObjectDetection(IntegralImages,HaarCasade,Options)

% Calculate the coarsest image scale
ScaleWidth = IntegralImages.width/HaarCasade.size(1);
ScaleHeight = IntegralImages.height/HaarCasade.size(2);
if(ScaleHeight < ScaleWidth ), 
    StartScale =  ScaleHeight; 
else
    StartScale = ScaleWidth;
end

% Array to store [x y width height] of Objects detected
Objects=zeros(100,4); n=0; 

% Calculate maximum of search scale itterations
itt=ceil(log(1/StartScale)/log(Options.ScaleUpdate));

% Do the Objection detection, looping through all image scales
for i=1:itt
    % Current scale
    Scale =StartScale*Options.ScaleUpdate^(i-1);    
    
    % Display the current scale and number of objects detected
    if(Options.Verbose)
        disp(['Scale : ' num2str(Scale) ' objects detected : ' num2str(n) ])
    end
    
    % Window size scales, with decreasing search-scale
    % (instead of cpu-intensive scaling of the image and calculation 
    % of new integral images)
    w = floor(HaarCasade.size(1)*Scale);
    h = floor(HaarCasade.size(2)*Scale);

    % Spacing between search coordinates of the image.
    step = floor(max( Scale, 2 ));

    % Make vectors with all search image coordinates used for the current scale
    [x,y]=ndgrid(0:step:(IntegralImages.width-w-1),0:step:(IntegralImages.height-h-1)); x=x(:); y=y(:);
    
    % If no coordinates due to large step size, continue to next scale
    if(isempty(x)), continue; end
    
    % Find objects in the image for the current scale
    [x,y] = OneScaleObjectDetection( x, y, Scale, IntegralImages, w, h, HaarCasade);
     
    % If search coordinates still exist, they contain an Object
    for k=1:length(x);
        n=n+1; Objects(n,:)=[x(k) y(k) w h];
    end
end

% Crop the initial array with Objects detected
Objects=Objects(1:n,:);

% Resize coordinates back, to compensate the resizing of the picture
% before making the IntegralImages
Objects=Objects*IntegralImages.Ratio;