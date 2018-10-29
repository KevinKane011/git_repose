function [status, list] = check_usb_error_handling(none, list, module_position)

c=0; % timer count, limit is 5 seconds
e=0; % error count, limit is 5
while 1
    pause(0.25)
    c=c+1;
    [lsub_status,cmdout] = dos('lsusb');
    if lsub_status ~= 0
        error(['Error with ''lsusb'' command: ' lsub_status]);
    end % lsub_status ~= 0
    cmdout = strsplit(cmdout,'\n');
    diff = setdiff(cmdout,none);
    if size(diff, 2) == 2
        status = 0;
        break
    elseif e == 5
        status = 1;
        list = [list module_position ' '];
        break
    elseif c == 20
        e=e+1;
        c=0;
        if size(diff, 2) == 0
            switch module_position
                case 'top'
                    brainstem_switch(0, 'enable');
                case 'middle'
                    brainstem_switch(2, 'enable');
                case 'bottom'
                    brainstem_switch(4, 'enable');
            end % switch module_position
            h = warndlg({['Could not connect to' module_position ' module!'],...
                'Please check that device is plugged in and powered on.',...
                ['When ready click ''OK'' to retry. There are ' num2str(5-e) ' tries left.']},...
                'Communications issue with module');
            uiwait(h)
        elseif size(diff, 2) == 1
            if isempty(strfind(diff{1:end}, '2bc5:0401'))
                h = warndlg({['RGB camera detected in ' module_position ' module; however, depth sensor ID missing!'],...
                    'Please check module for damage and device is plugged in fully.',...
                    ['When ready click ''OK'' to retry. There are ' num2str(5-e) ' tries left.']},...
                    'Communications issue depth sensor');
                uiwait(h)
            elseif isempty(strfind(diff{1:end}, '2a06:00d3'))
                h = warndlg({['Depth sensor detected in ' module_position ' module; however, RGB camera ID missing!'],...
                    'Please check module for damage and device is plugged in fully.',...
                    ['When ready click ''OK'' to retry. There are ' num2str(5-e) ' tries left.']},...
                    'Communications issue depth sensor');
                uiwait(h)
            else
                h = warndlg({['Unknown communications issue with ' module_position ' module!'],...
                    'Single device detected on Acroname USB Hub; however, device ID does not match RGB camera nor Depth Sensor!?',...
                    'Please check module for damage and device is plugged in fully.',...
                    ['When ready click ''OK'' to retry. There are ' num2str(5-e) ' tries left.']},...
                    'Communications issue unknown');
                uiwait(h)
            end
        else 
            h = warndlg({['Unknown communications issue with ' module_position ' module!'],...
                'More then 3 new devices detected on Acroname USB Hub!?',...
                'If a new device OTHER then module was just plugged into the computer, remove it.',...
                ['When ready click ''OK'' to retry. There are ' num2str(5-e) ' tries left.']},...
                'Communications issue unknown');
            uiwait(h)
        end % if size(diff, 1) == 0 
    end % if size(diff, 2) == 2
end % while 1
end % function