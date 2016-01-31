function I=ufd_integralImage(X)
    % function I=ufd_integralImage(X)
    % Input: X is a matrix representing a gray-scale image
    % Output: I is the integral image of X

    % upcasting the matrix representing the image to double
    % to make sure we don't lose data 
    X = im2double(X);
    % first the cumulative sum of the columns than another cumulative
    % sum nested for the rows with the new values to calculate the 
    % integral image (or the summed area table)
    % TODO do this calculation using for loops
    I = cumsum(cumsum(X, 2), 1);
end