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
    path_out = fullfile(dataPath, 'LEAP', 'EEG', 'faces',...
        '20181214', '03_clean100_mannheim');
    tryToMakePath(path_out)

    % input path
    path_preproc = fullfile(dataPath, 'LEAP', 'EEG', 'faces',...
        '20181214', '01_preproc100_mannheim');
    d = dir([path_preproc, filesep, '*.mat']);
    numFiles = length(d);
    ops = cell(numFiles, 1);

    % send data to workers
    parfor f = 1:numFiles
        
        try
            path_in = [path_preproc, filesep, d(f).name];
            parts = strsplit(d(f).name, '.');
            id = parts{1};
            ops{f} = struct;
            [~, ~, ops{f}] = LEAP_EEG_faces_02_doClean(ops{f}, path_in,...
                id, path_out, [], [], []);
            ops{f}.success = true;
        catch ERR
            ops{f}.error = ERR.message;
            ops{f}.success = false;
        end
            
    end

    res = teLogExtract(ops);


    cutoff_tpc = 20;
    met_tpc = res.tpc_inv >= cutoff_tpc & res.tpc_up >= cutoff_tpc;
    fprintf('Met 20tpc cutoff for both conditions: %d of %d (%.1f%%)\n',...
        sum(met_tpc), length(met_tpc), (sum(met_tpc) / length(met_tpc)) * 100)

    cutoff_interp = 10;
    met_interp = res.numChanInterp <= cutoff_interp;
    fprintf('Met <10 channels interpolated cutoff: %d of %d (%.1f%%)\n',...
        sum(met_interp), length(met_interp), (sum(met_interp) / length(met_interp)) * 100)

    cutoff_excl = 10;
    met_excl = res.numChanExcl <= cutoff_excl;
    fprintf('Met <10 channels excluded cutoff: %d of %d (%.1f%%)\n',...
        sum(met_excl), length(met_excl), (sum(met_excl) / length(met_excl)) * 100)

    met = met_tpc & met_excl * cutoff_interp;
    fprintf('Met all cutoff criteria: %d of %d (%.1f%%)\n',...
        sum(met), length(met), (sum(met) / length(met)) * 100)

    res = [res,...
        table(met_tpc, met_interp, met_excl, met, 'variablenames',...
        {'Met_Cutoff_TPC20', 'Met_Cutoff_Interp10', 'Met_Cutoff_Excl10', 'Met_All_Cutoffs'})];

  


