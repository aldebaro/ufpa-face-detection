function ufd_showBoundingBoxes(X,boxes)
% function ufd_showBoundingBoxes(X,boxes)
%Show the boxes as red rectangles. Simpler than the result of
%the commands below in Matlab:
% faceDetector = vision.CascadeObjectDetector;
% I = imread('visionteam.jpg');
% bboxes = step(faceDetector, I);
% IFaces = insertObjectAnnotation(I, 'rectangle', bboxes, 'Face');
% figure, imshow(IFaces), title('Detected faces');

imshow(X)
%TO DO: show the boxes superimposed to the image