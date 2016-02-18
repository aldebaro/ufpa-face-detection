%main script for running UFPA's face detector
%based on Dr. Kroon's script

%starting the script, we'll need the path  for the source image
%user may need to adapt path to curret OS 
imageFileName = ['Images', filesep(), '2.jpg'];

%And now add the path for the Haar features

%in Dr. Kroon's code the xml was removed, but since undestanding
%its conversion to .MAT is one of the points of the project, I'm going to include it
fileName = ['HaarCascades', filesep(), 'haarcascade_frontalface_alt.xml'];
%name treatment for the .xml file
j=find(fileName=='.'); 
if(~isempty(j))
    j=j(end);
    fileName=fileName(1:j-1); 
end
%Creates a string with the name of the .xml, but with .mat extension
fileNameHaarCascade = [fileName '.mat'];
%check if converted file already exixts, if so, conversion won't be done
if (~exist([fileName] '.mat')) 
    ufd_convertXML(fileName)
end
%stores the image in a matrix called 'I'
I = imread(imageFileName);
%calls the function that will call other detection functions
%passes as parameter the image and the .mat features file
objects = ufd_multiScaleDetection(I, fileNameHaarCascade)
%now the part missing is to print in the image the results of the detection
%draws boxes around the detected objects
ufd_showBoundingBoxes(I,objects);
%IMPORTANT
%notice that as this is written, the ufd_showBoundingBoxes has yet nothing in it, 
%it might be necessary to change the parameters after the function if finished
