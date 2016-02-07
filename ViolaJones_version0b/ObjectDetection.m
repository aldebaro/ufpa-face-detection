function Objects = ObjectDetection(Picture,FilenameHaarcasade,Options)
% This function ObjectDetection is an implementation of the Detection in
% the Viola-Jones framework. In this framework  Haar-like features are used for 
% rapid object detection. It supports the trained classifiers in the
% XML files of OpenCV which can be download as part of the OPENCV software
% on opencv.willowgarage.com
%
% Objects=ObjectDetection(I,FilenameHaarcasade,Options)
%  
% inputs,
%   I : 2D image, or Filename of an image
%   FilenameHaarcasade : The filename of a Matlab file with a Haarcasade
%			which is created from an OpenCV xml file, using the
%			function ConvertHaarcasadeXMLOpenCV.
%   Options : A struct with options
%   Options.ScaleUpdate : The scale update, default 1/1.2
%   Options.Resize : If boolean is true (default), the function will 
%               resize the image to maximum size 384 for less cpu-time
%   Options.Verbose : Display process information
%
% outputs,
%   Objects : An array n x 4 with [x y width height] of the detected
%               objects
%
% Literature :
%   - Rainer Linehart and Jochend Maydt, "An Extended Set of Haar-like 
%	Features for Rapid Object Detection"
%   - Paul viola and Michael J. Jones, "Rapid Object Detection using
% 	a Boosted Cascade of Simple Features", 2001
%
% Example 1,
%   % Convert an OpenCV classifier XML file to a Matlab file
%   ConvertHaarcasadeXMLOpenCV('HaarCascades/haarcascade_frontalface_alt.xml');
%   % Detect Faces
%   Options.Resize=false;
%   ObjectDetection('Images/1.jpg','HaarCascades/haarcascade_frontalface_alt.mat',Options);
%
% Example 2,
%   % Convert an OpenCV classifier XML file to a Matlab file
%   ConvertHaarcasadeXMLOpenCV('HaarCascades/haarcascade_frontalface_alt.xml');
%   I = imread('Images/2.jpg');
%   FilenameHaarcasade = 'HaarCascades/haarcascade_frontalface_alt.mat';
%   Objects=ObjectDetection(I,FilenameHaarcasade);
%   ShowDetectionResult(I,Objects);
%
% Function is written by D.Kroon University of Twente (November 2010)

% The default Options
defaultoptions=struct('ScaleUpdate',1/1.2,'Resize',true,'Verbose',true);

% Add subfunction path to Matlab Search Path
functionname='ObjectDetection.m';
functiondir=which(functionname);
functiondir=functiondir(1:end-length(functionname));
addpath([functiondir '/SubFunctions'])

% Check inputs
if(ischar(Picture))
    if(~exist(Picture,'file'))
        error('face_detect:inputs','Image not Found');
    end
end
if(~exist(FilenameHaarcasade,'file'))
    error('face_detect:inputs','Haarcasade not Found');
end

% Process input options
if(~exist('Options','var')), Options=defaultoptions;
else
    tags = fieldnames(defaultoptions);
    for i=1:length(tags),
        if(~isfield(Options,tags{i})), Options.(tags{i})=defaultoptions.(tags{i}); end
    end
    if(length(tags)~=length(fieldnames(Options))),
        warning('image_registration:unknownoption','unknown options found');
    end
end

% Read the Picture from file if Picture is a filename
if(ischar(Picture))
    Picture = imread(Picture);
end

% Get the HaarCasade for the object detection
HaarCasade=GetHaarCasade(FilenameHaarcasade);

% Get the integral images
IntergralImages= GetIntergralImages(Picture,Options);

Objects = HaarCasadeObjectDetection(IntergralImages,HaarCasade,Options);

% Show the finale results
if(nargout==0)
    ShowDetectionResult(Picture,Objects);
end




