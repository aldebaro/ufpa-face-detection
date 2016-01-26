# ufpa-face-detection

Face detection for Octave / Matlab based on Viola &amp; Jones' algorithm [1].

This code runs both on Octave and Matlab. Note that Mathworks has its own implementation [2]. OpenCV also provides an implementation [3].

Convention: all files (scripts and functions) start with the prefix ufd_ (UFPA face detection). 

The face detector has a training and a test stages. The main scripts for training and testing are: ufd_train and ufd_test, respectively.

Development strategy:

- We will use the training stage of OpenCV and import the classifier in [4] (> 30k lines). For that, we need code to import the XML file into Octave / Matlab. Note that Mathworks has support to OpenCV [5] but we will not use it for the sake of compatibility with Octave. This strategy will force us to use the same data structures as OpenCV but will allow to debug our code using OpenCV as a reference.
- We first concentrate on the test stage, with the following guidelines: 1) use a webcam video capture software to obtain a screenshot as an image file, 2) read the image from Octave / Matlab, convert it to gray scale and show it, 3) calculate the Integral Image, 4) for all required resolutions, calculate the needed parameters and invoke the classifier, 5) draw the rectangles according to the classifier's decisions.

<b>References:</b>

[1] Robust Real-Time Face Detection, Paul Viola and Michael Jones, International Journal of Computer Vision 57(2), 137–154, 2004.

[2] http://www.mathworks.com/help/vision/ref/vision.cascadeobjectdetector-class.html

[3] http://docs.opencv.org/master/d7/d8b/tutorial_py_face_detection.html

[4] https://github.com/Itseez/opencv/blob/master/data/haarcascades/haarcascade_frontalface_default.xml

[5] http://www.mathworks.com/help/vision/ug/opencv-interface.html
