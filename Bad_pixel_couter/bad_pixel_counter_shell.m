function [ bad_pixel_count, bad_pixel_blob_count, blob_sizes, BW ] = bad_pixel_counter_shell(depth_image, varargin)
%BAD_PIXEL_COUNTER_SHELL calls BAD_PIXEL_COUNTER & removes large two blobs
%   Details: removes the larges two blobs from blob_size. Check function 
%   BAD_PIXEL_COUNTER for more details.

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

[ ~, ~, blob_sizes, BW ] = bad_pixel_counter(depth_image, threshold, greater_less, false);
blob_sizes = sort(blob_sizes);      % sort
blob_sizes = blob_sizes(1:end-2);   % remove largest 2 from array
bad_pixel_count = sum(blob_sizes);
bad_pixel_blob_count = size(blob_sizes,1);

%% Display Binary Image and Histogram
if display == true
    figure, imshow(BW);
    
    BinLimits = [0,200];
    if max(blob_sizes) > BinLimits(2)
        BinLimits(2) = max(blob_sizes);
        disp('WARNING: Largest "blob" is larger then expected. Historgam size adjusted')
    end
    nbins = 20;
    figure, histogram(blob_sizes, nbins,'BinLimits', BinLimits);
end
