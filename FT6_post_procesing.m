% dump Post processing here

% Empty input argument (factory use, mode = 1)
if nargin < 1
    disp('No mode input; default mode = 1 ''factory mode''');
    mode = 1;
elseif mode == 1
    disp('mode = 1; ''factory mode''');
elseif mode == 2
    disp('mode = 2; ''post processing mode''');   
    folder_name = uigetdir('C:\Orbbec_Factory_FT6', 'Select the folder with the ''FT6x'' data of iterrest.');
    if folder_name == 0
        error('Error: no ''FT6'' folder selected.');
    else
        cd(folder_name);
        serial_dir = dir();
        dir_size = length(serial_dir);
    end % if folder_name == 0
elseif mode == 3
    disp('mode = 3; ''test factory (w/ example frames) mode''');
else
    error('Error: non-valid mode selected. Only 1, 2 and 3 are options.');
end %if nargin ...



l = 0
           case 2 % post processing mode
                l = l+1;
                if l >= dir_size
                    go = false;
                end
                disp(['Item ' num2str(l) ' of ' num2str(dir_size)])
                serial = serial_dir(l).name;
                ignore_dir = {'.', '..', '17113010070','.DS_Store'}; % <-- hack to skip these dir
                if any(strcmp(serial, ignore_dir))
                    continue
                end

                %% Read Data from folder(s)!
                % note, there are three formats of stored depth data:
                %   (I) .raw images listed in a sub-folder(s)
                %   (II) Structured format with a cap.depth and .raw inside
                %   (III) .raw images listed in the main-folder
                if serial_dir(l).isdir   % (I)
                    cd(serial)
                    data_id = serial;
                    raw_files = dir('*.raw');
                    for m = 1:length(raw_files)
                        FID = fopen(raw_files(m).name);
                        depth_all(:,:,m) = transpose(fread(FID, [640, 480], 'uint16=>uint16'));
                        fclose(FID);
                    end
                    cd ..
                elseif serial(end-3:end) == '.mat'  % (II)
                    load(serial, 'cap')
                    data_id = serial(1:end-4);
                    serial = serial(18:28);
                    depth_all = cap.depth;
                elseif serial(end-3:end) == '.raw'  % (III) 
                    data_id = serial(1:end-4);
                    raw_files = dir('*.raw');
                    for m = 1:length(raw_files)
                        FID = fopen(raw_files(m).name);
                        depth_all(:,:,m) = transpose(fread(FID, [640, 480], 'uint16=>uint16'));
                        fclose(FID);
                    end
                else
                    continue
                end % if serial_dir(l).isdir
                
                
                
                
                                case 2
                    display_results(test_header, test_limits, test_results, top,...
                        'C:\Orbbec_factory_program_release\RGB.jpg', 'e', 2.0);
                    
                    
                    % Create a new folder (and .csv file) name
                filename_csv = [data_id '.csv'];
                % if there is a csv file naming conflict...
                if exist([folder_name '/' dir_name '/' filename_csv], 'file')
                    if mode == 1 || mode == 3
                        warndlg('Warning: Unit appears to have already been tested! An additional results file is being created.')
                        choice = 'No (create new file name)';
                    end

                    if mode == 2 
                        switch choice
                            case 'Yes (overwrite this and all future conflicts)'
                                continue
                            otherwise
                                choice = questdlg(['The file ' filename_csv ' already exists. Would you like to creat a new file name or overwrite?'],...
                                    'File naming conflict',...
                                    'No (create new filename)',...
                                    'Yes (overwrite only this one)',...
                                    'Yes (overwrite this and all future conflicts)',...
                                    'Yes (overwrite this and all future conflicts)');  
                        end % switch choice
                        switch choice
                            case 'Yes (overwrite only this one)'
                                delete(filename_csv);
                            case 'Yes (overwrite this and all future conflicts)'
                                delete(filename_csv);
                        end
                    end % mode == 2
                
                switch choice
                        case 'No (create new filename)'
                            csv_num = 2;
                            while exist([folder_name '/' dir_name '/' data_id '-' num2str(csv_num) '.csv'],'file')~= 0 && csv_num < 10000
                                csv_num = csv_num + 1;
                            end
                            if csv_num == 10000
                                error('Error: Unit appears to have been tested over 10000 times! No further files to be created!')
                            end
                            filename_csv = [data_id '-' num2str(csv_num) '.csv'];
                            choice = ''; % reset choice value
                    end % switch choice == 'No ....'
                
                
                