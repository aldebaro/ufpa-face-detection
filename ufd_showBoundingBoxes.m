function ufd_showBoundingBoxes(Picture,Objects)
% function ufd_showBoundingBoxes(X,boxes)
%Show the boxes as red rectangles. Simpler than the result of
%the commands below in Matlab:
% faceDetector = vision.CascadeObjectDetector;
% I = imread('visionteam.jpg');
% bboxes = step(faceDetector, I);
% IFaces = insertObjectAnnotation(I, 'rectangle', bboxes, 'Face');
% figure, imshow(IFaces), title('Detected faces');

figure,imshow(Picture), hold on;

% Show the detected objects
if(~isempty(Objects));
    for n=1:size(Objects,1)
        x1=Objects(n,1); y1=Objects(n,2);
        x2=x1+Objects(n,3); y2=y1+Objects(n,4);
        plot([x1 x1 x2 x2 x1],[y1 y2 y2 y1 y1]);
    end
end
%just as it is, the code prints the same blue rectangles as Kroon's
%make an update later to change the color to red and print a label within the faces