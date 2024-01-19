    addpath(genpath('/Users/luke/Google Drive/Dev/lm_tools'))
    addpath('/Users/luke/Google Drive/Dev/ECKAnalyse/')
    addpath('/users/luke/Google Drive/Experiments/LEAP/Baseline/')
    
% db

    ac = teAnalysisClient;
    ac.ConnectToServer('localhost', 3000)
    ac.HoldQuery = {'Study', 'LEAP', 'faceerp_avged', true};
    
    % get metadata
    md = ac.Metadata;
    guids_md = cellfun(@(x) x.GUID, md, 'UniformOutput', false);

    % get ERPs
    [allErps, guids_erp] = ac.GetVariable('faceerp_avg30');
    numData = length(allErps);
    
    % get table
    tab = ac.Table;
    
    if ~isequal(guids_md, guids_erp, tab.GUID)
        error('Metadata/table/ERP GUIDs do not match.')
    end

    % get LEAP metadata
    [tab, ~, id_notFound] = LEAP_appendMetadata(tab, 'ID');
    
    % empty measures table
    tab_mes = table;
    
% measure

    % define expected peaks
    fnames_pr_exp = {...
                    'face_up_P1o_O1'...      
                    'face_up_P1o_O2'...      
                    'face_up_N170p_P7'...    
                    'face_up_N170p_P8'...    
                    'face_inv_P1o_O1'...     
                    'face_inv_P1o_O2'...     
                    'face_inv_N170p_P7'...   
                    'face_inv_N170p_P8'...   
                    };
    
    for d = 1:numData
        
        if mod(d, 50) == 0
            fprintf('Tabulating peaks %d of %d...\n', d, numData);
        end        
        
        % basic checks that this metadata has the fields we need
        if ~isprop(md{d}, 'erp_peaks'), continue, end
        if ~isstruct(md{d}.erp_peaks), continue, end
        if ~isstruct(md{d}.peakrating), continue, end
        
        % get erps
        erps = allErps{d};
        
        % tabulate
        tab_mes = [tab_mes; LEAP_EEG_faces_tabulatePeaks(md{d}, erps)];
                
    end
    
% % load previous analysis and mark each row of the table to indicate whether
% % or not it is new data
% 
%     % load previous 
%     old = readtable(...
%         '/Users/luke/Google Drive/Experiments/face erp/_old2/LEA_EEG_faces_results_20170510.xlsx',...
%         'Sheet', 'Sheet1');    
%     idx_new = ~ismember(tab_mes.ID, old.ID);
%     tab_mes.new_data = idx_new;

% append LEAP demo data
    
    tab_mes = LEAP_appendMetadata(tab_mes, 'ID');
    
% save Matlab and Excel

    save(sprintf('LEAP_EEG_faces_measures_%s', datestr(now, 30)), 'tab_mes')
    tab_mes_xl = tab_mes;
    tab_mes_xl.erp_avg = [];
    tab_mes_xl.erp_time = [];
    writetable(tab_mes_xl, sprintf('LEAP_EEG_faces_measures_%s.xlsx', datestr(now, 30)))