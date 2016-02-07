%% Face detection using code from 
%http://www.mathworks.com/matlabcentral/fileexchange/29437-viola-jones-object-detection 
%Note that the function ConvertHaarcasadeXMLOpenCV.m will load a XML
%and create two files: one .m and another .mat, at the same directory
%of the XML file. For example, if haarcascade_frontalface_alt.xml has
%the classifier, inspecting haarcascade_frontalface_alt.m is a good
%way to learn about how this classifier is represented in Matlab. And
%a good reference about the features is:
%http://www.lienhart.de/Prof._Dr._Rainer_Lienhart/Source_Code_files/ICIP2002.pdf 
%(this provides more details about how the Haar features can be calculated)
%Note that the XML version adopted by this software seems different than the
%one used in the latest OpenCV version.

%% 1) Define file names
%fileName = 'C:/ak/Works/2016_opencv/sources/data/haarcascades/haarcascade_frontalface_alt.xml';
fileName = 'C:\ak\Works\2016_opencv\ViolaJones_version0b\HaarCascades\haarcascade_frontalface_alt.xml';
%imageFileName = 'C:/ak/Works/2016_opencv/build3/bin/Debug/photo.jpg';
imageFileName = 'C:\ak\Works\2016_opencv\ViolaJones_version0b\Images\1.jpg';
%imageFileName = 'C:\ak\Works\2016_opencv\ViolaJones_version0b\Images\2.jpg';

j=find(fileName=='.'); if(~isempty(j)), fileName=fileName(1:j-1); end
fileNameHaarCascade = [fileName '.mat'];
%fileNameHaarCascade = 'C:\ak\Works\2016_opencv\ViolaJones_version0b\HaarCascades\haarcascade_frontalface_alt.mat';

%% 2) Convert XML into MAT using the code at
%http://www.mathworks.com/matlabcentral/fileexchange/29437-viola-jones-object-detection/
if 1 %disable if already converted, to save computing time
    ConvertHaarcasadeXMLOpenCV(fileName)
end

%% 3) Read image file
%originalImage = imread(imageFileName);
I = imread(imageFileName);
%I=imresize(originalImage,0.5); %resize to half size

%% 4) Perform detection
objects=ObjectDetection(I,fileNameHaarCascade);

%% 5) Show rectangles
ShowDetectionResult(I,objects);
