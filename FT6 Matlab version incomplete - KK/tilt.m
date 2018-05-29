function [tilt_result, tilt_max_limit, tilt_min_limit] = tilt(depth_all, v_pix, h_pix, distance, spray_high, spray_low)

% Kevin Kane and Laura Boon (May 2018)
%
% RGB Subsystem Active REQUIRED
% TILT: The maximum depth change across the Region of Interest (ROI) 
% excluding "spray". 
% METHOD:  Solve for the difference in mm between the maximum
% depth pixel values and the minimum depth pixel values within the ROI
% depth data, after excluding ?spray? pixels as defined above. Apply test
% to each of at least 50 frames and report the maximum depth difference
% found across all 50 frames. 
% MAX: at distance 6000mm = 40% * 6000mm = 2400mm 
% MAX: at distance 650mm = 40% * 650mm = 260mm 
% MIN: 0

%% tilt

% tic
% disp('tilt start...');

[~, ~, nframes] = size(depth_all);

if nargin < 5
    spray_low = ones(1,nframes)*10;
    spray_high = ones(1,nframes)*10;
elseif nargin < 6
    spray_low = ones(1,nframes)*10;
end

tilt_max_limit = distance * 0.4;
tilt_min_limit = 0;

if nframes < 50
    tilt_result = -1;
    error('ERROR: less then 50 frames at tilt test');
else
    diff_tilt = zeros(1,nframes);
    for j = 1:nframes
        hold = depth_all(v_pix,h_pix,j); % crop image
        sorted = sort(hold(:)); % still has nan's
        sorted = sorted(~isnan(sorted)); % nan's removed
        if isempty(sorted)
            diff_tilt(j) = NaN; % fails images with no valid data
        elseif size(sorted,1) <= spray_high(j)
            diff_tilt(j) = NaN; % fails images with all data points are spray
        else               
            max_val = sorted(end-spray_high(j)); % max_val that's NOT spray
            min_val = sorted(spray_low(j)+1); % min_val that's NOT spray
            diff_tilt(j) = max_val-min_val;
        end
    end
% 	tilt_mean = mean(diff_tilt);
    tilt_result = max(diff_tilt);

end

% disp('tilt stop...');
% toc

end
