classdef VDC

    properties
        
    start_depth = 0;             % optional single, defaults to single(0.5).
    depth_step = 0;              % optional single, defaults to single(0.5).
    shift_per_gmc_slope = 0;     % optional single, defaults to single(0).
    starting_gmc_slope = 0;      % optional single, defaults to single(0).
    correction_image_pngs = [];  % repeated uint8 vector, defaults to uint8([]).
    sensor_serial_number = '';   % optional string, defaults to ''.
    sensor_position = '';        % optional string, defaults to ''.
    camera_serial_number = '';   % optional string, defaults to ''.
    individual_sensor_calibration_time = ''; % optional string, defaults to ''.
    camera_in_situ_calibration_time = '';    % optional string, defaults to ''.
    vdc_creation_time = '';      % optional string, defaults to ''.
    vdc_creation_version = '';   % optional string, defaults to ''.
    
    default_target_vector = 0.5:0.5:10;
    target_vector = [];
    target_count = [];
    
    correction_factor_stack = [];

    end
    
    properties (Hidden, Constant)
        calrecords = '\\diskstation/CalRecords';
        calgen = '\\diskstation/CalGen';
    end
    
    methods
        function obj = VDC(true_depth_stack, observed_depth_stack, observed_depth_vector, do_use_shift, baseline)
            if nargin
                default('do_use_shift',true);
                default('observed_depth_vector',obj.default_target_vector);
                default('baseline',0);
                if ischar(true_depth_stack) || nargin < 2
                    obj = obj.load(true_depth_stack); % char VDC name
                else
                    obj = obj.calculate_stack(true_depth_stack, observed_depth_stack, observed_depth_vector, do_use_shift, baseline);
                end
            end
        end
        
        function obj = set.start_depth(obj,x)
            obj.start_depth = single(x);
        end
        
        function obj = set.depth_step(obj,x)
            obj.depth_step = single(x);
        end
        
        function obj = set.shift_per_gmc_slope(obj,x)
            obj.shift_per_gmc_slope = single(x);
        end
        
        function obj = set.starting_gmc_slope(obj,x)
            obj.starting_gmc_slope = single(x);
        end

        function obj = calculate_stack(obj, true_depth_stack, observed_depth_stack, observed_depth_vector, do_use_shift, baseline)
            default('do_use_shift',true)
            default('observed_depth_vector',obj.default_target_vector);
            default('baseline',0)

            % 	// The "final_voxels" format is a set of correction factors from observed depth to true depth.
            % 	// e.g. if the observed depth is 2m and the correction factor is 1.05, the true depth is 2.1m.
            % 	//
            % 	// The final voxels are computed at even steps of observed depth, interpolated from the raw
            % 	// calibration measurements.

            % function [] = write_vdc( serial, observed_depth_vector, true_depth_stack, observed_depth_stack, ...
            %     shift_per_gmc_slope, starting_gmc_slope)
            % [] = write_vdc(serial, observed_depth_vector, true_depth_stack, observed_depth_stack)

            % if ~all(diff(observed_depth_vector) == min(diff(observed_depth_vector)))
            %     error('observed depth target vector must be at even intervals');
            % end


            obj.target_count = numel(observed_depth_vector);
            obj.target_vector = observed_depth_vector;

            if nanmean(observed_depth_vector(:)) < 100
                observed_depth_vector = observed_depth_vector .* 1000;
            end
            if nanmean(true_depth_stack(:)) < 100
                true_depth_stack = true_depth_stack .* 1000;
            end
            if nanmean(observed_depth_stack(:)) < 100
                observed_depth_stack = observed_depth_stack .* 1000;
            end

            vres = size(true_depth_stack,1);
            hres = size(true_depth_stack,2);
            image_count = size(true_depth_stack,3);
            obj.target_count = numel(observed_depth_vector);

            if image_count == 1
                vres = size(observed_depth_stack,1);
                hres = size(observed_depth_stack,2);
                [~,~,true_depth_stack]  = meshgrid(1:hres,1:vres,true_depth_stack);
            end

            % remove zeros so they don't get interpolated in
            observed_depth_stack(observed_depth_stack < 10) = NaN;
            true_depth_stack(true_depth_stack < 10) = NaN;
            
            [xi,yi,observed_depth_stack_even] = meshgrid(1:hres,1:vres,observed_depth_vector);
            
