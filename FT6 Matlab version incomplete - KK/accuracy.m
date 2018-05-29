function [accuracy_result, accuracy_max_limit, accuracy_min_limit] = accuracy(depth_all, v_pix, h_pix, distance)

% Kevin Kane and Laura Boon (May 2018)
% 
% RGB Subsystem Active REQUIRED
% ACCURACY: The average measured depth across the ROI depth data. 
% METHOD: Solve for the average depth distance across the ROI depth data.
% Apply test to each of at least 50 frames and report the largest
% difference from the actual distance as calculated across all 50 frames.
% Min/max determined as +/- 8% of the nominal depth 
% MAX: + 0.08 * distance = 52mm and 480mm
% MIN: - 0.08 * distance = -52mm and -480mm

%% accuracy

% disp('accuracy start...');
% tic

accuracy_max_limit = 0.08*distance;
accuracy_min_limit = -0.08*distance;

nframes = size(depth_all,3);
ROI = depth_all(v_pix,h_pix,:);

if nframes < 50
    accuracy_result = -1;
    error('ERROR: less then 50 frames at accuracy test');
else 
    Avg = squeeze(mean(mean(ROI,1,'omitnan'),2,'omitnan'));
    distance_matrix = ones(size(Avg))*distance;
    diff = distance_matrix - Avg;
    [~, abs_diff_ind] = max(abs(diff));
    accuracy_result = diff(abs_diff_ind);
end

% disp('accuracy stop...');
% toc

end