function [array_buffer] = update_array_buffer(array_buffer, module_psition, DorRGB, result)

if strcmp(DorRGB, 'Depth')
    if strcmp(module_psition, 'top')
        array_buffer(1,1) = result;
    elseif strcmp(module_psition, 'middle')
        array_buffer(2,1) = result;
    elseif strcmp(module_psition, 'bottom')
        array_buffer(3,1) = result;
    else
        error('unclear array_buffer update condition')
    end
        
elseif strcmp(DorRGB, 'RGB')
    if strcmp(module_psition, 'top')
        array_buffer(2,1) = result;
    elseif strcmp(module_psition, 'middle')
        array_buffer(2,2) = result;
    elseif strcmp(module_psition, 'bottom')
        array_buffer(2,3) = result;
    else
        error('unclear array_buffer update condition')
    end
        
else
        error('unclear array_buffer update condition')
end