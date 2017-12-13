function [ bad_pixel_count, bad_pixel_blob_count, blob_sizes, BW ] = bad_pixel_counter(depth_image, varargin)
%BAD_PIXEL_COUNTER counts the number of bad (missing) depth pixels
%   Details: counts the number of bad (missing) pixels, number of blobs of
%   bad (missing) pixels, and graphs the distribution bad (missing) pixels 
%   per blob.
%
%   depth_image - image processing is done on
%   threshold - number threshold for bad pixels (defualt is 0)
%   greater_less - bad pixels are less-then-or-equal-to,...
%                   or greater-then-or-equal-to threshold (defualt is less)
%   display - option to display graphed results or not (defualt is true)

%% Deal with input arguments
% only want 3 optional inputs at most
numvarargs = length(varargin);
if numvarargs > 3
    error('myfuns:somefun2Alt:TooManyInputs', ...
        'requires at most 3 optional inputs');
end

% set defaults for optional inputs
optargs = {0 'less' true};

% now put these defaults into the valuesToUse cell array, 
% and overwrite the ones specified in varargin.
optargs(1:numvarargs) = varargin;

% Place optional args in memorable variable names
[threshold, greater_less, display] = optargs{:};

%% Load Threshold Black and White Image
BW = imbinarize(depth_image, threshold);
if greater_less == 'less'
    BW = imcomplement(BW);
end

%% Solve blob counts
CC1 = bwconncomp(BW,1);
bad_pixel_count = CC1.NumObjects;
CC4 = bwconncomp(BW,4);
bad_pixel_blob_count = size(CC4.PixelIdxList,2);

blob_sizes = zeros(bad_pixel_blob_count,1);
for x = 1:bad_pixel_blob_count
    size(CC4.PixelIdxList{x},1);
    blob_sizes(x) = size(CC4.PixelIdxList{x},1);
end

%% Display Binary Image and Histogram
if display == true
    figure, imshow(BW);
    figure, histogram(blob_sizes);
end

