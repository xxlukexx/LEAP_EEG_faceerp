% setup

    clear variables
    addpath('/Users/luke/Google Drive/Dev/fieldtrip-20180320')
    addpath(genpath('/Users/luke/Google Drive/Experiments/LEAP'))
    addpath('/Users/luke/Google Drive/Dev/eegtools')
    addpath(genpath('/Users/luke/Google Drive/Dev/lm_tools'))
    ft_defaults
    
% paths

    % get unified paths to experiments folder and data store
    [path_exp, path_dataStore]  = getExperimentsPath;

    % output path to faces task for this processing run
    path_faces                  = fullfile(...
                                    path_dataStore,...
                                    'LEAP',...
                                    'EEG',...
                                    'faces',...
                                    '20181214');

    path_preproc30              = fullfile(...
                                    path_faces,...
                                    '01_preproc30_mannheim');
                                
    path_preproc100             = fullfile(...
                                    path_faces,...
                                    '01_preproc100_mannheim');
                                
    path_raw                    = fullfile(...
                                    path_dataStore,...
                                    'LEAP',...
                                    '_preproc',...
                                    'out',...
                                    'eeg',...
                                    'bl',...
                                    'v3',...
                                    'face_erp');
                                
    % try to make any paths that may not yet exist
    tryToMakePath(path_preproc30)
    tryToMakePath(path_preproc100)

% find just Mannheim IDs

    % connect to DB to get authorative list of IDs
    client = teAnalysisClient;
    client.ConnectToServer('193.61.45.196', 3000)
    client.HoldQuery = {'Study', 'LEAP'};
    
    % get all IDs
    [ids, guids] = client.GetField('ID');
    tab_ids = cell2table(ids, 'VariableNames', {'ID'});
    
    % get LEAP medata (in order to look up site)
    tab_ids = LEAP_appendMetadata(tab_ids, 'ID');
    
    % find Mannheim IDs
    idx_site = strcmpi(tab_ids.site, 'Mannheim');
    id_cimh = tab_ids.ID(idx_site);
    
    % find all raw file IDs
    d = dir(sprintf('%s%s*.set', path_raw, filesep));
    files_raw = {d.name}';
    idx_raw = cellfun(@(x) find(instr(files_raw, x), 1), id_cimh);
    files_raw = files_raw(idx_raw);
    numSubs = length(idx_raw);
    
    % init blank operations structure
    ops = cell(numSubs, 1);    
    
% preprocess

    parfor d = 1:numSubs
                      
        ops{d} = struct;
        
        % get and check data path
        file_raw = fullfile(path_raw, files_raw{d});
        
        % process 30Hz
        [data_tmp30, file_out_30Hz, ops{d}] =...
            LEAP_EEG_faces_01_doPreProc(ops{d}, file_raw, 'Mannheim',...
            id_cimh{d}, path_preproc30, 30);
        
        % process 100Hz
        [data_tmp100, file_out_100Hz, ops{d}] =...
            LEAP_EEG_faces_01_doPreProc(ops{d}, file_raw, 'Mannheim',...
            id_cimh{d}, path_preproc100, 100);
        
    end