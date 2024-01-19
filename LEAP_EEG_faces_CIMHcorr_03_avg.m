% setup

    clear variables
    addpath('/Users/luke/Google Drive/Dev/fieldtrip-20180320')
    addpath('/Users/luke/Google Drive/Experiments/LEAP')
    addpath('/Users/luke/Google Drive/Dev/eegtools')
    addpath(genpath('/Users/luke/Google Drive/Dev/lm_tools'))
    ft_defaults
  
    stat = ECKStatus('Starting up...');

    % get paths
    [expPath, dataPath, gPath] = getExperimentsPath;

    % output paths
    path_out_30 = fullfile(dataPath, 'LEAP', 'EEG', 'faces',...
        '20181214', '04_avg30_mannheim');
    tryToMakePath(path_out_30)

    % input path
    path_clean = fullfile(dataPath, 'LEAP', 'EEG', 'faces',...
        '20181214', '03_clean30_mannheim');
    d = dir([path_clean, filesep, '*.mat']);
    numFiles = length(d);
    ops = cell(numFiles, 1);

    % send data to workers
    parfor f = 1:numFiles
        
        try
            path_in = [path_clean, filesep, d(f).name];
%             parts = strsplit(d(f).name, '.');
%             id = parts{1};
            ops{f} = struct;
            [erps_tmp, ops{f}] = LEAP_EEG_faces_03_doAverage(path_in,...
                path_out_30);
            ops{f}.success = true;
        catch ERR
            ops{f}.error = ERR.message;
            ops{f}.success = false;
        end
            
    end

    res = teLogExtract(ops);

