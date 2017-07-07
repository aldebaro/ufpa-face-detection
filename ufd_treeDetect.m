function Tree_sum=ufd_treeDetect(Node,Tree,Scale,x,y,integralImage,stddev,inverseArea)
% This function performs object detection for one tree classifier.
% (Based on code by D. Kroon)
%AK: Note that a "tree" classifier as the one below:
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
% is organized as a vector of 21 numbers:
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

% Get the current haar-classifiers
Leaf= Tree(Node+1,:); %each Leaf row is the given "classifier"

% Calculate the haar-feature response
Rectangle_sum = zeros(size(x));
for i_Rectangle = 1:3  %maybe 1:2 ???
    %AK: I see only 2 rectangles in the classifier (from XML file)
    %and the third "rectangle" is all zeros, and leads to r_sum=0
    Rectangle = Leaf(:,(1:5)+i_Rectangle*5);
    RectX = floor(Rectangle(:,1)*Scale+x);
    RectY = floor(Rectangle(:,2)*Scale+y);
    RectWidth = floor(Rectangle(:,3)*Scale);
    RectHeight = floor(Rectangle(:,4)*Scale);
    RectWeight = Rectangle(:,5);
    r_sum = ufd_sumRect(integralImage,RectX,RectY,RectWidth,RectHeight).*RectWeight;
    Rectangle_sum = Rectangle_sum + r_sum;
end
Rectangle_sum = Rectangle_sum * inverseArea;

% Get the values of the current haar-classifiers
LeafTreshold=Leaf(:,1);
LeftValue = Leaf(:,2);
RightValue =Leaf(:,3);
LeftNode = Leaf(:,4);
RightNode =Leaf(:,5);
%titled=Leaf(:,21);

% Check the haar-response versus the haar-classifier treshold
% If the haar-response is larger, use the right node/value otherwise the
% left node/value
Node=zeros(size(x));
Tree_sum =zeros(size(x));
check=Rectangle_sum >= LeafTreshold(:).*stddev;
Node(check) =RightNode(check);
Node(~check)=LeftNode(~check);
Tree_sum(check)=RightValue(check);
Tree_sum(~check)=LeftValue(~check);

% If a Node has a larger value then -1, it is not the end node with
% a value, but it is connected to another weak-classifier
check=Node>-1;
if(any(check))
    Tree_sum(check)=ufd_treeDetect(Node(check),Tree,Scale,x(check),y(check),integralImage,stddev(check),inverseArea);
end