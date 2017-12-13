function [fig, all_result] = display_results(test_header, test_limits, test_results, t, language)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Kevin Kane
% Matterport
% December 2017
% Discription: Basic display of results with limits and Pass/Fail
% Matterport Confidentual Material
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% ************ Start of Main Program:
% Declare display strings based on language default = english
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
        fail = '\times';
        test = 'TEST';
        result = 'RESULT';
        low = 'LOWER';
        up = 'UPPER';
        state = 'STATE';
    otherwise
        pass = '\surd';
        fail = '\times';
        test = 'TEST';
        result = 'RESULT';
        low = 'LOWER';
        up = 'UPPER';
        state = 'STATE';
end

%% Display pass/fail results to user
disp('Displaying test results')
gw = 840;
gh = 100+(50*size(test_header,1));
gri = 0.85*ones(gh, gw);
fig = figure();
imshow(gri);
fig.Name = 'Result of Test(s)';
fig.Color = [0 .9 0];
all_result = 'pass';
title(t);
hold on;
np = size(test_results, 2);   % needs array 'test_results' (1 by k)
text(50, 50, test, 'Color', 'k', 'FontSize', 16, 'Interpreter','latex');
text(210, 50, result, 'Color', 'k', 'FontSize', 16, 'Interpreter','latex');
text(360, 50, low, 'Color', 'k', 'FontSize', 16, 'Interpreter','latex');
text(510, 50, up, 'Color', 'k', 'FontSize', 16, 'Interpreter','latex');
text(660, 50, state, 'Color', 'k', 'FontSize', 16, 'Interpreter','latex');
for k = 1:np
    ll = test_limits(1, k);   % needs array 'test_limits' (2 by k)
    hl = test_limits(2, k);
    header = char(test_header(k,:));  % needs array 'test_header' (1 by k)
    tr = test_results(k);
    ps = pass;
    pc = [0 .75 0];
    if ll > tr || tr > hl
        ps = fail;
        pc = 'r';
        fig.Color = 'r';
        all_result = 'fail';
    end
    text(50, 50+(k*50), header, 'Color', pc, 'FontSize', 16, 'Interpreter','latex');
    text(210, 50+(k*50), num2str(tr), 'Color', pc, 'FontSize', 16, 'Interpreter','latex');
    text(360, 50+(k*50), num2str(ll), 'Color', pc, 'FontSize', 16, 'Interpreter','latex');
    text(510, 50+(k*50), num2str(hl), 'Color', pc, 'FontSize', 16, 'Interpreter','latex');
    text(660, 50+(k*50), num2str(ps), 'Color', pc, 'FontSize', 16, 'Interpreter','tex', 'FontWeight', 'bold');
end
hold off;
end