% Modified by Kevin and Koji, Dec 2016 - imx183 stuff
% Modified by Kevin, Jan 2017 - imx174 light_73 and light_74
% Modified by Kevin, Feb - fix imx174 distortion over saturation issue
% Modified by Kevin, March - using new function kek_read_config_file.m
% Modified by Kevin, March and April - Add light_75 to _81, provide two
% calibration types for Light (rb.csv)

function jprocess_check_limits()
clear
close('all')

disp('jprocess_check_limits.exe launched')

% Find sensor or product type
if exist('C:\latest_image\product_type.txt', 'file') == 0;
    sensor_type = 'missing';
    product = 'missing';
else
    product = fileread('C:\latest_image\product_type.txt');
end
disp(['Product: ', product])

switch product
    case 'a9imx174'
        filename = 'jprocess_params_imx174.mat';
        header = 'jprocess_params_imx174';
    case 'a9imx183'
        filename = 'jprocess_params_imx183.mat';
        header = 'jprocess_params_imx183';
    otherwise
        disp('Unsupported Sensor or Product Type');
        error('Unsupported Sensor or Product Type');
end
%disp(filename);
disp(['Test limits: ', header]);

% find most recent rev of file with 'filename_xxx'
if exist(filename, 'file') ~= 2
    filenames = dir(pwd);
    filenames = {filenames.name};
    for k = 3:size(filenames, 2)
        filename = char(filenames{k});
        if strcmpi(filename(end-2:end), 'mat')
            if strcmpi(filename(1:22), header)
                disp(['Loading test limits version: ', filename(24:26)])
                break;
            end
        end
    end
else
    disp('Loading default test limits version: 000')
end
load(filename);

%% resolve what filename (image type) is in the latest image file path
filenames = cell(System.IO.Directory.GetFiles(latest_image_pathname));  % jprocess_params.mat holds the latest_image_pathname variable
% filenames = {filenames.name};
filename = 'none';
testname = 'none';
for k = 1:size(filenames, 2)
    [~, filename, ext] = fileparts(char(filenames{k}));
    filename = [filename, ext];
    if strcmpi(filename(end-2:end), 'raw')
        n_tmp = find(filename == '_', 1, 'last');
        testname = filename(n_tmp+1:end-4);
        snts = filename(1:n_tmp-1);
        n_tmp = find(snts == '_', 1, 'last');
        sn = snts(n_tmp+1:end);
        disp(['Jaunt module serial number: ', sn])
        ts = snts(1:n_tmp-1);
        factory = sn(1);
        cfg = sn(9:10);
        rev = sn(11:12);
        disp(['Processing image: ', testname])
        if strcmpi(testname, 'dark') || strcmpi(testname, 'sfr1') ||...
                strcmpi(testname, 'sfr2') || strcmpi(testname, 'distortion') ||...
                strcmpi(testname, 'light') || strcmpi(testname, 'sfr3') ||...
                strcmpi(testname, 'pattern')
            break;
        end
    end
end

%% Read in the image
%[filename, sfr_pathname] = uigetfile('*.raw');
[img, img_y, img_gamma, img_bayer, fish_xyd, bayer_index] =...
    ese_read_image_file(latest_image_pathname, filename, 1);

