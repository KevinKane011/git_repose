function [status, cmdout, count] = brainstem_switch(port, state)

port = num2str(port);
count = 0;
while 1
    [status, cmdout] = dos(['C:\Python27\python.exe C:\Orbbec_factory_program_release\brainstem_tryout.py -p ' port ' --' state]);
    if status == 0
        break
    else
        count = count +1;
        if strcmp(cmdout(1:end-1), 'Error: Could not connect to device(3)') && status == 1
            h = warndlg({'Could not connect to Acroname USB Hub!',...
                'Please check that device is plugged into',...
                'the computer and powered on.',...
                'When ready click ''OK'' to retry'},...
                'Communications issue with Acroname USB Hub');
            uiwait(h)
        elseif count == 10
%             error(['Could not switch USB port: ' cmdout]);
            break
        end % if strcmp(cmdout(1:end-1),...
    end % if status == 0
end % while 1
end % function