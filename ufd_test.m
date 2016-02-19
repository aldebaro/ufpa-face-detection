%main script for running UFPA's face detector
%based on Dr. Kroon's script

%starting the script, we'll need the path  for the source image
%user may need to adapt path to curret OS 
imageFileName = ['Images', filesep(), '2.jpg'];

%And now add the path for the Haar features
fileName = ['HaarCascades', filesep(), 'haarcascade_frontalface_alt.xml'];

%in Dr. Kroon's code the xml was removed, but since undestanding
%its conversion to .MAT is one of the points of the project, I'm going to include it
%name treatment for the .xml file
j=find(fileName=='.'); 
if(~isempty(j))
    j=j(end);
    fileName=fileName(1:j-1); 
end

%check if converted file already exixts, if so, conversion won't be done
if (~exist([fileName, '.mat'])) 
    ufd_convertXML(fileName)
end

%gets the name of the .mat created above from the opencb xml file
fileNameHaarCascade = [fileName '.mat'];

%read it
haarCascade = ufd_readHaar(fileNameHaarCascade);

%stores the image in a matrix called 'I'
img = imread(imageFileName);

% gets its integral image
intImg = ufd_integralImage(img);

%calls the function that will call other detection functions
%passes as parameter the image and the .mat features file
% and some options
defaultoptions=struct('ScaleUpdate',1/1.2,'Resize',false,'Verbose',true);
objects = ufd_multiScaleDetection(intImg, haarCascade, defaultoptions);

%now the part missing is to print in the image the results of the detection
%draws boxes around the detected objects
ufd_showBoundingBoxes(img,objects);

%IMPORTANT
%notice that as this is written, the ufd_showBoundingBoxes has yet nothing in it, 
%it might be necessary to change the parameters after the function if finished
