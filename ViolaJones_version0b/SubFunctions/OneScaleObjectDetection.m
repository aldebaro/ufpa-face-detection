function [x,y]=OneScaleObjectDetection( x, y, Scale, IntegralImages, w,h,HaarCasade)
% [x,y]=OneScaleObjectDetection( x, y, Scale, IntegralImages, w,h,HaarCasade)
%

% Calculate the mean 
InverseArea = 1 / (w*h);
mean =  GetSumRect(IntegralImages.ii,x,y,w,h)*InverseArea;
% Use the mean and squared integral image to calculate the grey-level
% Varianceiance, of every search window
Variance = GetSumRect(IntegralImages.ii2,x,y,w,h)*InverseArea - (mean.^2);
% Convert the Varianceiation to Standard Deviation
Variance(Variance<1)=1; StandardDeviation =sqrt(Variance);

% The haarcasade contains a row of classifier-trees. The classifiers
% are executed one at the time. If a coordinate doesn't pass the classifier
% threshold it is removed, otherwise it goes into the next classifier

% Loop through all classifier stages
for i_stage = 1:length(HaarCasade.stages),
    stage = HaarCasade.stages(i_stage);
    Trees=stage.trees;
    StageSum = zeros(size(x));
    
    % Loop through a classifier tree
    for i_tree=1:length(Trees)
        Tree = Trees(i_tree).value;
        % Executed the classifier
        TreeSum=TreeObjectDetection(zeros(size(x)),Tree,Scale,x,y,IntegralImages.ii,StandardDeviation,InverseArea);
        StageSum = StageSum + TreeSum;
    end
    % If the StageSum of a coordinate is lower than the treshold it
    % is removed, otherwise it goes into the next stage
    check=StageSum < stage.stage_threshold;
    
    % Remove coordinates which don't contain an object
    x=x(~check);  if(isempty(x)), break; end % All coordinates failed
                                             % on this Scale to detect an
                                             % object in the image
    y=y(~check);
    StandardDeviation=StandardDeviation(~check);
end


