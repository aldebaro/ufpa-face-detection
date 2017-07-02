myFaceDetector.m is a very simple (and dumb) implementation of a face detector. It simply uses the Euclidean distance between the window under analysis and a template face image.

To run the evaluator code, execute: evaluateDetector.m

Observations about evaluateDetector.m:

1) Instead of using a large number of testing images, these images are generated on-the-fly by randomly positioning the face on a background image. The scale of the face image is also chosen randomly.

2)  4 landscape (background) images and 3 face images are used for the tests with evaluateDetector.m.

3) Half of the generated test images have a face and another half do not have.
