function Matterport_FT6_Orbbec_Factory(mode)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Matterport_FT6_Orbbec_Factory_2v0
%
% Kevin Kane & Laura Boon
% Matterport
% Nov 2017 - March 2018
% Discription: Factory Depth Image Quality Check (FT6)
%   code can be used either during capture of data at the factory 
%   (mode = 1, defualt) or testing Factory mode (mode = 2).
%
% Note: Matterport Confidential Material
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ************ Start of Main Program:

%% Clean up
close all

%% Setup mode 1 or 2
% Empty input argument (factory use, mode = 1)
if nargin < 1
    disp('No mode input; default mode = 1 ''factory mode''');
    mode = 1;
elseif mode == 1
    disp('mode = 1; ''factory mode''');
elseif mode == 2
    disp('mode = 2; ''test factory (w/ example frames) mode''');
else
    error('Error: non-valid mode selected. Only 1, 2 or empty are options.');
end %if nargin ...

try % Begin try
    
    %% Commandline strings set
    [capture_depth_command, capture_RGB_command_A, capture_RGB_command_B,...
        capture_RGB_command, get_RGB_serial_command] = set_command_line_str();

    %% Select TestType 'FT6A', 'FT6B', 'FT6A + RGB', 'FT6B + RGB',
    % pepare promt strings
    pro_A = '';
    pro_B = '';
    if 0 == isempty(capture_RGB_command_A)
        pro_A = ' + RGB';
    end
    if 0 == isempty(capture_RGB_command_B)
        pro_B = ' + RGB';
    end

    % promt operator
    TestType = questdlg('Select Test Type', 'Selection Menu',...
        ['FT6A (650mm)' pro_A], ['FT6B (5000mm)' pro_B], 'FT6A (650mm)');
    disp(['Test Type: ' TestType ' Selected.'])
    % set testing conditions
    switch TestType
        case 'FT6A (650mm)'
            TestType = 'FT6A';
            distance = 650;
            RGB = false;
        case 'FT6B (5000mm)'
            TestType = 'FT6B';
            distance = 5000;
            RGB = false;
        case 'FT6A (650mm) + RGB'
            TestType = 'FT6A';
            distance = 650;
            RGB = true;
        case 'FT6B (5000mm) + RGB'
            TestType = 'FT6B';
            distance = 5000;
            RGB = true;
        otherwise
            error('Error: no valid test type selction was made')
    end % switch TestType

    %% Begin Testing Arrays
    while 1  % array level while loop

        %% Move Stepper motor and switch USB ports to 'home'
        module_position = 'home';
        move_2_module_position(module_position, 5)
        
        %% Operator Enter/Scan Array SN
        while 1 
            array_SN = inputdlg('Enter or Scan Array SN', 'Array SN Entry', 1, {'YYYYMMDD-XXX'});
            if isempty(array_SN)  
                continue
            end
            array_SN = array_SN{1};
            if (size(array_SN,2) == 12) && (array_SN(9) == '-')
                break;
            end
        end % while 1
        disp(['Array SN: ' array_SN])
        
        %% Instruct Operator to load in Array and to plug in ALL modules
        usbicon = imread('C:\Orbbec_factory_program_release\USB.jpg');
        m = msgbox({'Load the new Array into the fixture and plug in',...
            'the three USB connections into the correct locations',...
            'When done click the ''OK'' button.'}, 'USB Plug-in Screen', 'custom', usbicon);
        uiwait(m)

        %% Check the six USB devices are found
        if check_usb()
            break % break from array level while loop
        end % if check_usb()

        %% Create new folder if needed
        folder_name = ['C:\Orbbec_Factory_FT6\' TestType '\' date];
        if exist(folder_name, 'dir') == 0
            mkdir(folder_name);
        end
        cd(folder_name)
        
        % create pass/fail buffer for tracking results in the array
        array_buffer = [-1,-1,-1;-1,-1,-1]; % -1 = unclear, 0 = fail, 1 = pass
        
        %% Begin Testing Modules
        while 1  % module level while loop         
            %% Setup USB and move motor to correct position
            module_position = next_module_position(module_position);
            move_2_module_position(module_position, 5);
            
            %% Pull SN from RGB camera
            [RGB_SN, ~] = pull_RGB_serial(get_RGB_serial_command);
            
            switch mode
                case 1 
                    %% Factory mode
                    % capture frames with depth camera! 
                    capture_depth_command = strrep(capture_depth_command,'(*distance*)', num2str(distance));
                    capture_depth_command = strrep(capture_depth_command,'(*TestType*)', TestType);
                    d = dialog('Position', [300 300 280 150], 'Name', 'My Dialog');
                    uicontrol('Parent', d, 'Style', 'text', 'Position',[20 80 210 40],...
                        'String',['The ' module_position ' module is warming... please wait']);
                    eval(['[status, cmdout] = dos(''' capture_depth_command ''');']);
                    close(d)
                    
                    % read depth data
                    dir_name = dir('Orbbec_*');
                    cd(dir_name(1).name); % goes to the latest directory
                    file_name = dir('cap_Orbbec_Astra*');
                    load(file_name);
                    data_id = cap.filename;
                    depth_all = cap.depth;
                    serial = cap.serial;
                    cd ..

                case 2 
                    %% Test (w/ example frames) mode
                    [file_name, PathName] = uigetfile('*.mat', 'Select the example .mat used for ''testing factory mode''.', 'C:\Orbbec_Factory_FT6');
                    %dir_name = PathName(1:end-1);
                    %[~, dir_name] = fileparts(dir_name);
                    load([PathName file_name]); 
                    data_id = cap.filename;
                    depth_all = cap.depth;
                    serial = cap.serial;
                otherwise
                    error('ERROR: How could you get here?');
            end % switch mode

            %% Format 'depth_all' data
            depth_all = double(depth_all);
            depth_all(depth_all == 0) = nan;
            [v_res, h_res, ~] = size(depth_all);
            if distance == 5000 % images cropped due to wall size
                h_pix = 0.1*h_res:0.9*h_res;
                v_pix = 0.25*v_res:0.57*v_res;
            elseif distance == 650 % images not cropped
                h_pix = 1:h_res;
                v_pix = 1:v_res;
            else
                error('ERROR: How could you get here??');
            end % distance == 5000
            
            %% Run Tests
            % Test Name Header
            test_header = {'Flatness'; 'Accuracy'; 'Spray'; 'Tilt'; 'Coverage'; 'ZeroCount'}; 

            % Flatness Test
            [flatness_result, flatness_max_limit, flatness_min_limit] = flatness(depth_all, v_pix, h_pix, distance);
            test_limits(1, 1) = flatness_min_limit;
            test_limits(1, 2) = flatness_max_limit;
            test_results(1) = flatness_result;

            % Accuracy Test
            [accuracy_result, accuracy_max_limit, accuracy_min_limit] = accuracy(depth_all, v_pix, h_pix, distance);   
            test_limits(2, 1) = accuracy_min_limit;
            test_limits(2, 2) = accuracy_max_limit;
            test_results(2) = accuracy_result;

            % Spray Test
            [spray_result, spray_max_limit, spray_min_limit, spray_high, spray_low] = spray(depth_all, v_pix, h_pix, distance);
            test_limits(3, 1) = spray_min_limit;
            test_limits(3, 2) = spray_max_limit;
            test_results(3) = spray_result;

            % Tilt Test
            [tilt_result, tilt_max_limit, tilt_min_limit] = tilt(depth_all, v_pix, h_pix, distance, spray_high, spray_low);
            test_limits(4, 1) = tilt_min_limit;
            test_limits(4, 2) = tilt_max_limit;
            test_results(4) = tilt_result;

            % Coverage Test
            [coverage_result, coverage_max_limit, coverage_min_limit] = coverage_L(depth_all, v_pix, h_pix, distance);       
            test_limits(5, 1) = coverage_min_limit;
            test_limits(5, 2) = coverage_max_limit;
            test_results(5) = coverage_result;

            % ZeroCount Test
            [zerocount_result, zerocount_max_limit, zerocount_min_limit] = zerocount(depth_all, v_pix, h_pix, distance);   
            test_limits(6, 1) = zerocount_min_limit;
            test_limits(6, 2) = zerocount_max_limit;
            test_results(6) = zerocount_result;

            disp('Image(s) process completed with no errors!')

            %% Depth Data management
            disp('Storing processed results...')
            str_distance = num2str(distance);
            timestamp = replace(cap.timestamp, ' ', '_');
            t1 = cap.temp_trigger_first_sample_temp;
            t2 = cap.temp_trigger_last_sample_temp;
            wait = cap.temp_trigger_first_to_last_ms;
            
            %% Display Depth Sensor pass/fail results to user
            fig_title = ['Module_SN: ' serial '    Date_Time: ' timestamp...
                '    Distance: ' str_distance 'mm' '    Position: ' module_position];
            eval(['[fig_d_' module_position ', all_result] = display_results(test_header, test_limits, test_results, fig_title,'...
                '''C:\Orbbec_factory_program_release\Depth.jpg'', ''c'');']);
                    
            array_buffer = update_array_buffer(array_buffer, module_position, 'Depth', all_result);

            %% Save results to new .csv file
            filename_csv = [data_id(1:end-4) '.csv'];
            FID = fopen(filename_csv,'a');
            % write the headers (identify module)
            header_csv = {'Module_SN', 'Pass/Fail', 'Image_Id', 'Position', 'RGB_SN', 'Array_SN',...
                'Date_Time', 'Distance', 'window_first_temp', 'window_last_temp', 'window_time_ms'};
            fprintf(FID,'%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s', header_csv{1,:});
            % write the headers (tests)
            fprintf(FID,'%s, %s, %s, %s, %s, %s',test_header{:,1});
            % write the headers (test limits)
            limits_header = {'flatness_min_limit', 'flatness_max_limit', 'accuracy_min_limit', 'accuracy_max_limit', 'spray_min_limit', 'spray_max_limit',...
                'tilt_min_limit', 'tilt_max_limit', 'coverage_min_limit', 'coverage_max_limit', 'zerocount_min_limit', 'coverage_max_limit'};
            fprintf(FID,'%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s\n', limits_header{:,1});
            
            % write results
            values_csv = {serial, all_result, data_id, module_position, RGB_SN, array_SN, timestamp, str_distance, t1, t2, wait};
            fprintf(FID,'%s, %f, %s, %s, %s, %s, %s, %s, %f, %f, %f', values_csv{1,:});
            fprintf(FID,'%f, %f, %f, %f, %f, %f', test_results);
            values_limits = {flatness_min_limit, flatness_max_limit, accuracy_min_limit, accuracy_max_limit, spray_min_limit, spray_max_limit,...
                tilt_min_limit, tilt_max_limit, coverage_min_limit, coverage_max_limit, zerocount_min_limit, coverage_max_limit};
            fprintf(FID,'%f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f', values_limits{1,:});
            fclose(FID);

            %% Append results to Master.csv file
            master_csv = 'C:\Orbbec_Factory_FT6\FT6_Master_CSV.csv';
            if exist(master_csv, 'file')
                FID = fopen(master_csv,'a');
                fprintf(FID,'%s, %s, %s, %s, %s, %s, %s, %s, %s, %s', values_csv{1,:});
                fprintf(FID,'%f, %f, %f, %f, %f, %f', test_results);
                fclose(FID);
            else
                copyfile(filename_csv, master_csv);
            end % if exist(master_csv, 'file')
            disp('Depth results data storage completed with no errors')
            
            %% Reduce .mat file size by trimming duplicate IR image data
            preview_image_flat = cap.preview_image(:,:,1);
%             i = imshow(preview_image_flat);
%             wait(1.5);
%             close(i);
            cap.preview_image = preview_image_flat;
            save(cap.filename,'cap','-mat')

            %% Arrange Depth figure(s) or wait for them to close?
            switch module_position
                case 'top'
%               	movegui(fig_d_top,[x y h w])
%               	waitfor(fig_rgb_top);
                case 'middle'
%               	movegui(fig_d_middle,[x y h w])
%               	waitfor(fig_d_middle);
                case 'bottom'
%               	movegui(fig_d_bottom,[x y h w])
%               	waitfor(fig_d_bottom);
                otherwise
            end % switch module_position

            if RGB == false
                array_buffer = update_array_buffer(array_buffer, module_position, 'RGB', 1);
            else
                %% RGB Image capture and 'Alive' Test
                [RGB_test_results, RGB_timestamp] = RGB_I_am_alive(capture_RGB_command);

                %% Display RGB camera pass/fail results to user
                fig_title = ['RGB_serial: ' RGB_SN '    Date_time: ' RGB_timestamp '    RGB "Alive" Test'];
                test_header = {'Alive'};
                test_limits = [1,1];
                eval(['fig_rgb_' module_position ', all_result] = display_results(test_header, test_limits, test_results, fig_title,'...
                    '''C:\Orbbec_factory_program_release\Depth.jpg'', ''c'');']);
                array_buffer = update_array_buffer(array_buffer, module_position, 'RGB', all_result);

                %% RGB Data management
                % Save RGB results to new .csv file
                RGB_filename_csv = ['RGB_', RGB_SN, '.csv'];
                FID = fopen(RGB_filename_csv,'a');
                RGB_header_csv = {'RGB_SN', 'Date_Time', 'Module_SN', 'Array_SN', 'Station', 'Mode_Loc' ,'Alive'};
                fprintf(FID,'%s, %s, %s, %s, %s, %s, %s',RGB_header_csv{1,:});
                values_csv = {RGB_SN, RGB_timestamp, serial, array_SN, TestType, module_position, RGB_test_results};
                fprintf(FID,'%s, %s, %s, %s, %s, %f',values_csv{1,:});
                fclose(FID);

                %% Append results to RGB_Master.csv file
                RGB_master_csv = 'C:\Orbbec_Factory_FT6\FT6_RGB_Master_CSV.csv';
                if exist(RGB_master_csv, 2)
                    FID = fopen(master_csv,'a');
                    fprintf(FID,'%s, %s, %s, %s, %s, %f',values_csv{1,:});
                    fclose(FID);
                else
                    copyfile(RGB_filename_csv, RGB_master_csv);
                end % if exist(master_csv)
                disp('RGB results data storage completed with no errors')
                
                %% Arrange RGB figure(s) or wait for them to close?
                switch module_position
                    case 'top'
%                    	movegui(fig_rgb_top,[x y h w])
%                       waitfor(fig_rgb_top);
                    case 'middle'
%                       movegui(fig_rgb_middle,[x y h w])
%                       waitfor(fig_rgb_middle);
                    case 'bottom'
%                       movegui(fig_rgb_bottom,[x y h w])
%                       waitfor(fig_rgb_bottom);
                    otherwise
                end % switch module_position
                
            end % if RGB == false

            %% Last module of array?
            if strcmp(module_position, 'bottom')
                break
            end % if strcmp(module, 'bottom')
            
        end % while 1  -  module level while loop
        
        %% End of Array
        % Display Array level results and Promt Operator to test another Array
        if sum(array_buffer) == 6
            array_str = ['Array ' array_SN ' Passed all tests!'];
        else 
            array_str = ['Array ' array_SN ' Failed some tests!'];
        end
        disp(array_str)
        
        choice = questdlg({array_str, 'Press ''Another'' to test another Array.'},...
            'Action Menu', 'Another', 'Quit', 'Another');
        if strcmp(choice, 'Another')
        else
            break % array level while loop
        end % if
    end % while 1  -  array level while loop
    
    % Move Stepper motor and switch USB ports to 'home'
    module_position = 'home';
    move_2_module_position(module_position, 5)

%% Catch Errors
catch ME
    e = errordlg({['Error ID: ' ME.identifier ME.message], '',...
        ['Error Message: ' ME.message], '', 'Closing Program!'}, 'Program Error');
    uiwait(e);
    
    % Move stepper motor and switch USB ports to 'home'
    module_position = 'home';
    move_2_module_position(module_position, 5)   
    close all
    fclose('all');
    rethrow(ME);
end % try
end % function
