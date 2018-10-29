function plot_depth_map()
% plot_depth_map creates and saved a 3D depth map of the file selected.
% After the file is generated it prompts the user if there are more files
% to be printed.

[file, path] = uigetfile('*.png','Secelt file(s) to plot','MultiSelect','on');

for i = 1:length(file)
    cd(path)
    data = load_depth_image([ path '/' file{i}]);

    show_stacked_maps(data)
    title(file{i}(1:end-4),'interpreter','none')
    saveas(gcf,[file{i}(1:end-4) '_plot.png'])
end

close all

end