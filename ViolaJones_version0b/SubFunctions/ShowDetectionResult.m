function ShowDetectionResult(Picture,Objects)
%  ShowDetectionResult(Picture,Objects)
%
%

% Show the picture
figure,imshow(Picture), hold on;

% Show the detected objects
if(~isempty(Objects));
    for n=1:size(Objects,1)
        x1=Objects(n,1); y1=Objects(n,2);
        x2=x1+Objects(n,3); y2=y1+Objects(n,4);
        plot([x1 x1 x2 x2 x1],[y1 y2 y2 y1 y1]);
    end
end
