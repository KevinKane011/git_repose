function [RGB_test_results, RGB_timestamp] = Stand_Alone_RGB_I_am_Alive()

%% Get RGB camera ID
RGB_id_image = imread('C:\Orbbec_factory_program_release\single_RGB.jpg');
imshow(RGB_id_image);
fig = gcf;
fig.Name = 'Image of RGB camera';
title('Image shows the location of RGB camera ID (red box) to be entered');
pos = fig.Position;
set(fig,'Position',[(2/3)*pos(1), (2/3)*pos(2), pos(3)+0.1, pos(4)]);
s = inputdlg({'Scan/Enter ID for the RGB camera'}, 'ID', [1 40], {'XXXXXXXXX'});
RGB_serial = s{1};
close(fig);

%% RGB Image capture and 'Alive' Test
[RGB_test_results, RGB_timestamp] = RGB_I_am_alive(capture_RGB_command);

%% RGB Data management
% Save RGB results to new .csv file
RGB_filename_csv = ['RGB_', RGB_serial, '.csv'];
FID = fopen(RGB_filename_csv,'a');
RGB_header_csv = {'RGB_SN', 'Date_Time', 'Module_SN', 'Station' ,'Alive'};
fprintf(FID,'%s, %s, %s, %s, %s',RGB_header_csv{1,:});
values_csv = {RGB_serial, RGB_timestamp, serial, TestType, RGB_test_results};
fprintf(FID,'%s, %s, %s, %s, %f',values_csv{1,:});
fclose(FID);

%% Append results to RGB_Master.csv file
RGB_master_csv = 'C:\Orbbec_Factory_FT6\FT6_RGB_Master_CSV.csv';
if exist(RGB_master_csv, 2)
    FID = fopen(master_csv,'a');
    fprintf(FID,'%s, %s, %s, %s, %f',values_csv{1,:});
    fclose(FID);
else
    copyfile(RGB_filename_csv, RGB_master_csv);
end % if exist(master_csv)
disp('RGB results data storage completed with no errors')

%% Display RGB camera pass/fail results to user
top = ['RGB_serial: ' RGB_serial '    Date_time: ' RGB_timestamp '    RGB "Alive" Test'];
test_header = {'Alive'};
test_limits = [1,1];
display_results(test_header, test_limits, test_results, top,...
    'C:\Orbbec_factory_program_release\RGB.jpg', 'c');

end % function