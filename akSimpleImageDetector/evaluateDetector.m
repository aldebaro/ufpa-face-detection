%% Constrained face detection.
%A face may occur in the image or not, but there is at most
%one face in the image (i.e., zero or one face in each generated image)
%pkg load image %in case using Octave
tic %start counting ellapsed time
numTests=100; %total number of tests
N=512; %landscape images are 512 x 512 pixels
M=86; %face images are 86 x 86 pixels
scales=[0.25 0.5 1 2 4]; %possible scales for image size
%scales=[0.25 1 4]; %possible scales for image size (to speed up)
warning('Processing started...');
numErrors = 0; %counter for error rate
numImagesWithFaces=0; %counter for the "positive" examples
regionAccuracy = 0; %accounts for the accuracy on estimating the face region
n=0; %counter for the number of tests
while n<numTests %go over all tests
    for i=1:4 %go over all lanscape images
        name=['landscape' num2str(i) '.jpg'];
        originalLandscape=imread(name); %get background image
        [n1,n2,n3]=size(originalLandscape); %check dimensions
        if n1~=N || n2~=N || n3~=3
            error(['Landscape RGB image ' name ...
                ' needs to have dimension 512x512x3']);
        end
        for j=1:3 %go over all face images
            im=originalLandscape; %reset image with face
            if rand() > 0.5 %define 50% for a face or not
                correctOutput='no face'; %default correct answer: now face
            else
                correctOutput='has face'; %correct answer is: has face
                numImagesWithFaces=numImagesWithFaces+1; %update
                name=['face' num2str(j) '.png']; %read face image
                face=imread(name);
                [n1,n2,n3]=size(face); %check dimensions
                if n1~=M || n2~=M || n3~=3
                    error(['Face RGB image ' name ...
                        ' needs to have dimension 86x86x3']);
                end
                %randomly find a scale among the possible ones
                scaleIndex=floor(rand()*length(scales))+1;
                thisScale=scales(scaleIndex); %this scale factor
                newM=M; %default face size is MxM pixels
                if thisScale~=1 %resize if different than one
                    face=imresize(face,thisScale); %resize image
                    newM=size(face,1); %update face size
                end
                %% make sure whole face fits in image
                maxValue=N-newM; %need to save space for newM pixels
                %randomly find the (x,y) corner top-left pixel
                x=floor(rand()*maxValue)+1;
                y=floor(rand()*maxValue)+1;
                im(x:x+newM-1,y:y+newM-1,:)=face(:,:,:); %superimpose the face
            end
            %% Show correct decision
            disp(['n=' num2str(n) ' ==> correctOutput = ' correctOutput]);
            %% Call the detector
            if 1
                [decision,detectedRegion]=myFaceDetector(im);
            else %for debugging, use the correct decisions
                decision=correctOutput;
                detectedRegion=[y,x,newM,newM];
            end
            disp(['decision = ' decision]);
            %% Process the dectector output
            if ~strcmp(decision,correctOutput) %'has face' or 'no face'
                numErrors = numErrors+1; %increase error counter
            end
            if strcmp(decision,'has face') && strcmp(correctOutput,'has face')
                correctRegion=[y,x,newM,newM];
                intersectionArea=rectint(correctRegion,detectedRegion);
                normalizationFactor=max(newM^2,detectedRegion(3)*detectedRegion(4));
                thisRegionAccuracy=intersectionArea/normalizationFactor;
                disp(['thisRegionAccuracy=' num2str(thisRegionAccuracy) ' %'])
                regionAccuracy=regionAccuracy+thisRegionAccuracy;
            end
            %% Show image and, eventually, detected face region as rectangle
            imshow(im) %show image
            if strcmp(decision,'has face')
                rectangle('Position', detectedRegion, ...
                    'LineWidth',3,'EdgeColor','red'); %// draw rectangle on image
            end
            title(['n=' num2str(n) ': correct=' correctOutput ...
                ' / decision=' decision]);
            drawnow
            if strcmp(lastwarn,'Processing started...')~= 1
                %trick to debug when a warning shows up
                pause
            end
            n=n+1; %update counter
            if n >= numTests
                break; %need to break inner "for" loop
            end
        end
        if n >= numTests
            break; %need to break outer "for" loop
        end
    end
end
%% Final statistics
display(['Error rate (%) = ' num2str(100*numErrors/numTests)])
display(['Intersection area metric (%, optimum is 100%) = ' ...
    num2str(100*regionAccuracy/numImagesWithFaces)])
toc %count ellapsed time