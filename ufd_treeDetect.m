function weakClassifierOutput=ufd_treeDetect(numberOfCurrentCandidateWindows, ...
    weakClassifer,Scale,x,y,integralImage,stddev,inverseArea)
% This function performs object detection for one weak learner.
% (Based on code by D. Kroon)
%AK: Note that the default "tree" classifier trained by OpenCV
%is organized in the XML file as the one below (assuming the old
%format for the XML):
%          <!-- tree 0 -->
%           <_>
%             <!-- root node -->
%             <feature>
%               <rects>
%                 <_>3 7 14 4 -1.</_>
%                 <_>3 9 14 2 2.</_></rects>
%               <tilted>0</tilted></feature>
%             <threshold>4.0141958743333817e-003</threshold>
%             <left_val>0.0337941907346249</left_val>
%             <right_val>0.8378106951713562</right_val></_></_>
%         <_>
%
% After parsing the XML, each weak leaner is represented (stored)
% in this code as a vector of 21 numbers:
% weak learner =
%    threshold left_val  right_val not_used not used    
%     0.0040    0.0338    0.8378   -1.0000   -1.0000    
%  rectangle (x,y,w,h,weight)
%    3.0000 7.0000   14.0000    4.0000   -1.0000
%    3.0000 9.0000   14.0000    2.0000    2.0000         
%  not used:
%  0         0         0        0         0         0

% Repeat the current Haar weak-learn classifier by the numberOfCurrentCandidateWindows
%each row is the given "weak classifier":
repeatedWeakClassifiers= weakClassifer(ones(numberOfCurrentCandidateWindows,1),:); 
%example: weakClassifer is a vector with 21 elements describing the classifier,
%and there are 45 candidate windows, then repeatedWeakClassifiers has size 45 x 21, with
%the weak-learner classifier repeated 45 times

% Calculate the haar-feature response for all candidate windows
weakClassifierResponse = zeros(numberOfCurrentCandidateWindows,1); %allocate space for all windows

%The features (for a weak classifier) can have at most 3 rectangles
for i_Rectangle = 1:3
    %extract the given "Rectangle"
    Rectangle = repeatedWeakClassifiers(:,(1:5)+i_Rectangle*5);
    RectX = floor(Rectangle(:,1)*Scale+x);
    RectY = floor(Rectangle(:,2)*Scale+y);
    RectWidth = floor(Rectangle(:,3)*Scale);
    RectHeight = floor(Rectangle(:,4)*Scale);
    RectWeight = Rectangle(:,5);
    %get the feature value using the integral image
    r_sum = ufd_sumRect(integralImage,RectX,RectY,RectWidth,RectHeight).*RectWeight;
    weakClassifierResponse = weakClassifierResponse + r_sum; %accumulate to obtain the value
end
weakClassifierResponse = weakClassifierResponse * inverseArea; %normalize by area in order
%to better compare rectangles with distinct sizes / areas

% Get the values of the current haar-classifiers
weakClassifierThreshold=repeatedWeakClassifiers(:,1); %this is the threshold
%find the weak-learner output
%output in case the the response is smaller than the threshould 
%multiplied by the standard deviation stddev:
LeftValue = repeatedWeakClassifiers(:,2); 
%output otherwise (response larger or equal the threshould * stddev
RightValue =repeatedWeakClassifiers(:,3);

% Check the response for the specific candidate windows
% against the previously obtained (during training stage) treshold
% If the response is larger than the threshold, use the right 
% value, otherwise use the left value
weakClassifierOutput =zeros(numberOfCurrentCandidateWindows,1); %initialize
%check will be 1 if the right value should be used or 0 otherwise
check=weakClassifierResponse >= weakClassifierThreshold(:).*stddev;
weakClassifierOutput(check)=RightValue(check);
weakClassifierOutput(~check)=LeftValue(~check);

%% Code below is not necessary for default XML face detector
%the logic regarding nodes below gives support to trees as weak learners, but the
%default detector uses single stumps, so their value is -1 for this
%detector. AK: I am then run the lines below only if a leaf is different
%from -1
if repeatedWeakClassifiers(1,4)~=-1 ||  repeatedWeakClassifiers(1,5)~=-1
    warning('AK: Be aware that a tree classifier more sophisticated than a decision stump is being used');
    Node=zeros(size(x));    
    LeftNode = repeatedWeakClassifiers(:,4);
    RightNode =repeatedWeakClassifiers(:,5);
    %titled=Leaf(:,21);
    
    Node(check) =RightNode(check);
    Node(~check)=LeftNode(~check);
    
    % If a Node has a larger value then -1, it is not the end node with
    % a value, but it is connected to another weak-classifier
    check=Node>-1;
    if(any(check))
        %recursively go over the weak classifiers. This allows a more
        %flexible weak classifier, but here we are using simple
        %decision stumps, and the code below will not execute for the
        %default detector
        weakClassifierOutput(check)=ufd_treeDetect(Node(check),weakClassifer,Scale,x(check),y(check),integralImage,stddev(check),inverseArea);
    end
end