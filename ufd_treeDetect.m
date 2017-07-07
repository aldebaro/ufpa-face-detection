function weakLearnerOutput=ufd_treeDetect(Node,Tree,Scale,x,y,integralImage,stddev,inverseArea)
% This function performs object detection for one tree classifier.
% (Based on code by D. Kroon)
%AK: Note that the default "tree" classifier trained by OpenCV
%is organized in the XML file as the one below:
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
% which is then stored as a vector of 21 numbers in this code:
% Tree =
%   Columns 1 through 6
%    threshold left_val  right_val    ??        ??      rectangle
%     0.0040    0.0338    0.8378   -1.0000   -1.0000    3.0000
%   Columns 7 through 12
%     7.0000   14.0000    4.0000   -1.0000    3.0000    9.0000
%   Columns 13 through 18
%    14.0000    2.0000    2.0000         0         0         0
%   Columns 19 through 21
%      not used?
%          0         0         0

% Get the current haar weak-learn classifiers
Leaf= Tree(Node+1,:); %each Leaf row is the given "classifier", for
%example: Tree is a vector with 21 elements describing the classifier,
%and there are 45 candidate windows, then Leaf has size 45 x 21, with
%the weak-learner classifier repeated 45 times

% Calculate the haar-feature response for all candidate windows
Rectangle_sum = zeros(size(x)); %allocate space for all windows
for i_Rectangle = 1:3  %AK maybe 1:2 given that the third is zero ???
    %AK: I see only 2 rectangles in the classifier (from XML file)
    %and the third "rectangle" is all zeros, and leads to r_sum=0
    Rectangle = Leaf(:,(1:5)+i_Rectangle*5);
    RectX = floor(Rectangle(:,1)*Scale+x);
    RectY = floor(Rectangle(:,2)*Scale+y);
    RectWidth = floor(Rectangle(:,3)*Scale);
    RectHeight = floor(Rectangle(:,4)*Scale);
    RectWeight = Rectangle(:,5);
    %get the feature value using the integral image
    r_sum = ufd_sumRect(integralImage,RectX,RectY,RectWidth,RectHeight).*RectWeight;
    Rectangle_sum = Rectangle_sum + r_sum; %accumulate to obtain the value
end
Rectangle_sum = Rectangle_sum * inverseArea; %normalize by area in order
%to better compare rectangles with distinct sizes / areas

% Get the values of the current haar-classifiers
LeafTreshold=Leaf(:,1); %this is the threshold
%find the weak-learner output
%output in case the the response is smaller than the threshould 
%multiplied by the standard deviation stddev:
LeftValue = Leaf(:,2); 
%output otherwise (response larger or equal the threshould * stddev
RightValue =Leaf(:,3);

% Check the haar-response for the specific candidate window
% against the previously obtained (during training stage) haar-classifier treshold
% If the haar-response is larger, use the right node/value otherwise the
% left node/value
Node=zeros(size(x));
weakLearnerOutput =zeros(size(x));
%check will be 1 if the right value should be used or 0 otherwise
check=Rectangle_sum >= LeafTreshold(:).*stddev;
weakLearnerOutput(check)=RightValue(check);
weakLearnerOutput(~check)=LeftValue(~check);

%the logic regarding nodes below gives support to trees as weak learners, but the
%default detector uses single stumps, so their value is -1 for this
%detector. AK: I am then run the lines below only if a leaf is different
%from -1
if Leaf(1,4)~=-1 ||  Leaf(1,5)~=-1
    warning('AK: Be aware that a tree classifier more sophisticated than a decision stump is being used');
    
    LeftNode = Leaf(:,4);
    RightNode =Leaf(:,5);
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
        weakLearnerOutput(check)=ufd_treeDetect(Node(check),Tree,Scale,x(check),y(check),integralImage,stddev(check),inverseArea);
    end
end