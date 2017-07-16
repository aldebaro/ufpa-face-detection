%Main script for running UFPA's face detector,
%based on Dr. Kroon's script
%Developed by UFPA students and instructor Aldebaro Klautau.
%It runs on both Octave and Matlab.
%It uses a classifier already trained (with OpenCV and saved as XML).
%Brazil, July 2017

%if running on Octave, execute (uncomment) the command below
%pkg load image %because you need the image package ("toolbox")

global debugme; %use 1 to debug with very small 20 x 20 "image"
%% 0) Define some variable
debugme=0; %debug with simple image or not
%Options:
options=struct('ScaleUpdate',1/1.2,'Resize',true,'Verbose',true);

%% 1) Locate files
%starting the script, we'll need the path  for the source image
%user may need to adapt path to its own file
imageFileName = ['Images', filesep(), '1.jpg'];
%imageFileName = ['Images', filesep(), '2.jpg'];
%imageFileName = ['Images', filesep(), '3.jpg'];
%stores the image in a matrix called 'img'
img = imread(imageFileName);

%if debugging the code with a small image
if debugme==1
    img=reshape(1:400,20,20); %simple "image"
    %change options, do not resize to avoid changing the image
    options=struct('ScaleUpdate',1/4,'Resize',false,'Verbose',true);
end

%And now add the path for the Haar features
fileName = ['HaarCascades', filesep(), 'haarcascade_frontalface_alt.xml'];

%% 2) Load the detector trained by OpenCV as a XML or MAT file
%the face detector can be specified as a XML or as a MAT file.
%Need to check if the MAT file already exists. First eliminate the
%XML extension and keep only the file name:
j=find(fileName=='.');
if(~isempty(j))
    j=j(end);
    fileName=fileName(1:j-1); %extract the file name
end
%check if converted MAT file already exixts, if so, conversion won't be done
if (~exist([fileName, '.mat']))
    ufd_convertXML(fileName) %convert XML file because MAT does not exist
end
%get the name of the .mat created above from the opencv xml file
fileNameHaarCascade = [fileName '.mat'];

%read the detector that is stored as a MAT file
haarCascade = ufd_readHaar(fileNameHaarCascade);

%% 3) Calculate the integral image
intImg = ufd_integralImage(img, options);

%% 4) Execute the face detector in all suggested scales
%call the function that will call other specific functions.
%The parameters are the integral image, classifier and options.
%The outputs are rectangles representing detected faces: [x, y, w, h]
%where x is the abscissa, from left to right, and y is the ordinate, 
%starting from top to bottom. w and l are the width and height.
%The rectangle is then:
%          (x,y)-------------(x+w,y)
%            |                  |
%            |                  |
%         (x,y+h)-----------(x+w,y+h)
objects = ufd_multiScaleDetection(intImg, haarCascade, options);

%% 5) Show the windows recognized as faces as rectangles
%draw boxes around the detected objects
ufd_showBoundingBoxes(img,objects);
