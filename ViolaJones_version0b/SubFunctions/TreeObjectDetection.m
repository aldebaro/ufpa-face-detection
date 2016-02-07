function Tree_sum=TreeObjectDetection(Node,Tree,Scale,x,y,IntegralImage,StandardDeviation,InverseAreaa)

% Get the current haar-classifiers
Leaf= Tree(Node+1,:);

% Calculate the haar-feature response
Rectangle_sum = zeros(size(x));
for i_Rectangle = 1:3
    Rectangle = Leaf(:,(1:5)+i_Rectangle*5);
    RectX = floor(Rectangle(:,1)*Scale+x);
    RectY = floor(Rectangle(:,2)*Scale+y);
    RectWidth = floor(Rectangle(:,3)*Scale);
    RectHeight = floor(Rectangle(:,4)*Scale);
    RectWeight = Rectangle(:,5);
    r_sum = GetSumRect(IntegralImage,RectX,RectY,RectWidth,RectHeight).*RectWeight;
    Rectangle_sum = Rectangle_sum + r_sum;
end
Rectangle_sum = Rectangle_sum * InverseAreaa;

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
check=Rectangle_sum >= LeafTreshold(:).*StandardDeviation;
Node(check) =RightNode(check);
Node(~check)=LeftNode(~check);
Tree_sum(check)=RightValue(check);
Tree_sum(~check)=LeftValue(~check);

% If a Node has a larger value then -1, it is not the end node with
% a value, but it is connected to another weak-classifier
check=Node>-1;
if(any(check))
    Tree_sum(check)=TreeObjectDetection(Node(check),Tree,Scale,x(check),y(check),IntegralImage,StandardDeviation(check),InverseAreaa);
end

