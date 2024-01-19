% pipeline dropout

    load('/Volumes/Projects/LEAP/EEG/faces/20181214/03_clean30/_results.mat')

    cutoff_tpc = 20;
    met_tpc = res.tpc_inv >= cutoff_tpc & res.tpc_up >= cutoff_tpc;
    fprintf('Met 20tpc cutoff for both conditions: %d of %d (%.1f%%)\n',...
        sum(met_tpc), length(met_tpc), (sum(met_tpc) / length(met_tpc)) * 100)

    cutoff_interp = 10;
    met_interp = cell2mat(res.numChanInterp) <= cutoff_interp;
    fprintf('Met <10 channels interpolated cutoff: %d of %d (%.1f%%)\n',...
        sum(met_interp), length(met_interp), (sum(met_interp) / length(met_interp)) * 100)

    cutoff_excl = 10;
    met_excl = cell2mat(res.numChanExcl) <= cutoff_excl;
    fprintf('Met <10 channels excluded cutoff: %d of %d (%.1f%%)\n',...
        sum(met_excl), length(met_excl), (sum(met_excl) / length(met_excl)) * 100)

    met = met_tpc & met_excl & met_interp;
    fprintf('Met all cutoff criteria: %d of %d (%.1f%%)\n',...
        sum(met), length(met), (sum(met) / length(met)) * 100)
    
    p_bad = res.P7Bad | res.P8Bad;
    o_bad = res.O1Bad | res.O2Bad;
    
    parts = cellfun(@(x) strsplit(x, '.'), res.clean_FileIn, 'UniformOutput', false);
    res.ID = cellfun(@(x) x{1}, parts, 'UniformOutput', false);
    res = LEAP_appendMetadata(res, 'ID');
    
    idx_asd = strcmpi(res.group, 'ASD');
    idx_id_asd = strcmpi(res.group, 'ID-ASD');
    idx_td= strcmpi(res.group, 'TD');
    idx_id_ctrl = strcmpi(res.group, 'TD-control');
    
    n = size(res, 1);
    n_samp = size(met_tpc, 1);
    
    [grp_u, ~, grp_s] = unique(res.group);
    n_grp = accumarray(grp_s, met_tpc, [], @length);
    tpc = accumarray(grp_s, ~met_tpc, [], @sum);
    
    interp = accumarray(grp_s, ~met_interp, [], @sum);
    
    excl = accumarray(grp_s, ~met_excl, [], @sum);
    
    met_all = accumarray(grp_s, ~met, [], @sum);
    
    pbad = accumarray(grp_s, p_bad, [], @sum);
    obad = accumarray(grp_s, o_bad, [], @sum);
    
    tab = table;
    tab.tpc20 = tpc;
    tab.interp10 = interp;
    tab.excl10 = excl;
    tab.all = met_all;
    tab.Properties.RowNames = grp_u;
    
    writetable(tab, sprintf('LEAP_EEG_faces_analysisDropout_%s.xlsx', datestr(now, 30)), 'WriteRowNames', true)
    
% peak dropout (breakdown by peak/comp/hemi)

    load('/Users/luke/Google Drive/Experiments/face erp/LEAP_EEG_faces_measures_20190522T094851.mat')
    
    idx_rem = strcmpi(tab_mes.comp, 'N2p') | strcmpi(tab_mes.comp, 'P2p') | strcmpi(tab_mes.comp, 'P1p');
    tab_mes(idx_rem, :) = [];
    
    [cond_u, ~, cond_s] = unique(tab_mes.cond);
    numCond = length(cond_u);
    [comp_u, ~, comp_s] = unique(tab_mes.comp);
    numComp = length(comp_u);
    [hemi_u, ~, hemi_s] = unique(tab_mes.hemi);
    numHemi = length(hemi_u);
    [grp_u, ~, grp_s] = unique(tab_mes.group);
    numGrp = length(grp_u);
    
    numRow = numCond * numComp * numHemi;
    m = nan(numRow, numGrp);
    cond = cell(numRow, 1);
    comp = cell(numRow, 1);
    hemi = cell(numRow, 1);
    r = 1;
    for i_cond = 1:numCond
        for i_comp = 1:numComp
            for i_hemi = 1:numHemi
                cond{r} = cond_u{i_cond};
                comp{r} = comp_u{i_comp};
                hemi{r} = hemi_u{i_hemi};
                
                for g = 1:numGrp

                    idx = cond_s == i_cond & comp_s == i_comp & hemi_s == i_hemi & grp_s == g;
                    m(r, g) = sum(~tab_mes.val(idx));
                    
                end
                
                    r = r + 1;
                
            end
        end
    end
    
    tab_peak = array2table(m, 'VariableNames', fixTableVariableNames(grp_u));
    tab_peak = [cell2table([cond, comp, hemi], 'VariableNames', {'cond', 'comp', 'hemi'}), tab_peak];
    
    writetable(tab_peak, sprintf('LEAP_EEG_faces_analysisDropout_peaks_%s.xlsx', datestr(now, 30)), 'WriteRowNames', true)            
        
