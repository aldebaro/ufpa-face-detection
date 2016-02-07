// ak_face.cpp : main project file.

//#include "stdafx.h"

//using namespace System;

//#include <objdetect.hpp>
//#include <highgui.hpp>
//#include <imgproc.hpp>

#include <opencv2/objdetect.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>


#include<iostream>
#include<stdio.h>

using namespace std;
using namespace cv;

int main(){

	String face_cascade = "C:/ak/Works/2016_opencv/sources/data/haarcascades/haarcascade_frontalface_alt.xml";

	String imgfile = "C:/ak/Works/2016_opencv/build3/bin/Debug/photo.jpg";

	CascadeClassifier face;

	if(!face.load(face_cascade)){
		printf("Loading Error!");
		return -1;
	}
	
	Mat image = imread(imgfile);
	Mat gray;
	cvtColor(image, gray, COLOR_BGR2GRAY);
	
	std::vector<Rect> faces;
	face.detectMultiScale(gray, faces);
	
	for(size_t i=0;i<faces.size();i++){
		rectangle(image, Point(faces[i].x, faces[i].y), Point(faces[i].x + faces[i].width, faces[i].y + faces[i].height), Scalar(255,0,0),2);
		//Mat faceROI = gray(faces[i]);
	}

#if 1
	imshow("face detection", image);
	waitKey(0);
	destroyAllWindows();
#else
	imwrite("photo_with_faces.jpg",image);
#endif
	return 0;
}
