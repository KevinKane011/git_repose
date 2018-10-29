function depth_result = load_depth_image(filename)
% This function will load in the depth images in the current directory
        
    %% Load in the depth data
    I = imread(filename);
    [vres, hres, chan] = size(I);

    switch (chan)
        case 3
            I = I(:,:,2:3); % lose the empty channel
            I = permute(I,[3 1 2]); % channels first for reshape to vector
            I = typecast(uint8(I(:)),'uint16');
            I = swapbytes(I); % fix endian issues (?)
        otherwise
            error('MP:LoadDataPng:Channels','weird channel number');
    end

   depth_result = reshape(I,[vres hres]); 

    end