% peak dropout (just P7/P8/N170)

    idx_rem = ~strcmpi(tab_mes.comp, 'N170p') | ~strcmpi(tab_mes.cond, 'face_up');
    tab_mes(idx_rem, :) = [];
    
    [id_u, ~, id_s] = unique(tab_mes.ID);
    
    m = accumarray(id_s, tab_mes.val, [], @sum);
    valPeaks = m == 2;
    tab_peaks = table;
    tab_peaks.ID = id_u;
    tab_peaks.val = valPeaks;
    tab_peaks = LEAP_appendMetadata(tab_peaks, 'ID');
    
    [grp_u, ~, grp_s] = unique(tab_peaks.group);
    numGrp = length(grp_u);
    m = accumarray(grp_s, ~tab_peaks.val, [], @sum);
    m_valid = accumarray(grp_s, tab_peaks.val, [], @sum);
    tab_peak_n170 = array2table([m, m_valid], 'VariableNames', {'Peaks', 'Vavlid'}, 'RowNames', grp_u);

    writetable(tab_peak_n170, sprintf('LEAP_EEG_faces_analysisDropout_peaks_N170_%s.xlsx', datestr(now, 30)), 'WriteRowNames', true)            
    
% calculate clinical scores based upon inclusion

    wantedVars = {...
        'clin_vabsdscoresc_dss'          ,...
        'clin_vabsdscoresd_dss'          ,...
        'clin_vabsdscoress_dss'          ,...
        'clin_ADI_soc'                   ,...
        'clin_ADI_com'                   ,...
        'clin_ADI_rrb'                   ,...   
        'clin_CSS_total_all'             ,...
        'clin_SA_CSS_all'                ,...
        'clin_RRB_CSS_all'               ,...   
        'age_years'                      ,...   
        'clin_viq'                       ,...
        'clin_piq'                       ,...
        'clin_dawba_ext'                 };
    
    tab_clin = readtable('/Volumes/Projects/LEAP/EEG/faces/LEAP_EEG_faces_allData.xlsx');
    
    %     % convert age to years
%     tab_clin.age_years = tab_clin.clin_age / 365;
    
    % IDs to string
    tab_clin.ID = arrayfun(@num2str, tab_clin.ID, 'UniformOutput', false);
    tab_clin = LEAP_appendMetadata(tab_clin, 'ID');
    tab_clin = LEAP_recode(tab_clin);
    
    % remove cambridge
    idx_rem = strcmpi(tab_clin.site, 'Cambridge');
    tab_clin(idx_rem, :) = [];
    
    % find IDs of those with valid peaks and clean data
    [id_u, ~, id_s] = unique(tab_mes.ID);
    m = accumarray(id_s, tab_mes.val & tab_mes.include, [], @sum);
    allVal = m == 2;
    ids_val = id_u(allVal);
    
    % get the index of valid IDs in the clinical table
    idx_clinVal = ismember(tab_clin.ID, ids_val);
    tab_clin.include = false(size(tab_clin, 1), 1);
    tab_clin.include(idx_clinVal) = true;
    
    % get group and age group subs
    [grp_u, ~, grp_s] = unique(tab_clin.diag);
    [age_u, ~, age_s] = unique(tab_clin.agegrp);
    incl_s = idx_clinVal + 1;
    
    % filter for wanted vars only
    tab_clin = tab_clin(:, wantedVars);
    
    % remove missing
    dat = tab_clin{:, :};
    dat(dat == 999) = nan;
    tab_clin{:, :} = dat;
    
    tab = table;
    for v = 1:length(wantedVars)
        
        % calculate means and SDs
        m = accumarray([grp_s, incl_s], tab_clin.(wantedVars{v}), [], @nanmean);
        sd = accumarray([grp_s, incl_s], tab_clin.(wantedVars{v}), [], @nanstd);
        
        % format as mean (sd)
        c = arrayfun(@(m, sd) sprintf('%.1f (%.1f)', m, sd), m, sd, 'UniformOutput', false);
        
        % do t-test
        idx_asd_incl = grp_s == 1 & incl_s == 2;
        idx_asd_excl = grp_s == 1 & incl_s == 1;
        idx_nt_incl = grp_s == 2 & incl_s == 2;
        idx_nt_excl = grp_s == 2 & incl_s == 1;
        [~, p_asd, ~, stats_asd] = ttest2(tab_clin.(wantedVars{v})(idx_asd_incl),...
            tab_clin.(wantedVars{v})(idx_asd_excl));
        [~, p_nt, ~, stats_nt] = ttest2(tab_clin.(wantedVars{v})(idx_nt_incl),...
            tab_clin.(wantedVars{v})(idx_nt_excl));
        
        % format t-test
        str_t_asd = sprintf('t(%d)=%.2f, p=%.3f', stats_asd.df,...
            abs(stats_asd.tstat), p_asd);
        str_t_nt = sprintf('t(%d)=%.2f, p=%.3f', stats_nt.df,...
            abs(stats_nt.tstat), p_nt);
        
        % arrange in [asd_incl, asd_excl, asd_test, td_incl, td_excl,
        % td_ttest)
        c = [c(1, :), str_t_asd, c(2, :), str_t_nt];
        tmp = cell2table(c, 'VariableNames', {'ASD_Excluded', 'ASD_Included', 'ASD_ttest', 'NT_Excluded', 'NT_Included', 'NT_ttest'});
        tmp.scale = wantedVars(v);
        tab = [tab; tmp];
        
    end
    tab = movevars(tab, 'scale', 'Before', 'ASD_Excluded');
    
    writetable(tab, 'LEAP_EEG_faces_exclusion_clin.xlsx');
