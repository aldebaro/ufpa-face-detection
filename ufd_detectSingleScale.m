function [x,y] = ufd_detectSingleScale(x, y, Scale, IntegralImage, w, h, HaarCascades)
% This function detects objects using a fixed scale through a Haar cascade
% classifier. Returns coordinates [x,y] where objects were detected
% (Based on code by D. Kroon)

%Calculation the inverse area of the matrix
InverseArea = 1/(w*h);

%Calculated the average in relation sum of rectangles(utilizing integral image) matrix and matrix area
average = ufd_sumRect(IntegralImage.ii,x,y,w,h)*InverseArea;

%Calculation of variance in each sub-windows of the classifiers
Variance = ufd_sumRect(IntegralImage.ii2,x,y,w,h)*InverseArea - (average.^2);

%Using a Variance to calculate the standard deviation
Variance(Variance<1) = 1;
StandardDeviation = sqrt(Variance);

%Os the "haarcarscade" contains a row of classifier-trees that are executed step by step. If a coordinate doesn't pass the classifier threshold it is removed, otherwise it goes into the next classifier.

i_stage = 1; %Control variable for loop into classifier stages
%Loop through all classifier stages
while (i_stage<=length(HaarCascades.stages))
    stage = HaarCascades.stages(i_stage); % stage receives the classifier class regarding the index i_stage
    Trees=stage.trees; % Access the classifiers tree class of the element 
    StageSummation = zeros(size(x)); % Create a matrix of zeros with length equal to the x (size should perhaps be (x, y))

    % Loop through a classifier tree
    for i_tree=1:length(Trees) %i_tree will receive each accessed tree index
        Tree = Trees(i_tree).value; %Tree receive the value of the tree specified by the i_tree
        % Executing the classifier
        TreeSum=ufd_treeDetect(zeros(size(x)),Tree,Scale,x,y,IntegralImage.ii,StandardDeviation,InverseArea); %TreeSum stores the execution of the classifier
        StageSummation = StageSummation+TreeSum; % Sum of two matrices
    end

    check=StageSummation < stage.stage_threshold; %The variable check indicates if StageSum is smaller than the minimum value determined by the classifier
    
    x=x(~check); %Remove the coordinates which values are less than the minimum value determined by the classifier

    if(isempty(x)) %If no coordinated satisfies the minimum value determined by the classifier then the loop is broken because no trace of object was detected
    	i_stage = length(HaarCascades.stages)+1; %i_stage receive the value that closes the loop
    end 

    y=y(~check);%Remove the coordinates which values are less than the minimum value determined by the classifier

    StandardDeviation=StandardDeviation(~check); %Remove the standard deviations which coordinate values are smaller than the minimum value determined by the classifier
    i_stage = i_stage+1; %Increment i_stage
end