%% Select the image processing based on the test type
try
    %% Pattern
    if strcmpi(testname, 'pattern')
        if strcmpi(sensor_type, 'imx174')
            [~, img_bayer, ~] =...
                ese_read_raw_bayer_image(fullfile(latest_image_pathname, filename), 0);
            [result, fig_pattern] = kek_imx174_chart_pattern(img_bayer);
        elseif strcmpi(sensor_type, 'imx183') % should never enter
            disp('entered pattern test on a9imx183, unexpected error');
            error('entered pattern test on a9imx183, unexpected error');
        else
            disp('Unsupported Sensor or Product Type');
            error('Unsupported Sensor or Product Type');
        end
        test_results = result;
        test_limits = pattern_limits;
        disp(test_limits);
        test_header = header(4+n_dark+n_focus+n_sfr1+n_sfr2+n_distortion+n_light+n_sfr3:...
            3+n_dark+n_focus+n_sfr1+n_sfr2+n_distortion+n_light+n_sfr3+n_pattern);
        fig_file = fullfile(latest_image_pathname, [filename(1:end-4), '_', filename(end-2:end), '.png']);
        saveas(fig_pattern, fig_file);
        csv_file = fullfile(latest_image_pathname, [filename(1:end-4), '_', filename(end-2:end), '.csv']);
        fid = fopen(csv_file, 'w');
        fprintf(fid, '%16.8f,', result);
        fclose(fid);
        
    %% Dark       
    elseif strcmpi(testname, 'dark')
        [row_fpn, col_fpn, pix_fpn, row_shd, col_shd,...
            ~, ~, ~, fig_image, fig_noises] = ese_chart_dark(img_bayer, 0);   % calls function ese_chart_dark
        structured_noise = sqrt(row_fpn^2+col_fpn^2);
        shading = sqrt(row_shd^2+col_shd^2);
        test_results = ese_db([...
            pix_fpn,...
            structured_noise,...
            shading,...
            row_fpn,...
            col_fpn,...
            row_shd,...
            col_shd]);
        test_limits = dark_limits;
        test_header = header(4:3+n_dark);
        close(fig_noises);
        fig_file = fullfile(latest_image_pathname, [filename(1:end-4), '_', filename(end-2:end), '.png']);
        saveas(fig_image, fig_file);
        csv_file = fullfile(latest_image_pathname, [filename(1:end-4), '_', filename(end-2:end), '.csv']);
        fid = fopen(csv_file, 'w');
        fprintf(fid, repmat('%16.8f,', 1, 7),...
            ese_db([...
            pix_fpn,...
            structured_noise,...
            shading,...
            row_fpn,...
            col_fpn,...
            row_shd,...
            col_shd]));
        fclose(fid);
    
    %% SFR1 and SFR2
    elseif strcmpi(testname, 'sfr1') || strcmpi(testname, 'sfr2') || strcmpi(testname, 'sfr')   % sfr is for old old files
        zoom_factor = 2*min([size(img, 1), size(img, 2)]./target_resolution);
        rot = -10; % in degrees. if negative remember to also change matrix.
        [sfrs, profiles, sqfs, oversharpenings, contrasts, ps, qs, rs, agls,...
            fig_alignment, fig_sfr, fig_field, fig_tilt] = ese_chart_sfr12(...
            img, img_y, patch_shrink, sfr_x_axis, edge_profile_x_axis, zoom_factor,... 
            bayer_index, rot, sensor_type);
        ix124 = interp1(sfr_x_axis, 1:size(sfr_x_axis, 2), [0.5, 0.25, 0.125]);
        sfr124 = [...
            sfrs(:, ix124(1)),...
            sfrs(:, ix124(2)),...
            sfrs(:, ix124(3))];
        sfrc1 = mean(sfr124([1,4,7,8,9,10,14,15], 1));
        sfrl1 = mean(sfr124([17,20:30], 1));
        sfrr1 = mean(sfr124([35:44,46,47], 1));
        sfrc2 = mean(sfr124([1,4,7,8,9,10,14,15], 2));
        sfrl2 = mean(sfr124([17,20:30], 2));
        sfrr2 = mean(sfr124([35:44,46, 47], 2));
        sfrc4 = mean(sfr124([1,4,7,8,9,10,14,15], 3));
        sfrl4 = mean(sfr124([17,20:30], 3));
        sfrr4 = mean(sfr124([35:44,46,47], 3));
        sfrtl2 = mean(sfr124([17,20], 2));
        sfrtr2 = mean(sfr124([35,36], 2));
        sfrbl2 = mean(sfr124([29,30], 2));
        sfrbr2 = mean(sfr124([46,47], 2));
        sfre1 = mean([sfrr1, sfrl1]);
        sfre2 = mean([sfrr2, sfrl2]);
        sfre4 = mean([sfrr4, sfrl4]);
        tilt_hor = (sfrtr2+sfrbr2-sfrtl2-sfrbl2)/(sfrtr2+sfrbr2+sfrtl2+sfrbl2)*100;
        tilt_ver = (sfrbl2+sfrbr2-sfrtl2-sfrtr2)/(sfrtr2+sfrbr2+sfrtl2+sfrbl2)*100;
        close(fig_sfr);
        close(fig_tilt);
        close(fig_field);
        test_results = [sfrc1, sfre1, sfrc2, sfre2, sfrc4, sfre4, tilt_hor, tilt_ver,...
            sfrtl2, sfrtr2, sfrbl2, sfrbr2];
        if strcmpi(testname, 'sfr1') || strcmpi(testname, 'sfr')
            test_limits = sfr1_limits;
            test_header = header(4+n_dark+n_focus:3+n_dark+n_focus+n_sfr1);
        else
            test_limits = sfr2_limits;
            test_header = header(4+n_dark+n_focus+n_sfr1:3+n_dark+n_focus+n_sfr1+n_sfr2);
        end
        fig_file = fullfile(latest_image_pathname, [filename(1:end-4), '_', filename(end-2:end), '.png']);
        saveas(fig_alignment, fig_file);
        csv_file = fullfile(latest_image_pathname, [filename(1:end-4), '_', filename(end-2:end), '.csv']);
        fid = fopen(csv_file, 'w');
        fprintf(fid, repmat('%16.8f,', 1, 12),...
            [sfrc1, sfre1, sfrc2, sfre2, sfrc4, sfre4, tilt_hor, tilt_ver,...
            sfrtl2, sfrtr2, sfrbl2, sfrbr2]);
        fclose(fid);
    
    %% Light
    elseif strcmpi(testname, 'light')
        gold = false;
        golden_light_data = kek_read_config_file('Golden Light:');
        day = datestr(now, 'mm/dd/yyyy');
        disp(strcat('Today is (', day, ')'));
        if strcmp(golden_light_data(1), sn)
            gold = true;
            disp(strcat('Color Calibration Sample [', golden_light_data(1), '] is being calibrated now.'))
        elseif strcmp(golden_light_data(3), cellstr(day))
            gold = false;
            disp(strcat('Color Calibration Sample [', golden_light_data(1), '] has been calibrated today.'))
        else
            gold = false;
            disp(strcat('Error: Color Calibration Sample [', golden_light_data(1), '] NOT calibrated today!'))
            error('Error: Color Calibration Sample NOT Calibrated today!');
        end

        [optical_center, shading_avg_r, shading_avg_colors, peaks, channel_means,...
            fig_center, fig_angle, fig_color, fig_average, fig_peaks, fig_blm] =...
            ese_chart_flat_light(img, mean(shading, 2));
        %shading_avg = mean(shading_avg_colors, 2);
        shading_avg_csv = [];
        ncsv = 9;
        for k = 1:4
            shading_avg_csv = [shading_avg_csv,...
                interp1(shading_avg_r, shading_avg_colors(:, k), linspace(0, 100, ncsv),...
                'linear', 'extrap')];
        end
        test_results = [2*optical_center, shading_avg_csv, reshape(peaks', 1, []), channel_means];
        test_limits = light_limits;
        test_header = header(4+n_dark+n_focus+n_sfr1+n_sfr2+n_distortion:...
            3+n_dark+n_focus+n_sfr1+n_sfr2+n_distortion+n_light);
        close(fig_center);
        close(fig_color);
        close(fig_average);
        close(fig_angle);
        close(fig_peaks);

        disp(latest_image_pathname);
        
        % solve for Light_73 and Light_74
        rb_img = channel_means([1, 3])/channel_means(2); % [r/g, b/g] image sensor (from light_69, 70, 71 data)
        light_73 = rb_img(1); % r/g DUT
        light_74 = rb_img(2); % b/g DUT 
        test_results = [test_results, light_73, light_74];
        
        % check for color calibration type required
        color_cal_type = kek_read_config_file('color cal type:');
        color_cal_type = color_cal_type(1);
        
        if strcmpi(color_cal_type, 'sensor')
            % make test results .csv (only with light_73 and light_74)
            csv_file = fullfile(latest_image_pathname, [filename(1:end-4), '_', filename(end-2:end), '.csv']);
            fid = fopen(csv_file, 'w');
            fprintf(fid, repmat('%16.8f,', 1, 2+size(shading_avg_csv, 2)),...
                [2*optical_center, shading_avg_csv, reshape(peaks', 1, []),...
                channel_means], light_73, light_74);
            fclose(fid);
        end
        
        if strcmpi(color_cal_type, 'sensor') || strcmpi(color_cal_type, 'both_sample') || strcmpi(color_cal_type, 'both_sensor')
            % Find the color.cvs file
            fig_file = fullfile(latest_image_pathname, [filename(1:end-4), '_', filename(end-2:end), '.png']);
            saveas(fig_blm, fig_file);
            color_file = fullfile(latest_image_pathname, [filename(1:end-10), '_', 'color.csv']);
            disp(color_file)
            if exist(color_file, 'file') == 0
                disp('Error: color.csv file missing');
                error('Error: color.csv file missing');
            end
            disp('Reading color.csv file');
            rgb = dlmread(color_file);
            
            % solve for rb.csv (sensor)
            rb_sensor = rgb([1, 3])/rgb(2); % [r/g, b/g] color sensor (from color.csv) 
            k1 = [0.6517, 0.6242];   % ~ A, B of golden samples constant
            k2 = rb_img./rb_sensor;
            rb_sensor = k1./k2;  % <--- this the NAND data for color calibration
            disp('Sensor Calculated RB:')
            disp(rb_sensor)
        end
        
        if strcmpi(color_cal_type, 'sample') || strcmpi(color_cal_type, 'both_sample') || strcmpi(color_cal_type, 'both_sensor')
            % read off data from golden_light sample
            disp('Reading Calibration Sample details');
            light_75 = str2double(cell2mat(golden_light_data(4)));  % red of golden
            light_76 = str2double(cell2mat(golden_light_data(5)));  % green1 of golden
            light_77 = str2double(cell2mat(golden_light_data(6)));  % blue of golden
            light_78 = str2double(cell2mat(golden_light_data(7)));  % green2 of golden
            light_79 = str2double(cell2mat(golden_light_data(8)));  % red / avg(green1, green2) of golden
            light_80 = str2double(cell2mat(golden_light_data(9)));  % blue / avg(green1, green2) of golden
            light_81 = golden_light_data(1);  % SN of the Golden (aka Sample)
            light_82 = golden_light_data(2);  % Mac address of golden
            light_83 = golden_light_data(3);  % Date of Golden Test
            
            test_results = [test_results, light_75, light_76, light_77,...
                light_78, light_79, light_80]; % light_81, light_82, light_83];
            disp(test_results)
            
            % make test results .csv (includes light_75 to light_80)
            csv_file = fullfile(latest_image_pathname, [filename(1:end-4), '_', filename(end-2:end), '.csv']);
            fid = fopen(csv_file, 'w');
            fprintf(fid, repmat('%16.8f,', 1, 2+size(shading_avg_csv, 2)),...
                [2*optical_center, shading_avg_csv, reshape(peaks', 1, []),...
                channel_means], light_73, light_74, light_75, light_76, light_77,...
                light_78, light_79, light_80);
            fclose(fid);
            
            % solve for rb.csv (sample)
            rb_sample = [light_79, light_80]; % [r/g, b/g] (from sample.csv) 
            %k1 = [1.0118, 0.9647];   % ~ A, B of golden samples constant
            k1 = [1,1];
            k2 = rb_img./rb_sample;
            rb_sample = [1,1]./(k1.*k2);
            %k3 = [0.0212, 0.0085];
            k3 = [0,0];
            rb_sample = rb_sample - k3; % <--- this the NAND data for color calibration
            disp('Sample Calculated RB:')
            disp(rb_sample);
            
            % save new measurements IF the device under test is the golden reference sample
            if gold
                [~,result] = dos('getmac');
                mac = result(160:176);
                day = datestr(now, 'mm/dd/yyyy');
                comma = {', '};
                space = {' '};
                % sample: 'Golden Light: X6044114C240, 00-0C-29-DA-05-74,...
                % ... 14-Mar-2017, 0.06892745, 0.17078224, 0.11250471,... 
                % ... 0.17075117, 0.4036351817, 0.6588211092'
                old_line = strcat('Golden Light:', space, golden_light_data(1),...
                    comma, golden_light_data(2), comma, golden_light_data(3),...
                    comma, golden_light_data(4), comma, golden_light_data(5),...
                    comma, golden_light_data(6), comma, golden_light_data(7),...
                    comma, golden_light_data(8), comma, golden_light_data(9));
                disp(old_line);
                new_line = strcat('Golden Light:',space, sn, comma, mac, comma, day,...
                    comma, num2str(test_results(69)), comma, num2str(test_results(70)),...
                    comma, num2str(test_results(71)), comma, num2str(test_results(72)),...
                    comma, num2str(test_results(73)), comma, num2str(test_results(74)));
                disp(new_line);
                % overwrite line in the config.txt file
                kek_modify_config_file(old_line, new_line);
            end
        end

        if strcmpi(color_cal_type, 'sensor') || strcmpi(color_cal_type, 'both_sensor')
            cal_rb = rb_sensor;
        elseif strcmpi(color_cal_type, 'sample') || strcmpi(color_cal_type, 'both_sample')
            cal_rb = rb_sample;
        else
            disp('Unsupported color calibration type');
            error('Unsupported color calibration type');
        end
            
        % make and save the results to new rb.csv file
        csv_file = fullfile(latest_image_pathname, 'rb.csv');
        n_tmp = find(filename == '_', 1, 'last');
        fs = filename(1:n_tmp-1);
        n_tmp = find(fs == '_', 1, 'first');
        if ~isempty(n_tmp)
            fs = fs(n_tmp+1:end);
        end
        fid = fopen(csv_file, 'w');
        fprintf(fid, '%s, ', fs);
        fprintf(fid, repmat('%16.8f, ', 1, 2), cal_rb);
        fclose(fid);
        disp('Write rb.csv file');
        
    %% SFR3
    elseif strcmpi(testname, 'sfr3')
        zoom_factor = 2*min([size(img, 1), size(img, 2)]./target_resolution);
        rot = -10; % in degrees. if negative remember to also change matrix.
        [sfrs, profiles, sqfs, oversharpenings, contrasts, ps, qs, rs, agls,...
            fig_alignment, fig_sfr, fig_field, fig_tilt] = ese_chart_sfr5(...
            img, img_y, patch_shrink, sfr_x_axis, edge_profile_x_axis,...
            zoom_factor, bayer_index, rot, sensor_type);
        ix124 = interp1(sfr_x_axis, 1:size(sfr_x_axis, 2), [0.5, 0.25, 0.125]);
        sfr124 = [...
            sfrs(:, ix124(1)),...
            sfrs(:, ix124(2)),...
            sfrs(:, ix124(3))];
        sfrc1 = mean(sfr124([9:12], 1));
        sfrl1 = mean(sfr124([1,4,13,14], 1));
        sfrr1 = mean(sfr124([7,8,18,19], 1));
        sfrc2 = mean(sfr124([9:12], 2));
        sfrl2 = mean(sfr124([1,4,13,14], 2));
        sfrr2 = mean(sfr124([7,8,18,19], 2));
        sfrc4 = mean(sfr124([9:12], 3));
        sfrl4 = mean(sfr124([1,4,13,14], 3));
        sfrr4 = mean(sfr124([7,8,18,19], 3));
        sfrtl2 = mean(sfr124([1,4], 2));
        sfrtr2 = mean(sfr124([7,8], 2));
        sfrbl2 = mean(sfr124([13,14], 2));
        sfrbr2 = mean(sfr124([18,19], 2));
        sfre1 = mean([sfrr1, sfrl1]);
        sfre2 = mean([sfrr2, sfrl2]);
        sfre4 = mean([sfrr4, sfrl4]);
        tilt_hor = (sfrtr2+sfrbr2-sfrtl2-sfrbl2)/(sfrtr2+sfrbr2+sfrtl2+sfrbl2)*100;
        tilt_ver = (sfrbl2+sfrbr2-sfrtl2-sfrtr2)/(sfrtr2+sfrbr2+sfrtl2+sfrbl2)*100;
        close(fig_sfr);
        close(fig_tilt);
        close(fig_field);
        test_results = [sfrc1, sfre1, sfrc2, sfre2, sfrc4, sfre4, tilt_hor, tilt_ver,...
            sfrtl2, sfrtr2, sfrbl2, sfrbr2];
        disp(test_results)
        test_limits = sfr3_limits;
        test_header = header(4+n_dark+n_focus+n_sfr1+n_sfr2+n_distortion+n_light:...
            3+n_dark+n_focus+n_sfr1+n_sfr2+n_distortion+n_light+n_sfr3);
        fig_file = fullfile(latest_image_pathname, [filename(1:end-4), '_', filename(end-2:end), '.png']);
        saveas(fig_alignment, fig_file);
        csv_file = fullfile(latest_image_pathname, [filename(1:end-4), '_', filename(end-2:end), '.csv']);
        fid = fopen(csv_file, 'w');
        fprintf(fid, repmat('%16.8f,', 1, 12),...
            [sfrc1, sfre1, sfrc2, sfre2, sfrc4, sfre4, tilt_hor, tilt_ver,...
            sfrtl2, sfrtr2, sfrbl2, sfrbr2]);   
        fclose(fid);
    
    %% Distortion
    elseif strcmpi(testname, 'distortion')
        wb_gains = [1.8, 1, 1.5];
        wb4 = [wb_gains, wb_gains(2)];
        img_bayer_wb = zeros(size(img, 1)*2, size(img, 2)*2);
        img3d_wb = zeros(size(img));
        for k = 1:4
            img3d_wb(:, :, k) = img(:, :, k)*wb4(k);
            img_bayer_wb(bayer_index(k, 1):2:end, bayer_index(k, 2):2:end) = img3d_wb(:, :, k);
        end
        img_vision = img_bayer_wb;
        if product == 'a9imx183'
            img_vision = 4*img_vision; % hack to deal with imx183 dark distortion image .RAW
        end
        fish_d0s = 2400:20:2600;
        [fish_xyd, phi, theta, mdl_err, hp, fig_model] =...
            ese_chart_checkers_ftheta(img_vision, 0, sensor_type);
        test_results = [fish_xyd, phi, theta, mdl_err];
        test_limits = distortion_limits;
        test_header = header(4+n_dark+n_focus+n_sfr1+n_sfr2:...
            3+n_dark+n_focus+n_sfr1+n_sfr2+n_distortion);
        
        n_tmp = find(filename == '_', 1, 'last');
        fs = filename(1:n_tmp-1);
        n_tmp = find(fs == '_', 1, 'first');
        if ~isempty(n_tmp)
            fs = fs(n_tmp+1:end);
        end
        
        fig_file = fullfile(latest_image_pathname, [filename(1:end-4), '_', filename(end-2:end), '.png']);
        saveas(fig_model, fig_file);
        csv_file = fullfile(latest_image_pathname, 'xyd.csv');
        fid = fopen(csv_file, 'w');
        fprintf(fid, '%s, ', sn);
        fprintf(fid, repmat('%16.8f, ', 1, 3), fish_xyd);
        fclose(fid);
        csv_file = fullfile(latest_image_pathname, [filename(1:end-4), '_', filename(end-2:end), '.csv']);
        fid = fopen(csv_file, 'w');
        fprintf(fid, repmat('%16.8f,', 1, 5), [fish_xyd, phi, theta, mdl_err]);
        fclose(fid);
    end 
    codefail = 0;
    disp('Image processing completed')

% Check for an error during Image Processing
catch
    disp('Image processing failed to complete')
    codefail=1;
    gw = 640;
    gh = 640;
    gri = 0.5*ones(gh, gw);
    fig = figure();
    imshow(gri);
    title(['timestamp: ', ts, '     SN: ', sn]);
    hold on;
    if gold == false;
        text(gw/10+0*gw/6, 1/(1+1)*gh, 'Error: Color Calibration Sample not Calibrated today!', 'Color', 'r');
    else
        text(gw/10+0*gw/6, 1/(1+1)*gh, 'BAD IMAGE: Image processing failed.', 'Color', 'r');
    end
    hold off;
end

% No error during Image Processing
if codefail == 0
    disp('Storing results to cloud')
    !uploader
    disp('Results stored to cloud')
    
    %% Display pass/fail results to user
    % Format Light test results if needed
    if strcmpi(testname, 'light')
        test_results = test_results(1:74);
    end

    disp('Displaying test results')
    gw = 640;
    gh = 640;
    gri = 0.5*ones(gh, gw);
    fig = figure();
    imshow(gri);
    title(['timestamp: ', ts, '     SN: ', sn]);
    hold on;
    np = size(test_results, 2);
    for k = 1:np
        ll = test_limits(k, 1);
        hl = test_limits(k, 2);
        cv = test_results(k);
        ps = 'pass';
        hk = char(test_header(k));
        ix = find(hk == '_', 1, 'first');
        hk = [hk(1:ix-1), '\', hk(ix:end)];
        pc = 'g';
        if ll > cv || cv > hl
            ps = 'fail';
            pc = 'r';
        end
        text(gw/10+0*gw/6, k/(np+1)*gh, hk, 'Color', pc);
        text(gw/12+1*gw/6, k/(np+1)*gh, num2str(cv), 'Color', pc);
        text(gw/12+2*gw/6, k/(np+1)*gh, num2str(ll), 'Color', pc);
        text(gw/12+3*gw/6, k/(np+1)*gh, num2str(hl), 'Color', pc);
        text(gw/12+4*gw/6, k/(np+1)*gh, num2str(ps), 'Color', pc);
    end
    hold off; 
end
end