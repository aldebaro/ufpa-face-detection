function integralImage=ufd_integralImage(X, Options)
    % function I=ufd_integralImage(X)
    % Input: X is a matrix representing a gray-scale image
    % Output: I is the integral image of X

    % converting to gray (needs the image package)
    if (size(X,3)>1)
        X = rgb2gray(X);
    end

    % upcasting the matrix representing the image to double
    % to make sure we don't lose data 
    X = im2double(X); %it will scale the data if not double (e.g. uint8)

    % added the resize option
    if(Options.Resize)
    if (size(X,2) > size(X,1)),
        Ratio = size(X,2) / 384;
    else
        Ratio = size(X,1) / 384;
    end
        X = imresize(X, [size(X,1) size(X,2) ]/ Ratio);
    else
        Ratio=1;
    end
    
    % first the cumulative sum of the columns than another cumulative
    % sum nested for the rows with the new values to calculate the 
    % integral image (or the summed area table)
    I = cumsum(cumsum(X, 2), 1);
    
    % Make integral image to calculate fast a local standard deviation of the
    % pixel data (have no idea)
    I2 = cumsum(cumsum(X.^2, 1), 2);
    
    % if we where to use for loops
    % numcol = columns(X);
    % numrow = rows(X);
    % for row = 1:numrow
    %    for col = 1:numcol
    %        if row > 1 && col > 1
    %            I(row,col) = X(row,col) + I(row-1,col) + I(row,col-1) - I(row-1,col-1);
    %        elseif row > 1
    %            I(row,col) = X(row,col) + I(row-1,col);
    %        elseif col > 1
    %            I(row,col) = X(row,col) + I(row,col-1);
    %        else
    %            I(row,col) = X(row,col);
    %        endif
    %    endfor
    % endfor

    % Add a row and a column of zeros before and above the begin of the matrix for both matrixes
    % First concat the column of zeros to the matrix
    I = [zeros(size(I,1), 1) I];
    I2 = [zeros(size(I2,1), 1) I2];
    
    % Then the row
    I = [zeros(1, size(I,2)); I];
    I2 = [zeros(1, size(I2,2)); I2];

    % If we want to use the function padarray from the image package
    % I = padarray(I, [1 1], 'pre')
    
    % returns a struct because every other function expects one
    integralImage = struct('ii', I, 'ii2', I2, 'width', size(X,2), 'height', size(X,1), 'Ratio', Ratio);
    
%endfunction
