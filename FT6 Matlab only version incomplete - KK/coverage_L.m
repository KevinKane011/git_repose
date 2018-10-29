function [coverage_result, coverage_max_limit, coverage_min_limit] = coverage_L(depth_all, v_pix, h_pix, distance)

% Kevin Kane and Laura Boon
% 
% RGB Subsystem Active REQUIRED
% COVERAGE: The portion of the FOV where data is missing due to light
% source pattern being un-observable (as searched for from the left side of
% the image).
% METHOD:  Count the number of columns (testing from left to right side of
% the ROI depth data) where at least 50% of the vertical pixels do not have
% a value within the range of 10% of the actual depth distance (i.e.
% distance - 10% < data < distance + 10%). Apply test to each of at least
% 50 frames and report the largest column count across all 50 frames.
% MAX: 60
% MIN: 1

%% coverage_L

disp('coverage start...');
tic

coverage_max_limit = 60;
coverage_min_limit = 1;

% Min/max distances help removes spray and 0's
depth_min = distance - (distance*0.1);
depth_max = distance + (distance*0.1);
depth_all = depth_all(v_pix,h_pix,:);
[v_res, ~, nframes] = size(depth_all);

if nframes < 50
    coverage_result = -1;
    error('ERROR: less then 50 frames at coverage test');
else
    coverage_result = 0;
    for j = 1:nframes
        dead_pix = isnan(depth_all(:,1:100,j));
        bad_depth_pix = ~(depth_all(:,1:100,j)>depth_min & depth_all(:,1:100,j)<depth_max);
        missing_pix = sum((dead_pix|bad_depth_pix));
        
        coverage = find(missing_pix < (v_res*0.5));
        if size(coverage, 2) == 0
            continue;
        elseif coverage(1) > coverage_result
            coverage_result = coverage(1);
        end
    end 
end

disp('coverage stop...');
toc

end