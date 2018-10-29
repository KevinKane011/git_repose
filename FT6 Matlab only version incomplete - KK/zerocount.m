function [zerocount_result, zerocount_max_limit, zerocount_min_limit] = zerocount(depth_all, v_pix, h_pix, distance)

% Kevin Kane and Laura Boon
%
% RGB Subsystem Active REQUIRED 
% ZEROCOUNT: The percentage of non-zero elements in the depth image.
% METHOD:  Count the number of non-zero pixels in the ROI depth data. Apply
% test to each of at least 50 frames and report the minimum calculated
% across all 50 frames.
% MAX: at distance 5000mm is 100% * ROI = 1*513*154 = 79002 
% MAX: at distance 650mm is 100% * ROI = 1*640*480 = 307200 
% MIN: at distance 5000mm is 25% * ROI = 0.25*513*154 = 49152 
% MIN: at distance 650mm is 25% * ROI = 0.25*640*480 = 76800

%% zerocount

tic
disp('zerocount start...');

zerocount_max_limit = 1.00;
zerocount_min_limit = 0.25;

[~, ~, nframes] = size(depth_all);

if nframes < 50
    zerocount_result = -1;
    error('ERROR: less then 50 frames at zerocount test');
else
    zerocount = ones(1,nframes);
    for j = 1:nframes
        zerocount(j) = nnz(depth_all(:,:,j))/numel(depth_all(:,:,j));
    end
    zerocount_result = min(zerocount);
end

disp('zerocount stop...');
toc

end
