function [module_position] = next_module_position(module_position)

%% next_module_position
% switch to new position

switch module_position
    case 'home'
        module_position = 'top';
    case 'top'
        module_position = 'middle';
    case 'middle'
        module_position = 'bottom';
    case 'bottom'
        module_position = 'home';
    otherwise
        error('Error: confused about motor location and module sequence!')
end