%% method 1: full linear interpolation with scattered (does odd things at borders)
% 
%             [xg,yg,~] = meshgrid(1:hres,1:vres,1:image_count);
%             idx = ~isnan(observed_depth_stack) & ~isnan(true_depth_stack);
%             F = scatteredInterpolant(xg(idx),yg(idx),observed_depth_stack(idx),true_depth_stack(idx),'linear','none');
%             
%             
%             [xi,yi,~] = meshgrid(1:hres,1:vres,1:obj.target_count);
%             true_depth_stack_even = F(xi, yi, observed_depth_stack_even);
%             
%             F_lin = scatteredInterpolant(xg(idx),yg(idx),observed_depth_stack(idx),true_depth_stack(idx),'linear','linear');
%             
%             true_depth_stack_lin = F_lin(xi, yi, observed_depth_stack_even);
%             
%             
%             % locations of areas to fill in because they were NaN -- only do this for "near" data
%             idx_infill_near = isnan(true_depth_stack_even) & true_depth_stack_even < 3500;
%             true_depth_stack_even(idx_infill_near) = true_depth_stack_lin(idx_infill_near);

%% strip interpolation

            % perform a gridwise "strip" interpolation independently at each 2D voxel location
            
            % first, do straight up interp1, with no extrapolation, filling in with NaN
            naninterp1 = @(x,y,xi) interp1(x(~isnan(x)&~isnan(y)), y(~isnan(x)&~isnan(y)), xi, 'pchip', NaN);
            true_depth_stack_even = gridfun(naninterp1, observed_depth_stack, true_depth_stack, observed_depth_stack_even);

            % repeat the whole stack with linear extrapolation
            naninterp1 = @(x,y,xi) interp1(x(~isnan(x)&~isnan(y)), y(~isnan(x)&~isnan(y)), xi, 'linear', 'extrap');
            true_depth_stack_extrap = gridfun(naninterp1, observed_depth_stack, true_depth_stack, observed_depth_stack_even);

            % from the above, take out entire strips if there were too few parts
            idx_incomplete = repmat(sum(isnan(observed_depth_stack),3) > 4,[1 1 obj.target_count]);
            true_depth_stack_extrap(idx_incomplete) = NaN; 

            % use the scatteredInterpolant to lean on surrounding data to fill those in
            idx = ~isnan(observed_depth_stack_even) & ~isnan(true_depth_stack_extrap);
            F_extrap = scatteredInterpolant(xi(idx), yi(idx), observed_depth_stack_even(idx), true_depth_stack_extrap(idx),'linear','linear');
            true_depth_stack_extrap = F_extrap(xi, yi, observed_depth_stack_even);

            % fill in missing data from the near ranges with these extrapolated values
            idx_infill_near = isnan(true_depth_stack_even) & observed_depth_stack_even < 3500;
            true_depth_stack_even(idx_infill_near) = true_depth_stack_extrap(idx_infill_near);
            
            % now, for the far ranges with missing data...
            idx_infill_far = isnan(true_depth_stack_even) & observed_depth_stack_even >= 3500;
            
            
            if do_use_shift
                % create the shift map from the farther ranges, making sure not to average in zero values  
                shift_map = conv_depth_to_11bit(true_depth_stack) - conv_depth_to_11bit(observed_depth_stack);
                shift_map(true_depth_stack < 3500 | observed_depth_stack == 0) = NaN;
                shift_map = nanmean(shift_map,3);

                % if there ARE no farther values, well, try the near ones?
                shift_map_all = nanmean(shift_map,3);
                shift_map(isnan(shift_map)) = shift_map_all(isnan(shift_map));

                % replace all nans at far ranges with shift-adjusted data if available
                s = conv_11bit_to_depth(bsxfun(@plus,conv_depth_to_11bit(observed_depth_stack_even),shift_map));
                true_depth_stack_even(idx_infill_far) = s(idx_infill_far);
                
            elseif baseline
                % non-carmine triangulation sensors -- shift map probably still better than linear
                % create the shift map from the farther ranges, making sure not to average in zero values  
                shift_map = baseline./(true_depth_stack) - baseline./(observed_depth_stack);
                shift_map(true_depth_stack < 3500 | observed_depth_stack == 0) = NaN;
                shift_map = nanmean(shift_map,3);

                % if we just can't reach, 
                shift_map_all = nanmean(shift_map,3);
                shift_map(isnan(shift_map)) = shift_map_all(isnan(shift_map));

                % replace all nans at far ranges with shift-adjusted data if available
                s = baseline./(bsxfun(@plus,baseline./(observed_depth_stack_even),shift_map));
                idx_infill_far = isnan(true_depth_stack_even);
                true_depth_stack_even(idx_infill_far) = s(idx_infill_far);
            else
                % use the original extrapolation
                idx_infill_far = isnan(true_depth_stack_even) & observed_depth_stack_even >= 3500;
                true_depth_stack_even(idx_infill_far) = true_depth_stack_extrap(idx_infill_far);
            end
            
            
