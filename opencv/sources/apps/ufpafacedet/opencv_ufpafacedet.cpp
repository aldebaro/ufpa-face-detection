/*	Example file to debug Viola and Jones' face detection algorithm.
	UFPA, Brazil, Feb. 07, 2016. */
#include <opencv2/objdetect.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>

#include<iostream>
#include<stdio.h>

using namespace std;
using namespace cv;

int main(){

	//The xml below comes with OpenCV. Change the PATH to the one on your computer:
	String face_cascade = "C:/ak/Works/2016_opencv/sources/data/haarcascades/haarcascade_frontalface_alt.xml";
	//Get a JPEG image and change below to point to it
	String imgfile = "C:/ak/Works/2016_opencv/build3/bin/Debug/photo.jpg";

	CascadeClassifier face; //declare the classifier

	if(!face.load(face_cascade)){ //loads the classifier from the XML file
		printf("Loading Error!");
		return -1;
	}	
	Mat image = imread(imgfile); //read the image file you provided
	Mat gray; //declare a matrix
	cvtColor(image, gray, COLOR_BGR2GRAY); //convert from color to gray scale
	
	std::vector<Rect> faces; //create an array of rectangles to indicate the faces
	face.detectMultiScale(gray, faces); //perform the face detection
	
	for(size_t i=0;i<faces.size();i++){ //add all the detected rectangles to the original image
		rectangle(image, Point(faces[i].x, faces[i].y), Point(faces[i].x + faces[i].width, faces[i].y + faces[i].height), Scalar(255,0,0),2);
	}

#if 1 // show the image with rectangles
	imshow("face detection", image);
	waitKey(0);
	destroyAllWindows();
#else //write a file with the image superimposed to the detected rectangles
	imwrite("photo_with_faces.jpg",image);
#endif
	return 0;
}
