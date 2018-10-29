function [fig, all_result] = display_results(test_header, test_limits, test_results, fig_title, im, language, delay)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Kevin Kane
% Matterport
% December 2017
% Discription: Basic display of results with limits and Pass/Fail
% Matterport Confidentual Material
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ************ Start of Main Program:

%% Declare display strings based on language default = english
switch(language)
    case 'e' 
        pass = 'pass';
        fail = 'fail';
        test = 'TEST';
        result = 'RESULT';
        low = 'LOWER';
        up = 'UPPER';
        state = 'STATE';
    case 'c'
        pass = '\surd';
        fail = '\times  NG';
        test = 'TEST';
        result = 'RESULT';
        low = 'LOWER';
        up = 'UPPER';
        state = 'STATE';
    otherwise
        pass = '\surd';
        fail = '\times  NG';
        test = 'TEST';
        result = 'RESULT';
        low = 'LOWER';
        up = 'UPPER';
        state = 'STATE';
end

%% Display pass/fail results to user
disp('Displaying test results')

% setup figure
iheight = 300;
gw = 840;
gh = 120+(50*size(test_header,1))+iheight;
gri = 0.85*ones(gh, gw);
fig = figure();
imshow(gri);
pos = get(gca, 'Position');
pos(2) = 0.065;
set(gca, 'Position', pos)
fig.Name = 'Result of Test(s)';
fig.Color = [0 .9 0];

hold on;
img = imread(im);
image('CData',img,'XData',[30 gw-30],'YData',[gh-(iheight+30) gh-30]);

all_result = 'PASS';
fig_title = replace(fig_title,'_','\_');
title(fig_title);

% add fill in figure with text showing pass and fails
np = size(test_results,2);   % needs array 'test_results' (1 by k)
text(50, 50, test, 'Color', 'k', 'FontSize', 14, 'Interpreter','tex', 'FontWeight', 'bold');
text(220, 50, result, 'Color', 'k', 'FontSize', 14, 'Interpreter','tex', 'FontWeight', 'bold');
text(380, 50, low, 'Color', 'k', 'FontSize', 14, 'Interpreter','tex', 'FontWeight', 'bold');
text(550, 50, up, 'Color', 'k', 'FontSize', 14, 'Interpreter','tex', 'FontWeight', 'bold');
text(720, 50, state, 'Color', 'k', 'FontSize', 14, 'Interpreter','tex', 'FontWeight', 'bold');
for k = 1:np
    ll = test_limits(k, 1);   % needs array 'test_limits' (k by 2)
    hl = test_limits(k, 2);
    header = char(test_header(k,:));  % needs array 'test_header' (k by 1)
    tr = test_results(k);
    ps = pass;
    pc = [0 .75 0];
    if ll > tr || tr > hl
        ps = fail;
        pc = 'r';
        fig.Color = 'r';
        all_result = 'FAIL';
    end % if ll > tr || tr > hl
    text(50, 50+(k*50), header, 'Color', pc, 'FontSize', 16, 'Interpreter','tex');
    text(220, 50+(k*50), num2str(tr), 'Color', pc, 'FontSize', 16, 'Interpreter','tex');
    text(380, 50+(k*50), num2str(ll), 'Color', pc, 'FontSize', 16, 'Interpreter','tex');
    text(550, 50+(k*50), num2str(hl), 'Color', pc, 'FontSize', 16, 'Interpreter','tex');
    text(720, 50+(k*50), num2str(ps), 'Color', pc, 'FontSize', 16, 'Interpreter','tex', 'FontWeight', 'bold');
end % for k = 1:np
hold off;
disp(['Test Result: ' all_result])

%% Delay or wait for figure to be closed by Operator
if exist('delay', 'var')
    if delay >= 0
        pause(delay)
        close(fig)
    else
        uiwait(fig)
    end % if delay >= 0
end % if exist('delay', 'var')

%% Set all_result output
if strcmp(all_result, 'PASS')
    all_result = 1;
elseif strcmp(all_result, 'FAIL')
    all_result = 0;
else
    error('fialure in identifying pass/fail status')
end % if strcmp(all_result, 'PASS')

end % function