%% correction factor stack

            CFS = true_depth_stack_even ./ observed_depth_stack_even;
            
            %  zeros are a Really Bad Thing, so inpaint if there are any nans left
            
            CFS(CFS > 50) = nan;
            CFS(CFS < 0) = nan;
            
            CFS_high = CFS(:,:,2:end);
            CFS_low = CFS(:,:,1:end-1);
            if nanmedian(CFS_high(:)) > nanmedian(CFS_low(:))
                CFS_high(CFS_high < CFS_low) = nan;
            else
                CFS_high(CFS_low < CFS_high) = nan;
            end
            
            CFS(:,:,2:end) = CFS_high;
            
            for i = 1:obj.target_count
                 k = CFS(:,:,i);
                 k(k==0) = nan;
                 CFS(:,:,i) = inpaint_nans(k);
            end
            
%% create the data for the VDC!

            obj.correction_factor_stack = CFS;
            
            if ~ischar(obj.sensor_serial_number)
                obj.sensor_serial_number = num2str(obj.sensor_serial_number,'%i');
            end

            obj.start_depth = observed_depth_vector(1) / 1000;
            obj.depth_step = (observed_depth_vector(2) - observed_depth_vector(1)) / 1000;

            obj.correction_image_pngs = cell(obj.target_count,1);
            for i = 1:obj.target_count
                img = single(obj.correction_factor_stack(:,:,i));
                img = typecast(img(:),'uint8');
                img = reshape(img,[4 vres hres]);
                img = permute(img,[2 3 1]);
                stream = cv.imencode('.png',img,'PngCompression',6);
                obj.correction_image_pngs{i} = uint8(stream);
            end
        end

        function data_cal = apply(obj, data)
            %%
            [vres,hres,~] = size(obj.correction_factor_stack);
            [vresd,hresd,nd] = size(data);
            
            if nanmean(data(:)) > 100, scale = 1000; else scale = 1; end
            
            [xg,yg,zg] = get_image_grid(hresd,vresd,hres,vres,double(obj.target_vector)*scale);
%             F = griddedInterpolant(xg,yg,zg,double(obj.correction_factor_stack),'linear','linear');

            P = [2 1 3];
            X = permute(xg, P);
            Y = permute(yg, P);
            Z = permute(zg, P);
            V = permute(double(obj.correction_factor_stack), P);
            F = griddedInterpolant(X,Y,Z,V,'linear','linear');
            
            [xg,yg,~] = meshgrid(1:hresd,1:vresd,1:nd);
            
            
            X = permute(xg, P);
            Y = permute(yg, P);
            Z = permute(double(data), P);
            
