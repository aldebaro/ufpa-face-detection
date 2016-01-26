# ufpa-face-detection

Face detection for Octave / Matlab based on Viola &amp; Jones' algorithm [1].

This code runs both on Octave and Matlab. Note that Mathworks has its own implementation [2]. OpenCV also provides an implementation [3].

Convention: all files (scripts and functions) start with the prefix ufd_ (UFPA face detection). 

The face detector has a training and a test stages. The main scripts for training and testing are: ufd_train and ufd_test, respectively.

References:
[1] Robust Real-Time Face Detection, Paul Viola and Michael Jones, International Journal of Computer Vision 57(2), 137–154, 2004.

[2] http://www.mathworks.com/help/vision/ref/vision.cascadeobjectdetector-class.html

[3] http://docs.opencv.org/master/d7/d8b/tutorial_py_face_detection.html
