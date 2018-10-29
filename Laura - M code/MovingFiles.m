%% Moving around Sensor eval data
% This is specifically for bright wall data, varying exposure and gain

% This is for the ir20 values (they were saved in a different format
prefix = 'Orbbec_Astra_16122010564_overExposure';

% Under exposure settings
% exp = {'0','500','600','800','900','a00','c00','1000'};
% exp_dec = [0,1280,1536,2048,2304,2560,3072,4096];
% gain = {'60'};
% gain_dec = [96];

% Under exposure settings (take 2)
% exp = {'0','500','600','700','800','900','a00','b00','c00','d00','e00','f00','1000'};
% exp_dec = [0,1280,1536,1792,2048,2304,2560,2816,3072,3328,3584,3840,4096];
% gain = {'60'};
% gain_dec = [96];

% Over expose settings
%exp = {'0','1','100','200','300'};
%exp_dec = [0,1,256,512,768];
%gain = {'8','18','28','38','45','55','60'};
%gain_dec = [8,24,40,56,69,85,96];

% Over exposure settings (take 2)
exp = {'0','500','700','900','b00','d00','f00','1000'};
exp_dec = [0,1280,1792,2304,2816,3328,3840,4096];
gain = {'8','18','28','38','45','55','60'};
gain_dec = [8,24,40,56,69,85,96];

starting_dir = pwd;

%cd('//10.2.10.10/SensorEvalDMZ/Inbox/CarminePrime_vs._Astra');
Dir_all = dir('Orbbec_Astra_16122010564_overExposure_*');
Dir_all = {Dir_all.name};


for i = 1:length(exp)
    for j = 1:length(gain)
        working_dir = [prefix '_Exp' num2str(exp_dec(i)) '_Gain' num2str(gain_dec(j))];
        if ~exist(working_dir,'dir')
            mkdir(working_dir);
        end
        out_exp = strfind(Dir_all,['0x' exp{i}]);
        out_gain = strfind(Dir_all, ['0x' gain{j}]);
        
        dir_ind = find(~cellfun('isempty',out_exp)&~cellfun('isempty',out_gain));
        
        for k = 1:length(dir_ind)
            dir_now = Dir_all(dir_ind(k));
            copyfile([dir_now{1} '/*.mat'], working_dir);
        end
        cd(working_dir)
        %SensorEval_add_ExpGain(exp_dec(i),gain_dec(j));
        cd ..
    end
end

%% move the rest of the files to the correct folders

% Dir_all = dir('Orbbec_Astra_16122010564_bright_*');
% final_dir = dir([prefix '_Exp*']);
% final_dir = {final_dir.name};
% 
% for m = 1:length(Dir_all)
%     working_dir = Dir_all(m).name;
%     cap_in = dir([working_dir '/*.mat']);
%     load([working_dir '/' cap_in.name]);
%     
%     exp_in = cap.ir_exposure;
%     gain_in = cap.ir_gain;
%     %ind_exp = (exp_dec == exp_in);
%     %ind_gain = (gain_dec == gain_in);
%     
%     input_dir = dir(['*_Exp' num2str(exp_in) '_Gain' num2str(gain_in)]);
%     save([input_dir.name '/' cap_in.name],'cap');
%     
% end