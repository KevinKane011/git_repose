function [capture_depth_command, capture_RGB_command_A, capture_RGB_command_B, capture_RGB_command, get_RGB_serial_command] = set_command_line_str()

%% Command_line strings set
% Default settings
capture_depth_command = ['C:\Orbbec_factory_program_release\bin_warmuptemp\capture_orbbec.exe'...
    ' -target=1 -ir_save_count=1 -single -nframes=50 -temp_trigger_min_rise=0.19 -temp_trigger_poll_samples=100'...
    ' -temp_trigger_poll_ms=100 -depth_override=(*distance*) -tag=PVT_(*TestType*)'];
capture_RGB_command_A = '';
capture_RGB_command_B = '.\leopard_rgb_capture 0 10 10';
capture_RGB_command = '.\leopard_rgb_capture 0 10 10';
get_RGB_serial_command = 'C:\Python27\python.exe C:\Orbbec_factory_program_release\get_leopard_serials.py';

% backdoor.txt overwrites commandline strings
backdoor = 'C:\Orbbec_factory_program_release\backdoor.txt';
if exist(backdoor, 'file') == 2
    backdoortext = fileread(backdoor);
    commands = {'capture_depth_command = ', 'capture_RGB_command_A = ', 'capture_RGB_command_B = ', 'capture_RGB_command = ', 'get_RGB_serial_command = '};
    s = size(commands);
    for k = 1:s(2)
        [~, endIndex] = regexp(backdoortext, commands(k));
        if isempty(endIndex{1})
            continue
        else
            command = backdoortext(endIndex{1}+2:end);
            [startIndex, ~] = regexp(command,'''');
            eval([commands{k} 'command(1:startIndex(1)-1);']);
        end
    end
end