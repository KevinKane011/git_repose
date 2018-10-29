% Plot the results

% load the results
load('Orbbec_Astra_16122010564_OverExposureResults_2.mat');
% create a plot for each distance.  x,y are exposure and gain, z = coverage
% Do a surface plot
dist = distance(1,:);
exp_vec = unique(exp);
gain_vec = unique(gain);
for i = 1:length(dist)
    figure
    cov_matrix = reshape(coverage(:,i),length(gain_vec),length(exp_vec));
    surf(exp_vec,gain_vec,cov_matrix);
    xlabel('exposure (dec)')
    ylabel('gain (dec)')
    zlabel('% Coverage')
    zlim([0, 100]);
    title(['Over exposure - Distance = ' num2str(dist(i))])
end

% Do the other data set
% load('Orbbec_Astra_16122010564_UnderExposureResults.mat');
% dist = distance(1,:);
% exp_vec = unique(exp);
% gain_vec = unique(gain);
% figure
% surf(exp_vec,dist,coverage');
% xlabel('exposure (dec)')
% ylabel('distance (m)')
% zlabel('% Coverage')
% zlim([0, 100]);
% title(['Under exposure - Gain = ' num2str(gain_vec)])

