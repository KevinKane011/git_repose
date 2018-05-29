function [zerocount_result, zerocount_max_limit, zerocount_min_limit] = zerocount(depth_all, v_pix, h_pix, distance)

% Kevin Kane and Laura Boon (May 2018)
%
% RGB Subsystem Active REQUIRED 
% ZEROCOUNT: The percentage of zero (or NaN) elements in the depth image.
% METHOD:  Count the number of zero (or NaN) pixels in the ROI depth data.
% Calculate the ratio (or NaN) pixel in the ROI. Apply test to each of at
% least 50 frames and report the max ratio calculated across all 50 frames.
%
% MAX: at distance 6000mm is 20% = 0.20
% MAX: at distance 650mm is 20% = 0.20 
% MIN: at distance 6000mm is 0% = 0.00
% MIN: at distance 650mm is 0% = 0.00
%
% Notice: previous steps of the depth image processing may have converted
% zero value elements to NaN.

%% zerocount

% tic
% disp('zerocount start...');

if distance == 650
    zerocount_max_limit = 0.20;
elseif distance == 6000
    zerocount_max_limit = 0.20;
else
    error('ERROR: reached unreachable location in flatness test');
end
zerocount_min_limit = 0.00;

[~, ~, nframes] = size(depth_all);
depth_all(depth_all == 0) = nan;

if nframes < 50
    zerocount_result = -1;
    error('ERROR: less then 50 frames at zerocount test');
else
    zerocount = ones(1,nframes);
    for j = 1:nframes
        numnan_img = sum(sum(isnan(depth_all(:,:,j))));
        zerocount(j) = numnan_img/numel(depth_all(:,:,j));        
%        zerocount(j) = numnan(depth_all(:,:,j))/numel(depth_all(:,:,j));
    end
    zerocount_result = max(zerocount);
end

% disp('zerocount stop...');
% toc

end
