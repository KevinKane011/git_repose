%Code to compare the postfilter threshold values to find the best fit
% clear all
close all

cd /Users/kkane/Desktop/Astra_Overlap;
data_dir = dir('*postfilter_threshold*');

% Load in all the data
q = length(data_dir);
for i = 1:q
    disp(['Folder ' num2str(i) ' of ' num2str(q)]);
    cd(data_dir(i).name)
    load_file = dir('cap*');
    load(load_file.name);
    filename = cap.test(end-2:end);
    eval(['threshold_' filename ' = cap;']);
    mmdepth = num2str(cap.rangefinder_binned);
    disp(['Data set ' num2str(i) ' of ' num2str(q) ' :  Threshold ' filename ' at ' num2str(cap.rangefinder_binned) 'mm']);
     
    % Visualize the blank size distrabution
    eval(['bad_pixel_count_' filename ' = 0']);
    eval(['bad_pixel_blob_count_' filename ' = 0']);
    eval(['blob_sizes_' filename ' = []']);
    l = length(cap.depth(1,1,:));
    %figure
    for x = 1:l
        disp(['Frame ' num2str(x) ' of ' num2str(l)]);
        [bad_pixel_count, bad_pixel_blob_count, blob_sizes, BW] = bad_pixel_counter_shell(cap.depth(:,:,x), 0, 'less', false);
        close all;
        imshow(BW); % Display Depth Images
        title(['Threshold ' filename ' at ' mmdepth 'mm : Black & White Image (frame ' num2str(l) ')']);
        pause(.1);
        eval(['bad_pixel_count_' filename ' = bad_pixel_count_' filename '+ bad_pixel_count;']);
        eval(['bad_pixel_blob_count_' filename ' = bad_pixel_blob_count_' filename '+ bad_pixel_blob_count;']);
        eval(['blob_sizes_' filename])
        if isempty(blob_sizes)
        else
            eval(['blob_sizes_' filename ' = cat(1, blob_sizes_' filename ', blob_sizes);']);
        end
    end
    
    % Display numaric results
    %eval(['disp(bad_pixel_count_' filename ')']);
    %eval(['disp(bad_pixel_blob_count_' filename ')']);
    %eval(['disp(blob_sizes_' filename ')']);

    % Histogram of Blank Pixels
    %figure
    %eval(['histogram(blob_sizes_' filename ')']);
    %title(['Threshold ' filename ' at ' mmdepth 'mm : Blank Pixel Blob Size']);
    
    % Stack Depth images
    %show_stacked_maps(cap.depth);
    %title(['Threshold ' filename ' at ' mmdepth 'mm: Stacked Depth Images']);
    
    f1 = 'bad_pixel_count';
    f2 = 'bad_pixel_blob_count';
    f3 = 'blob_sizes';
    f4 = 'largest_blob';
    f5 = 'BW_image';
    f6 = 'Depth_in_mm';
    f7 = 'Threshold';
    f8 = 'Directory_Name';
    results = struct( f1, bad_pixel_count, ...
                f2, bad_pixel_blob_count, ...
                f3, blob_sizes, ...
                f4, max(blob_sizes), ...
                f5, BW, ...
                f6, mmdepth, ...
                f7, filename, ...
                f8, data_dir(i).name);
    name = ['OA_' data_dir(i).name(14:end) '_results'];
    eval(['save(''' name '.mat'', ''results'');']);
    cd ..
end

%Evalulate results