%   
%     % use peak validity table to find IDs with valid peaks
%     
%     
%     
%     
%     
%     
%     
%     % load completion data
%     tab_complete = readtable('/Volumes/Projects/LEAP/_preproc/in/eeg/LEAP_EEG_master.preproc.xlsx', 'Sheet', 'Sheet1');
%     tab_complete.Properties.VariableNames{'Clinical_Subjects'} = 'ID';
%     
%     % filter completion data to remove cambridge IDs 
%     idx_rem = strcmpi(tab_complete.site, 'Cambridge');
%     tab_complete(idx_rem, :) = [];
%     
%     % remove irrelevant vars from complete data
%     tab_complete = tab_complete(:, {'ID', 'notdone'});
%     
% %     % remove no EEG
% %     idx_noeeg = tab_clin.Face_up_tpc == 999;
% %     tab_clin(idx_noeeg, :) = [];
%     
%     % table of ID and peak validity
%     tab_incl = tab_peaks(:, 1:2);
%     tab_incl.Properties.VariableNames{'val'} = 'val_peak_n170';
%     
%     % table of ID and criteria 
%     tab_met = table;
%     tab_met.ID = res.ID;
%     tab_met.met_crit = met;
%     
%     % join tables
%     tab_val = innerjoin(tab_met, tab_incl, 'Keys', 'ID');
%     tab_val.met_and_val_peaks = tab_val.met_crit & tab_val.val_peak_n170;
%     
%     % pipeline dropout - clinical data with pipeline failures
%     tab_clin.ID = arrayfun(@num2str, tab_clin.ID, 'UniformOutput', false);
%     tab_clin_pipeline = innerjoin(tab_clin, tab_val, 'Keys', 'ID');
%     
%     % completion dropout - clinical data with completion failures
%     tab_clin_complete = innerjoin(tab_clin, tab_complete, 'Keys', 'ID');
%     
%     % get subscripts for incomplete reason
%     [reason_u, ~, reason_s] = unique(tab_clin_complete.reason_code);
%     reason_u{1} = 'Completed';
%     
%     % make small table from clinical data of just wanted vars
%     tab_clin_complete_small = tab_clin_complete(:, wantedVars);
%     
% 
%     % add reason
%     tab_clin_complete_small.reason = tab_clin_complete.reason_code;
%     writetable(tab_clin_complete_small, 'LEAP_EEG_faces_clindrop_complete.xlsx')
%     
%     % calculate mean from all wanted vars for each reason
%     mu = nan(length(reason_u), length(wantedVars));
%     sd = nan(length(reason_u), length(wantedVars));
%     for i = 1:length(wantedVars)
%         mu(:, i) = accumarray(reason_s, tab_clin_complete_small{:, i}, [], @nanmean);
%         sd(:, i) = accumarray(reason_s, tab_clin_complete_small{:, i}, [], @nanstd);
%     end
%     c = arrayfun(@(mu, sd) sprintf('%.1f (%.1f)', mu, sd), mu, sd, 'UniformOutput', false);
%     tab_clin_dropout_comp = cell2table(c, 'RowNames', reason_u,...
%         'VariableNames', wantedVars);
    

    
    
    
    

