function [mergeddata] = combine_multiple_csv()

clear all

[csvFiles, PathName, ~] = uigetfile('*.csv', ...
    'Select the .csv files to combine','MultiSelect', 'on');
numcsv = size(csvFiles, 2);

for k=1:numcsv
    % [serial, Date_time, distance, flatness, coverage]
    [s1, s2, s3, s4, s5] = textread([PathName csvFiles{k}], '%s %s %s %s %s', 2);
    if k == 1
        filedata(k,:) = [{s1{1,1}}, {s2{1,1}}, {s3{1,1}}, {s4{1,1}}, {s5{1,1}}];
        filedata(k+1,:) = [{s1{2,1}}, {'0'}, {s1{2,1}}, {s1{2,1}}, {s1{2,1}}]; % <-- hacked
    end
    filedata(k+1,:) = [{s1{2}}, {'0'}, {s2{2}}, {s3{2}}, {s4{2}}]; % <-- hacked
end
disp(filedata);

fid = fopen([PathName 'combined_csv.csv'], 'w') ;
fprintf(fid, '%s,', filedata{1,1:end}) ;
fprintf(fid, '%s\n', filedata{1,end}) ;
for k=1:numcsv
    fprintf(fid, '%s,', filedata{k+1,1:end}) ;
    fprintf(fid, '%s\n', filedata{k+1,end}) ;
end
fclose(fid) ;