%             corrs = F(xg,yg,double(data));
            corrs = F(X,Y,Z);
            
            data_cal = Z .* corrs;
            
            data_cal(data_cal == 0) = nan;
            
            data_cal = permute(data_cal,[2 1 3]);
            
            
        end
        
        
        
        
        
        function write(obj)
            obj.vdc_creation_time = datestr(now,'yyyy-mm-dd HHMMSS');
            msg = proto_object(obj);
            filename = [obj.sensor_serial_number '.vdc'];
            fid = fopen(filename,'w');
            fwrite(fid,pblib_generic_serialize_to_string(msg));
            fclose(fid);
        end

        function write_oldstyle(obj)
            filename = [obj.sensor_serial_number '.vdc'];
            fid = fopen(filename,'w');
            fwrite(fid,obj.start_depth,'float');
            fwrite(fid,obj.depth_step,'float');
            fwrite(fid,obj.target_count,'int');
            [vres, hres, ~] = size(obj.correction_factor_stack);
            for i = 1:obj.target_count
                img = single(obj.correction_factor_stack(:,:,i));
                img = typecast(img(:),'uint8');
                img = reshape(img,[4 vres hres]);
                img = permute(img,[2 3 1]);
                stream = cv.imencode('.png',img,'PngCompression',6);
                fwrite(fid,numel(stream),'int32');
                fwrite(fid,stream,'uint8');
            end
            fclose(fid);
        end
 
        
        function write_nerfed(obj)
            obj.shift_per_gmc_slope = 0;
            obj.starting_gmc_slope = 0;
            msg = proto_object(obj);
            filename = [obj.sensor_serial_number '.vdc'];
            fid = fopen(filename,'w');
            fwrite(fid,pblib_generic_serialize_to_string(msg));
            fclose(fid);
        end
        
        function obj = load( obj, filename )
            if ~ischar(filename)
                filename = num2str(filename,'%i');
            end
            if numel(filename) == 10
                filename = [filename '.vdc'];
            end
                
            if ~exist(filename, 'file')
                direc = dir('./*_calibration_files*');
                if ~isempty(direc) && exist([direc(1).name '/' filename], 'file')
                    copyfile([direc(1).name '/' filename], filename)
                end
            end
            
            if ~exist(filename, 'file')
                [~, here, ~] = fileparts(pwd);
                direc = [VDC.calrecords '/gamma/' here(1:2) '/' here(1:4)];
                if exist([direc '/' filename], 'file')
                    copyfile([direc '/' filename], filename)
                end
            end
                
            if ~exist(filename, 'file')
                error('MP:VDC:NotFound',['asked to load VDC to but did not find VDC file ' filename]);
            end

            fid = fopen(filename,'r');
            msg = fread(fid,inf,'uint8');
            fclose(fid);
            try
                proto = pb_read_eos__vdc_proto__VoxelDepthCorrection(msg);
                %disp('protobuf file');
            catch
                % not a protobuf, must be old style
                disp('non-protobuf file');
                fid = fopen(filename);
                obj.start_depth = fread(fid,1,'float');
                obj.depth_step = fread(fid,1,'float');
                obj.target_count = fread(fid,1,'int');
                pages = cell(obj.target_count,1);
                obj.correction_image_pngs = cell(obj.target_count,1);

                for i = 1:obj.target_count
                    sz = fread(fid,1,'int32');
                    obj.correction_image_pngs{i} = uint8(fread(fid,sz,'uint8'))';
                    img = cv.imdecode(obj.correction_image_pngs{i},'Flags',-1);
                    [vres,hres,~] = size(img);
                    img = permute(img,[3 1 2]);
                    img = typecast(img(:),'single');
                    img = reshape(img,[vres hres]);
                    pages{i} = img;
                end
                obj.correction_factor_stack = cell2mat(reshape(pages,[1 1 obj.target_count]));
                obj.target_vector = obj.start_depth:obj.depth_step:(obj.start_depth + obj.depth_step*(obj.target_count-1));
                fclose(fid);
                return;
            end
                
                obj.start_depth = proto.start_depth;
                obj.depth_step = proto.depth_step;
                obj.shift_per_gmc_slope = proto.shift_per_gmc_slope;
                obj.starting_gmc_slope = proto.starting_gmc_slope;
                obj.correction_image_pngs = proto.correction_image_pngs;
                obj.sensor_serial_number = proto.sensor_serial_number;
                obj.camera_serial_number = proto.camera_serial_number;
                obj.sensor_position = proto.sensor_position;
                obj.individual_sensor_calibration_time = proto.individual_sensor_calibration_time;
                obj.camera_in_situ_calibration_time = proto.camera_in_situ_calibration_time;
                obj.vdc_creation_time = proto.vdc_creation_time;
                obj.vdc_creation_version = proto.vdc_creation_version;
                
                obj.target_count = numel(obj.correction_image_pngs);
                pages = cell(obj.target_count,1);

                for i = 1:obj.target_count
                    
                    img = cv.imdecode(obj.correction_image_pngs{i},'Flags',-1);
                    [vres,hres,~] = size(img);
                    img = permute(img,[3 1 2]);
                    img = typecast(img(:),'single');
                    img = reshape(img,[vres hres]);
                    pages{i} = img;
                end
                obj.correction_factor_stack = cell2mat(reshape(pages,[1 1 obj.target_count]));
                obj.target_vector = obj.start_depth:obj.depth_step:(obj.start_depth + obj.depth_step*(obj.target_count-1));
            
        end

    end
    
end

function msg = proto_object(obj)
    msg = pb_read_eos__vdc_proto__VoxelDepthCorrection([]);
    msg = pblib_set(msg, 'start_depth', single(obj.start_depth));
    msg = pblib_set(msg, 'depth_step', single(obj.depth_step));
    msg = pblib_set(msg, 'shift_per_gmc_slope', single(obj.shift_per_gmc_slope));
    msg = pblib_set(msg, 'starting_gmc_slope', single(obj.starting_gmc_slope));
    msg = pblib_set(msg, 'correction_image_pngs', obj.correction_image_pngs);
    msg = pblib_set(msg, 'sensor_serial_number', obj.sensor_serial_number);
    msg = pblib_set(msg, 'camera_serial_number', obj.camera_serial_number);
    msg = pblib_set(msg, 'individual_sensor_calibration_time', obj.individual_sensor_calibration_time);
    msg = pblib_set(msg, 'camera_in_situ_calibration_time', obj.camera_in_situ_calibration_time);
    msg = pblib_set(msg, 'vdc_creation_time', obj.vdc_creation_time);
    msg = pblib_set(msg, 'vdc_creation_version', obj.vdc_creation_version);
end

% CHANGES
% protoc gets a fgew things wrong
% read functions for strings must be transposed: 
%   @(x) char(x{1}(x{2} : x{3}))
%   'read_function', @(x) char(x{1}(x{2} : x{3}))', ...
% read functions for single must be typecast to uint8:
%   @(x) typecast(x, 'single'), ...
%   'read_function', @(x) typecast(uint8(x), 'single'), ...
% 