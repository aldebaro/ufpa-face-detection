%This script allows to evaluate statistics of a given face detector.
%Assuming haarCascade is loaded in memory, representing the detector
%this code confirms that the 20 x 20 pictures are represented 
%with rectangles numbered from 0 to 19.
Scale=1;
x=0;
y=0;
minW=Inf;
maxW=-Inf;
RectX=[];
RectY=[];
RectWidth=[];
RectHeight=[];
RectWeight=[];
for i=1:20
    stage=haarCascade.stages(i);
    strongClassifier=stage.trees; % Access the classifiers tree class of the element
    for i_weakClassifier=1:length(strongClassifier) %i_weakClassifier will receive each accessed tree/strong classifier index
        %the field "value" is an array with 21 elements that describes
        %a specific weak learner
        weakClassifier = strongClassifier(i_weakClassifier).value; %get weak classifier
        for i_Rectangle = 1:3
            %extract the given "Rectangle"
            Rectangle = weakClassifier(:,(1:5)+i_Rectangle*5);
            RectX = [RectX floor(Rectangle(:,1)*Scale+x)];
            RectY = [RectY floor(Rectangle(:,2)*Scale+y)];
            RectWidth = [RectWidth  floor(Rectangle(:,3)*Scale)];
            RectHeight = [RectHeight floor(Rectangle(:,4)*Scale)];
            RectWeight = [RectWeight Rectangle(:,5)];
        end        
    end
end
max(RectX)
max(RectY)
min(RectX)
min(RectY)
hist(RectWidth)