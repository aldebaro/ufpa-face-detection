function [x,y] = ufd_detectSingleScale(x, y, scale, integralImages, w, h, haarCascade)
% This function detects objects using a fixed scale through a Haar cascade
% classifier. Returns coordinates [x,y] where objects were detected
% (Based on code by D. Kroon)
