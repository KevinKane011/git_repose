150function [flatness_result, flatness_max_limit, flatness_min_limit] = flatness(depth_all, v_pix, h_pix, distance)

% Kevin Kane and Laura Boon
%
% RGB Subsystem Active REQUIRED
% FLATNESS: The flatness of the ROI depth data in 3-D space. 
% METHOD: Find the RMS error of the best fit plane to the given data. Apply test to each of at least 50 frames and report the largest error calculated across all 50 frames.
% MAX: at distance 5000mm = 150
% MAX: at distance 650 mm = 3
% MIN: 0

%% flatness

disp('flatness start...');
tic

if distance == 650
    flatness_max_limit = 3;
elseif distance == 5000
    flatness_max_limit = 150;
else
    error('ERROR: reached unreachable location in flatness test');
end
flatness_min_limit = 0;

depth_all = depth_all(v_pix,h_pix,:);
[~, ~, nframes] = size(depth_all);
rmse = zeros(nframes,1);

if nframes < 50
    flatness_result = -1;
    error('ERROR: less then 50 frames at flatness test');
else
    
    for j = 1:nframes
        Z = depth_all(:,:,j);
        [X,Y] = meshgrid(h_pix,v_pix);
        % fit doesn't work with NAN's Only keep the non-nan values
        if any(isnan(Z(:)))
            X = X(:);
            Z = Z(:);
            Y = Y(:);
            X = X(~isnan(Z));
            Y = Y(~isnan(Z));
            Z = Z(~isnan(Z));
        end
        %[f, gof] = fit([X(:), Y(:)], Z(:),'poly11'); % takes ~0.045 seconds with Macbook Pro
        %rmse(j) = gof.rmse;
        %plot(f, [X(:) Y(:)], Z(:));
        %pause(2.5);
        %close(fig);
    end
    %flatness_result = max(rmse);
    flatness_result = -1;
end
    
disp('flatness end...');   
toc
     
end
