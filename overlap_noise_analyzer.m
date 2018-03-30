function [ ] = overlap_noise_analyzer(depth_image, varargin)
%OVERLAP_NOISE_ANALYZER looks at the over lap region and quanifies the
%   noise levels

%% Deal with input arguments
% only want 3 optional inputs at most
numvarargs = length(varargin);
if numvarargs > 0
    error('myfuns:somefun2Alt:TooManyInputs', ...
        'requires at most 0 optional inputs');
end

% set defaults for optional inputs
optargs = {'', '', ''};

% now put these defaults into the valuesToUse cell array, 
% and overwrite the ones specified in varargin.
optargs(1:numvarargs) = varargin;

% Place optional args in memorable variable names
[optional_input_1, optional_input_1, optional_input_1] = optargs{:};


