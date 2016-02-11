function obj=ufd_multiScaleDetection(integralImages, haarCascade, options)
% This function performs object detection in multiple scales, calling ufd_detect
% function on each scale.
% (Based on code by D. Kroon)
