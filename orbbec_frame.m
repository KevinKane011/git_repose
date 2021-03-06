function [frame] = orbbec_frame(raw)

%ORBBEC_FRAME - Opens a .raw depth frame
% this is a test, and only a test

if isempty(raw)
    raw = uigetfile('.raw', 'Select the .raw depth file');
end

if isa(raw,'char')
    frame = transpose(fread(fopen(raw), [640, 480], 'uint16=>uint16'));
    imshow(frame);
else
    disp('Error: input value was not a string');
    error('Error: input value was not a string');
end
end

