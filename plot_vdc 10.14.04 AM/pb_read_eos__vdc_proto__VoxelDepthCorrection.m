function [voxel_depth_correction] = pb_read_eos__vdc_proto__VoxelDepthCorrection(buffer, buffer_start, buffer_end)
%pb_read_eos__vdc_proto__VoxelDepthCorrection Reads the protobuf message VoxelDepthCorrection.
%   function [voxel_depth_correction] = pb_read_eos__vdc_proto__VoxelDepthCorrection(buffer, buffer_start, buffer_end)
%
%   INPUTS:
%     buffer       : a buffer of uint8's to parse
%     buffer_start : optional starting index to consider of the buffer
%                    defaults to 1
%     buffer_end   : optional ending index to consider of the buffer
%                    defaults to length(buffer)
%
%   MEMBERS:
%     start_depth    : optional single, defaults to single(0.5).
%     depth_step     : optional single, defaults to single(0.5).
%     shift_per_gmc_slope: optional single, defaults to single(0).
%     starting_gmc_slope: optional single, defaults to single(0).
%     correction_image_pngs: repeated uint8 vector, defaults to uint8([]).
%     sensor_serial_number: optional string, defaults to ''.
%     sensor_position: optional string, defaults to ''.
%     camera_serial_number: optional string, defaults to ''.
%     individual_sensor_calibration_time: optional string, defaults to ''.
%     camera_in_situ_calibration_time: optional string, defaults to ''.
%     vdc_creation_time: optional string, defaults to ''.
%     vdc_creation_version: optional string, defaults to '0'.
%     fit_parameters : repeated double, defaults to double([]).

  if (nargin < 1)
    buffer = uint8([]);
  end
  if (nargin < 2)
    buffer_start = 1;
  end
  if (nargin < 3)
    buffer_end = length(buffer);
  end

  descriptor = pb_descriptor_eos__vdc_proto__VoxelDepthCorrection();
  voxel_depth_correction = pblib_generic_parse_from_string(buffer, descriptor, buffer_start, buffer_end);
  voxel_depth_correction.descriptor_function = @pb_descriptor_eos__vdc_proto__VoxelDepthCorrection;
