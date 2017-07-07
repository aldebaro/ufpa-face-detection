function [x,y] = ufd_detectSingleScale(x, y, Scale, IntegralImage, w, h, HaarCascades)
% This function detects objects using a fixed scale through a Haar cascade
% classifier. Returns coordinates [x,y] where objects were detected
% (Based on code by D. Kroon)

%Calculation the inverse area of the matrix
InverseArea = 1/(w*h);

%Calculated the average in relation sum of rectangles(utilizing integral image) matrix and matrix area
average = ufd_sumRect(IntegralImage.ii,x,y,w,h)*InverseArea;

%AK: I think this variance was added to deal with varying illumination
%conditions, and was not part of the original Viola & Jones algorithms
%It would be interesting to specify this reference here.

%Calculation of variance in each sub-windows of the classifiers
%Note that for random variable X, we have E[X^2]=variance + mean^2,
%hence variance = E[X^2] - mean^2
Variance = ufd_sumRect(IntegralImage.ii2,x,y,w,h)*InverseArea - (average.^2);

%Using a Variance to calculate the standard deviation
Variance(Variance<1) = 1;
StandardDeviation = sqrt(Variance);

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
%structure "Trees" because the XML calls it a tree, but Trees is in
%fact an array of N elements, where N is the number of weak 
%classifiers for the given stage and each element of this array has
%a field "value" consisting of a vector with M=21 elements, describing
%the corresponding weak classifier. These values can be accessed
%by Trees(i).value for the i-weak classifer. For example, the first stage in
%the default XML has N=3 weak classifiers and the last stage (the 22th)
%has N=213.
%
%If a coordinate does not pass the
%classifier threshold, it is eliminated (rejected as a face candidate),
%otherwise this candidate is passed to the next stage classifier.

i_stage = 1; %Control variable for loop into classifier stages
%Loop through all classifier stages
while (i_stage<=length(HaarCascades.stages))
    stage = HaarCascades.stages(i_stage); % stage receives the classifier class regarding the index i_stage
    Trees=stage.trees; % Access the classifiers tree class of the element 
    StageSummation = zeros(size(x)); % Create a matrix of zeros with length equal to the x (size should perhaps be (x, y))

    %Loop through all weak classifiers (for this stage, also called "tree")
    %note that all window candidates are being evaluated simultaneously
    for i_tree=1:length(Trees) %i_tree will receive each accessed tree index
        Tree = Trees(i_tree).value; %Tree receive the value of the tree specified by the i_tree
        % Executing the classifier
        TreeSum=ufd_treeDetect(zeros(size(x)),Tree,Scale,x,y,IntegralImage.ii,StandardDeviation,InverseArea); %TreeSum stores the execution of the classifier
        StageSummation = StageSummation+TreeSum; % Sum of two matrices
    end

    %check is a binary (logical) vector with its length corresponding
    %to the number of candidate analysis windows
    check=StageSummation < stage.stage_threshold; %The variable check indicates if StageSum is smaller than the minimum value determined by the classifier
    
    x=x(~check); %Remove the coordinates which values are less than the minimum value determined by the classifier

    if(isempty(x)) %If no coordinated satisfies the minimum value determined by the classifier then the loop is broken because no trace of object was detected
    	i_stage = length(HaarCascades.stages)+1; %i_stage receive the value that closes the loop
    end 

    y=y(~check);%Remove the coordinates which values are less than the minimum value determined by the classifier

    StandardDeviation=StandardDeviation(~check); %Remove the standard deviations which coordinate values are smaller than the minimum value determined by the classifier
    i_stage = i_stage+1; %Increment i_stage
end