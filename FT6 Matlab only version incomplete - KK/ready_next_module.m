function [module] = ready_next_module(module)

%% ready_next_module

% Display Image Capture Trigger
myicon = imread('C:\Orbbec_factory_program_release\USB.jpg');
line1 = ['Click ''OK'' when ' module ' module is plugged in and ready.'];
line2 = 'Motor will move to next position and start testing automaticly!';
line3 = '';
line4 = 'KEEP HANDS CLEAR!';
h = msgbox({line1, line2, line3, line4}, 'Image Capture Trigger', 'custom', myicon);
%htext = findobj(h, 'Type', 'Text');  %find text control in dialog
%htext.FontSize = 10;  %set fontsize to whatever you want
uiwait(h)

switch module
    case 'NA'
        module = 'top';
        % MOVE STEPPER MOTER TO POSITION "top" HERE!
        % !C:\Orbbec_factory_program_release\Orbbec_control.exe -top2wall
        % SWITCH USB TO TOP MODULE HERE!
    case 'top'
        module = 'middle';
        % MOVE STEPPER MOTER TO POSITION "middle" HERE!
        %!C:\Orbbec_factory_program_release\Orbbec_control.exe -mid2wall
        % SWITCH USB TO middel MODULE HERE!
    case 'middle'
        module = 'bottom';
        % MOVE STEPPER MOTER TO POSITION "bottom" HERE!  
        %!C:\Orbbec_factory_program_release\Orbbec_control.exe -bot2wall
        % SWITCH USB TO bottom MODULE HERE!
    otherwise
        error('Error: confused about motor location and module sequence!')
end % switch module