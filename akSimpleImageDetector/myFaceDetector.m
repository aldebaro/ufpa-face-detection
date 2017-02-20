function [decision,detectedRegion]=myFaceDetector(im)
N=size(im,1); %should be 512
M=86; %face images are 86 x 86 pixels
threshold=3e3; %threshold found by tria-and-error
%scales=[0.25 1 4]; %possible scales for image size (to speed up)
scales=[0.25 0.5 1 2 4]; %possible scales for image size
name='face5.png'; %face image that will work as face "pattern"
face=imread(name); %read file
[n1,n2,n3]=size(face); %check dimensions
if n1~=M || n2~=M || n3~=3
    error(['Face RGB image ' name ...
        ' needs to have dimension 86x86x3']);
end
%To simplify, will process in gray scale (may loose accuracy)
im=double(rgb2gray(im)); %convert to gray and cast
face=rgb2gray(face); %keep it as uint8 and cast in loop below
minMeanSquaredError=Inf; %initialize to large value
for s=1:length(scales) %go over all pre-defined scaling factors
    thisScale=scales(s); %pick the current scale
    if thisScale==1 %do not work much if scale == 1
        pattern=double(face); %cast from uint8 to double
        newM=M; %default face size is MxM pixels
    else %resize if scale is different than one        
        pattern=imresize(face,thisScale); %resize image        
        pattern=double(pattern); %cast from uint8 to double
        newM=size(pattern,1); %update face pattern size
    end
    %% make sure whole face fits in image, properly restricting the
    %upper-left pixel location
    maxValue=N-newM; %need to save space for newM pixels
    for i=1:maxValue %scan all image
        for j=1:maxValue
            block=im(i:i+newM-1,j:j+newM-1); %extract a block
            thisError=block-pattern; %error
            thisDistance=sum(thisError(:).^2)/(newM^2); %normalized quadratic error
            if thisDistance < minMeanSquaredError %check if better than best
                minMeanSquaredError = thisDistance; %update distance
                bestRegion=[j,i,newM,newM]; %update region
            end
        end
    end
end
disp(['minMeanSquaredError = ' num2str(minMeanSquaredError)])
%% indicate a face exists if the distance is below threshold
if minMeanSquaredError < threshold;
    decision = 'has face';
    detectedRegion = bestRegion;
else %there is no face
    decision = 'no face';
    detectedRegion = []; %return null
end