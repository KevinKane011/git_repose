function [status] = check_usb()

disp('check_usb start...')
tic

% Fancy multi bar (use labels and update all bars at once)
m = 8;
n = 5;
p = 5;
progressbar('Overall Progress','Check USB Communications with Module','Disabled All USB Ports') % Init 3 bars

list = '';

status_list = zeros(8,1);
[status_list(1), ~] = brainstem_switch(0, 'disable');
progressbar(0, 0, 1/m)
[status_list(2), ~] = brainstem_switch(1, 'disable');
progressbar(0, 0, 2/m)
[status_list(3), ~] = brainstem_switch(2, 'disable');
progressbar(0, 0, 3/m)
[status_list(4), ~] = brainstem_switch(3, 'disable');
progressbar(0, 0, 4/m)
[status_list(5), ~] = brainstem_switch(4, 'disable');
progressbar(0, 0, 5/m)
[status_list(6), ~] = brainstem_switch(5, 'disable');
progressbar(0, 0, 6/m)
[status_list(7), ~] = brainstem_switch(6, 'disable');
progressbar(0, 0, 7/m)
[status_list(8), ~] = brainstem_switch(7, 'disable');

if sum(status_list) ~= 0
    error(['Error with ''disabling'' port(s)']);
end % sum(status_list) ~= 0

[status_none, cmdout_none] = dos('lsusb');
if status_none ~= 0
    error(['Error with ''lsusb'' command: ' status_none]);
end % status ~= 0

none = strsplit(cmdout_none,'\n');

% check USB port #0 (top)
progressbar(1/p, 1/n, 8/m)
brainstem_switch(0, 'enable');
progressbar(1/p, 2/n, 8/m)
pause(1);
progressbar(1/p, 3/n, 8/m)
module_postion = 'top';
[status_0, list] = check_usb_error_handling(none, list, module_postion);
progressbar(1/p, 4/n, 8/m)
brainstem_switch(0,'disable');

% check USB port #2 (middle)
progressbar(2/p, 1/n, 8/m)
brainstem_switch(2, 'enable');
progressbar(2/p, 2/n, 8/m)
pause(1);
progressbar(2/p, 3/n, 8/m)
module_postion = 'middle';
[status_2, list] = check_usb_error_handling(none, list, module_postion);
progressbar(2/p, 4/n, 8/m)
brainstem_switch(2,'disable');

% check USB port #4 (bottom)
progressbar(3/p, 1/n, 8/m)
brainstem_switch(4, 'enable');
progressbar(3/p, 2/n, 8/m)
pause(1);
progressbar(3/p, 3/n, 8/m)
module_postion = 'bottom';
[status_4, list] = check_usb_error_handling(none, list, module_postion);
progressbar(3/p, 4/n, 8/m)
brainstem_switch(0,'disable');
progressbar(4/p, 5/n, 8/m)

brainstem_switch(4, 'disable');
progressbar(5/p, 5/n, 8/m)

% report results
if status_0==0 && status_2==0 && status_4==0
    status = 0;
else
    status = 1;
    h = errordlg({['There is an issue with module(s): ' list], 'Remove and replace module(s)!!!'},...
        'USB Communications Error');
    uiwait(h)
end % if status == 0 && status_0==0 && status_2==0 && status_4==0

disp('check_usb end...')
toc

end % function