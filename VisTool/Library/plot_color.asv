function plot_color(data,lim_min,lim_max,fig)
% function plot_color
% This function generates a color plot of the depth data with specificed
% limits. The plot is shown on the figure 'fig'.
% 
% The function adds a black scatter plot over the color map where there are
% nan's in the depth map. 
%
% Inputs:
% data: A NxM depth map generated from FT6A/B data
% lim_min, lim_max: The min and max limits for the color bar, anything
% above or below those values will be 'saturated'
% fig: The figure label in which the plot is generated. 
% 


fig;
imagesc(data,[lim_min,lim_max])
hold on
[ii, jj] = find(isnan(data));
scatter(jj, ii, 2,'.k')
hold off

