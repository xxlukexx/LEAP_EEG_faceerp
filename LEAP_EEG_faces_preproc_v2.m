% setup

    clear variables
    addpath('/Users/luke/Google Drive/Dev/fieldtrip-20180320')
    addpath('/Users/luke/Google Drive/Experiments/LEAP')
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
                                    '01_preproc30');
                                
    path_raw                    = fullfile(...
                                    path_dataStore,...
                                    'LEAP',...
                                    '_preproc',...
                                    'out',...
                                    'eeg',...
                                    'bl',...
                                    'v3',...
                                    'face_erp');
                                
    path_master                 = fullfile(path_dataStore,...
                                    'LEAP',...
                                    '_preproc',...
                                    'in',...
                                    'eeg',...
                                    'LEAP_EEG_master.preproc.xlsx');
                                
    % try to make any paths that may not yet exist
    tryToMakePath(path_preproc30)

% load master table of IDs

    tab_master = readtable(path_master, 'Sheet', 'Sheet1');
    numSubs = size(tab_master, 1);
    
    % convert empty (loaded as nan by readtable) task presence to false
    idx_nan = isnan(tab_master.TaskPresent_FACE_ERP);
    tab_master.TaskPresent_FACE_ERP(idx_nan) = false;
    
    % init blank operations structure
    ops = cell(numSubs, 1);
    
% preprocess

    parfor d = 1:numSubs
        
        % determine whether face ERP task was present
        if tab_master.TaskPresent_FACE_ERP(d)
            ops{d}.FaceERP_Present = true;
            
        else
            ops{d}.FaceERP_Present = false;
            continue
            
        end
        
        % get ID and site
        id = tab_master.Clinical_Subjects{d};
        site = tab_master.site{d};
        
        % get and check data path
        file_raw = fullfile(path_raw, sprintf('%s_face_erp.set', id));
        ops{d}.FaceERP_FoundRawFile = exist(file_raw, 'file') == 2;
        if ~ops{d}.FaceERP_FoundRawFile, continue, end
        
        % temp serial function call
        [~, file_out_30Hz, ops{d}] =...
            LEAP_EEG_faces_01_doPreProc(ops{d}, file_raw, site, id,...
            path_preproc30, 30);
       
    end