function [RGB_SN, status] = pull_RGB_serial(get_RGB_serial_command)

e=0;
while 1
    [status, cmdout] = dos(get_RGB_serial_command);
    if status == 0 % no error
        RGB_SN = strtrim(cmdout);
        if size(RGB_SN,2) == 12
            status = 0;
            break
        elseif size(RGB_SN,2) == 0 && e < 10
            e=e+1;
            pause(0.25)
            continue
        else
            h = questdlg({['RGB camera S/N: ' RGB_SN ' does not meet normal format!'],...
                'To try and pull the serial number automaticly again, click ''RETRY''.',...
                'Or to use the RGB camera S/N as is, click ''ACCEPT''.'},...
                'Invalid RGB SN Warning', 'RETRY', 'ACCEPT', 'RETRY');
            switch h
                case 'RETRY'
                    continue
                case 'ACCEPT'
                    val_SN = true;
                    status = 2;
                otherwise
                    status = -1;
                    error('''Invalid RGB SN Warning'' dialog box exited')
            end
        end
    else
        h = questdlg({'Could not pull the RGB camera S/N name from the device!',...
            'Check the module is plugged in and click ''RETRY'' to try again.',...
            'Or click the ''END'' to ERROR out of the program.'},...
            'RGB SN Warning', 'RETRY', 'END', 'RETRY');
        switch h
            case 'RETRY'
                continue
            case 'END'
                status = -2;
                error('Could not read the RGB serial number! Selected END program!')
            otherwise
                status = -3;
                error('''RGB SN Warning'' dialog box exited')
        end
    end
end