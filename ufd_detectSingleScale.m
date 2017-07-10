function [x,y] = ufd_detectSingleScale(x, y, Scale, IntegralImage, w, h, HaarCascades)
% This function detects objects using a fixed scale through a Haar cascade
% classifier. Return the window coordinates [x,y] where objects (faces)
% were "detected"
% (Based on code by D. Kroon)

%Calculation the inverse area of the matrix
InverseArea = 1/(w*h);

%Calculated the average in relation sum of rectangles(utilizing integral image) matrix and matrix area
average = ufd_sumRect(IntegralImage.ii,x,y,w,h)*InverseArea;

%AK: I think this variance was added to deal with varying illumination
%conditions, and was not part of the original Viola & Jones algorithms
%It would be interesting to specify this reference here.

%Calculation of variance in each sub-window of the classifiers
%Note that for random variable X, we have E[X^2]=variance + mean^2,
%hence variance = E[X^2] - mean^2
Variance = ufd_sumRect(IntegralImage.ii2,x,y,w,h)*InverseArea - (average.^2);

%From variances, calculate standard deviations
Variance(Variance<1) = 1; %limit the minimum variance value to be 1
StandardDeviation = sqrt(Variance); %definition of standard deviation

%HaarCascades contains a cascade (sequence) of strong classifiers,
%trained with AdaBoost. Each stage classifier is composed of several
%weak classifiers. The number of stages can vary and the field "parent"
%indicates the predecessor of a stage. For example, considering 22 stages,
%parent=-1 for the first stage and 20 for the last stage, which has
%number 21 (they are numbered from 0 to 21).
%
%Besides, the number of weak classifiers in a given stage
%can also vary and a list is used as the data structure to deal with
%the variable number of weak classifiers. The code calls this data
%structure "strongClassifier" and the XML also calls it a tree.
%strongClassifier, in this
%code is an array of N elements, where N is the number of weak
%classifiers for the given stage and each element of this array has
%a field "value" consisting of a vector with M=21 elements, describing
%the corresponding weak classifier. These values can be accessed
%by strongClassifier(i).value for the i-weak classifer. For example, the first stage in
%the default XML has N=3 weak classifiers and the last stage (the 22th)
%has N=213.
%
%If a coordinate does not pass the
%classifier threshold, it is eliminated (rejected as a face candidate),
%otherwise this candidate is passed to the next stage classifier.

i_stage = 1; %Control variable for loop into classifier stages
%Loop through all strong classifier stages
%x and y inform all the candidate analysis windows for this scale
while (i_stage<=length(HaarCascades.stages))
    stage = HaarCascades.stages(i_stage); % stage receives the classifier class regarding the index i_stage
    strongClassifier=stage.trees; % Access the classifiers tree class of the element
    %recall that the evaluation is done simultaneously for all candidate
    %windows, such that strongClassifierOutput needs to store the stage output
    %for all candidate windows (some will be detected as "faces" and
    %others not). For example, if there are 45 candidate windows, the
    %size of strongClassifierOutput is 45 x 1.
    numberOfCurrentCandidateWindows=length(x);
    %strongClassifierOutput = zeros(size(x)); % Create a matrix of zeros with length equal to the x (size should perhaps be (x, y))
    strongClassifierOutput = zeros(numberOfCurrentCandidateWindows,1); % Create a matrix of zeros with length equal to the x (size should perhaps be (x, y))
    
    %Loop through all weak classifiers (for this stage, also called "tree")
    %note that all window candidates are being evaluated simultaneously
    for i_weakClassifier=1:length(strongClassifier) %i_weakClassifier will receive each accessed tree/strong classifier index
        %the field "value" is an array with 21 elements that describes
        %a specific weak learner
        weakClassifier = strongClassifier(i_weakClassifier).value; %get weak classifier
        % Executing this specific weak-learner classifier        
        weakClassifierOutput=ufd_treeDetect(numberOfCurrentCandidateWindows, ...
            weakClassifier,Scale,x,y,IntegralImage.ii,StandardDeviation, ...
            InverseArea);
        strongClassifierOutput = strongClassifierOutput+weakClassifierOutput; % Sum of two matrices
    end
    
    %check is a binary (logical) vector with its length corresponding
    %to the current number of candidate analysis windows
    shouldRemoveBecauseBelowThreshold=strongClassifierOutput < stage.stage_threshold;
    
    %update the list of candidate analysis windows, keeping only
    %the ones with strongClassifierOutput larger than the stage_threshold
    x=x(~shouldRemoveBecauseBelowThreshold); %Remove the coordinates which values are less than the minimum value determined by the classifier
    
    %If no coordinates (no candidate window) satisfy the minimum value determined by the
    %classifier then the loop is broken because no trace of object was detected
    if(isempty(x))
        break;     	%original code: i_stage = length(HaarCascades.stages)+1; %i_stage receive the value that closes the loop
    end

    %Note that x and y are modified (some of their elements can be
    %deleted) to keep only the current candidates (windows that may have a face)
    y=y(~shouldRemoveBecauseBelowThreshold);%Remove the coordinates which values are less than the minimum value determined by the classifier    
    StandardDeviation=StandardDeviation(~shouldRemoveBecauseBelowThreshold); %Remove the standard deviations which coordinate values are smaller than the minimum value determined by the classifier
    
    i_stage = i_stage+1; %Increment i_stage in while loop
end