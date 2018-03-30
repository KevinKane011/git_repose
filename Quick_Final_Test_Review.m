function [ ] = Quick_Final_Test_Review()

% clear all
close all

% Jump to Overlap path
id = 'I1';
path = ['/Volumes/CalGen/gamma/' id];
cd(path);

% Load in all the data
data_dir = dir(['*' id '*']);
q = length(data_dir);
for i = 1:q
    stru_d = data_dir(i);
    stru_d.name;
    cd(['/Volumes/CalGen/gamma/' id '/' stru_d.name]);
    
    % find the oldest "warm" final test image
    test_dir = dir('*finalwarm*'); 
    x = length(test_dir);
    warm_ts = '21000101_235959'; % Jan 1st 2100!
    for j = 1:x
        stru_t = test_dir(j);
        ts = stru_t.name;
        if str2num(ts(end-14:end-7)) < str2num(warm_ts(end-14:end-7))
            warm_ts = ts(end-14:end);
        elseif str2num(ts(end-14:end-7)) == str2num(warm_ts(end-14:end-7))
            if str2num(ts(end-6:end)) < str2num(warm_ts(end-6:end))
                warm_ts = ts(end-14:end);
            end   
        end
    end
    disp([path '/' stru_d.name '/' stru_d.name '_finalwarm_' warm_ts '/y_' stru_d.name '_' warm_ts '_warm.jpg']);
    figure;
    imshow([path '/' stru_d.name '/' stru_d.name '_finalwarm_' warm_ts '/y_' stru_d.name '_' warm_ts '_warm.jpg']);
    warm_metrics = fileread([path '/' stru_d.name '/' stru_d.name '_finalwarm_' warm_ts '/metrics_' stru_d.name '_' warm_ts '_warm.txt']);
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.51, 0.45, 0.49, 0.49]);
    disp(['warm: ' warm_metrics]);

    
    
    % find the oldest "warm" final test image
    test_dir = dir(['*finalcold*']);
    x = length(test_dir);
    cold_ts = '21000101_235959'; % Jan 1st 2100!
    for j = 1:x
        stru_t = test_dir(j);
        ts = stru_t.name;
        if str2num(ts(end-14:end-7)) < str2num(cold_ts(end-14:end-7))
            cold_ts = ts(end-14:end);
        elseif str2num(ts(end-14:end-7)) == str2num(cold_ts(end-14:end-7))
            if str2num(ts(end-6:end)) < str2num(cold_ts(end-6:end))
                cold_ts = ts(end-14:end);
            end   
        end
    end
    disp([path '/' stru_d.name '/' stru_d.name '_finalcold_' warm_ts '/y_' stru_d.name '_' warm_ts '_cold.jpg']);
    figure;
    imshow([path '/' stru_d.name '/' stru_d.name '_finalcold_' cold_ts '/y_' stru_d.name '_' cold_ts '_cold.jpg']);
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.01, 0.45, 0.49, 0.49]);
    cold_metrics = fileread([path '/' stru_d.name '/' stru_d.name '_finalcold_' warm_ts '/metrics_' stru_d.name '_' warm_ts '_cold.txt']);
    disp(['cold: ' cold_metrics]);
    
    uiwait(gcf)
    
    close all
    cd ..
end