function [] = move_2_module_position(module_position, sec)

%% move_2_module_position

% Display Image Capture Trigger count down
if sec > 0
    line1 = 'ATTENTION!!!!';
    line2 = 'Motor will move to next position';
    line3 = ['automatically in ' num2str(sec) ' seconds!'];
    line4 = '';
    line5 = 'KEEP HANDS CLEAR!';
    h = warndlg({line1, line2, line3, line4, line5}, 'Automated Testing Trigger');
    for c = 1:sec
        line3 = ['testing automatically in ' num2str(sec-c) ' seconds!'];
        pause(1)
        close(h)
        h = warndlg({line1, line2, line3, line4, line5}, 'Automated Testing Trigger');
    end % for c = 1:sec
    close(h)
end % if sec > 0

% move motor and switch USB connection
switch module_position
	case 'home'
        % MOVE STEPPER MOTER TO POSITION "home" HERE!  
        % [status, cmdout] = dos('C:\Orbbec_factory_program_release\Orbbec.dll -home');
        brainstem_switch(0, 'disable');
        pause(1)
        brainstem_switch(2, 'disable');
        pause(1);
        brainstem_switch(4, 'disable');
    case 'top'
        % MOVE STEPPER MOTER TO POSITION "top" HERE!
        % [status, cmdout] = dos('C:\Orbbec_factory_program_release\Orbbec.dll -top2wall');
        brainstem_switch(2, 'disable');
        pause(1)
        brainstem_switch(4, 'disable');
        pause(1);
        brainstem_switch(0, 'enable');
    case 'middle'
        % MOVE STEPPER MOTER TO POSITION "middle" HERE!
        % [status, cmdout] = dos('C:\Orbbec_factory_program_release\Orbbec.dll -mid2wall');
        brainstem_switch(0, 'disable');
        pause(1)
        brainstem_switch(4, 'disable');
        pause(1);
        brainstem_switch(2, 'enable');
    case 'bottom'
        % MOVE STEPPER MOTER TO POSITION "bottom" HERE!  
        % [status, cmdout] = dos('C:\Orbbec_factory_program_release\Orbbec.dll -bot2wall);
        brainstem_switch(0, 'disable');
        pause(1)
        brainstem_switch(2, 'disable');
        pause(1);
        brainstem_switch(4, 'enable');
    otherwise
        error('Error: confused about motor location and module sequence!')
end % switch module_position

end % function