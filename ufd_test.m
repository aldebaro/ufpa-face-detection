%main script for running UFPA's face detector
%based on Dr. Kroon's script
%Developed by UFPA students and instructor Aldebaro Klautau.
%It runs on both Octave and Matlab.
%It uses a classifier already trained (with OpenCV and saved as XML).
%Brazil, June 2017

%if running on Octave, execute (uncomment) the command below
%pkg load image %because you need the image package ("toolbox")

%starting the script, we'll need the path  for the source image
%user may need to adapt path to curret OS 
imageFileName = ['Images', filesep(), '1.jpg'];
%imageFileName = ['Images', filesep(), '2.jpg'];
%imageFileName = ['Images', filesep(), '3.jpg'];

%And now add the path for the Haar features
fileName = ['HaarCascades', filesep(), 'haarcascade_frontalface_alt.xml'];

%in Dr. Kroon's code the xml was removed, but since understanding
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

%gets the name of the .mat created above from the opencv xml file
fileNameHaarCascade = [fileName '.mat'];

%read it
haarCascade = ufd_readHaar(fileNameHaarCascade);

%stores the image in a matrix called 'img'
img = imread(imageFileName);

% and some options
defaultoptions=struct('ScaleUpdate',1/1.2,'Resize',true,'Verbose',true);

% gets its integral image
intImg = ufd_integralImage(img, defaultoptions);

%calls the function that will call other detection functions
%passes as parameter the integral image, classifier and options
objects = ufd_multiScaleDetection(intImg, haarCascade, defaultoptions);

%draws boxes around the detected objects
ufd_showBoundingBoxes(img,objects);
