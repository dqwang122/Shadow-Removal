% FUNCTION writes an ASCII file in LIBSVM format with data and associated
% labels.
%
%   libsvmwrite( filename, labels, data );
%
% INPUT :
%   filename        - filename of the text file to create
%   gvector         - column vector with labels
%   data            - data matrix with samples in rows
%                     (matrix should be sparse!)
%
% OUTPUT :
%   <filename>