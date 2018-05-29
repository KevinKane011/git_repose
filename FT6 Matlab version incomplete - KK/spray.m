function [spray_result, spray_max_limit, spray_min_limit, spray_high, spray_low] = spray(depth_all, v_pix, h_pix, distance)

% Kevin Kane and Laura Boon (May 2018)
%
% RGB Subsystem Active REQUIRED
% SPRAY: The number of pixels for which invalid data is generated. 
% METHOD:  For this test, an "invalid" pixel is defined as a ROI depth data
% pixel not equal to zero AND outside the known distance by 10% (i.e. data
% < 0.9*distance OR 1.1*distance < data). Apply test to each of at least 50
% frames and report the maximum invalid pixel count observed across 50
% frames.
% MAX: at distance 6000mm is 5% * ROI = 0.05*513*154 = 3950
% MAX: at distance 650mm is 5% * ROI = 0.05*640*480 = 15360 
% MIN: 0

%% spray

% tic
% disp('spray start...');

depth_all = depth_all(v_pix,h_pix,:);
spray_max_limit = size(v_pix,2)*size(h_pix,2)*0.05;
spray_min_limit = 0;

dist_high = 1.2*distance;
dist_low = 0.8*distance;

[~, ~, nframes] = size(depth_all);

if nframes < 50
    spray_result = -1;
    spray_low = -1;
    spray_high = -1;
    error('ERROR: less then 50 frames at spray test');
else
    
    low = depth_all < dist_low;
    high = depth_all > dist_high;
    [~,~,z_low] = ind2sub(size(depth_all),find(low));
    [~,~,z_high] = ind2sub(size(depth_all),find(high));
    spray_low = histcounts(z_low,1:nframes+1);
    spray_high = histcounts(z_high,1:nframes+1);
    spray = spray_high + spray_low;
    spray_result = max(spray);
end

% disp('spray stop...');
% toc

end