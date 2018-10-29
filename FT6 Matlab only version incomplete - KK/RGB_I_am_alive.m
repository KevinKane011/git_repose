function [result, RGB_timestamp] = RGB_I_am_alive(capture_RGB_command)

%% RGB_I_am_alive
disp('RGB I am alive start...');
tic

% Empty input argument (factory use, mode = 1)
if nargin < 1
    disp('No capture_RGB_command string input');
    backdoor = 'C:\Orbbec_factory_program_release\backdoor.txt';
    if exist(backdoor, 'file') == 2
        backdoortext = fileread(backdoor);
        commands = {'capture_RGB_command = '};
        [~, endIndex] = regexp(backdoortext, commands(1));
        if isempty(endIndex{1})
        else
            command = backdoortext(endIndex{1}+2:end);
            [startIndex, ~] = regexp(command,'''');
            eval([commands{1} 'command(1:startIndex(1)-1);']);
        end 
    else
        capture_RGB_command = '.\leopard_rgb_capture 0 10 10';
    end
end

[filepath,name,ext] = fileparts(...
    'C:\Orbbec_factory_program_release\leopard_rgb_streamer_and_capture\leopard_out.png');
result = 0;
c = clock;
%RGB_timestamp = 'YYYY-MM-DD_HH:mm:ss'
RGB_timestamp = [num2str(c(1)) '-' num2str(c(2)) '-' num2str(c(3)) '_' num2str(c(4)) ':' num2str(c(5)) ':' num2str(round(c(6)))];

try
    currentFolder = pwd;
    cd(filepath)
    [status,cmdout] = eval(['dos(' capture_RGB_command ')']);
    imshow([name ext]);
    fig = gcf;
    i = imread([name ext]);

    % Check Image
    if isequal(size(i),[2048 3080]) % check size
        if sum(sum(i)) ~= 4095*2048*3080 % check not all ones
            if sum(sum(i)) ~= 0 % check not all zeros
                result = 1;
            end
        end
    end

    movefile([filepath '\' name ext], currentFolder);
    pause(4);
    close(fig);
    
catch ME
    ME.identifier
    switch ME.identifier
        case 'images:getImageFromFile:fileDoesNotExist'
            e = warndlg({'Image not found! Please check that camera is plugged in, '...
                'and retest. If it fails again then FAIL unit!'},...
                'Warning, Image file does not exist!');
            uiwait(e);
            result = -2;
        otherwise
            rethrow(ME)
    end
end

cd(currentFolder);

toc
disp('RGB I am alive stop...');