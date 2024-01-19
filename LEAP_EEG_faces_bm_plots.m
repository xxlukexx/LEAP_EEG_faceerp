addpath('/Users/luke/Google Drive/Dev/eegtools')
addpath('/users/luke/Google Drive/Experiments/LEAP/Baseline/')
addpath('/Users/luke/Google Drive/Dev/ECKAnalyse/')
addpath(genpath('/Users/luke/Google Drive/Dev/lm_tools'))

load('/Users/luke/Google Drive/Experiments/face erp/mar18/LEAP_EEG_faces_measures_20190308T175201.mat')
path_fig = '/Users/luke/Google Drive/Experiments/face erp/mar18';

fontsize = 24;

% filter table
tab_lat = tab_mes;
idx_asdtd = strcmpi(tab_lat.group, 'ASD') | strcmpi(tab_lat.group, 'TD');
tab_lat = tab_lat(idx_asdtd, :);
idx_include = logical(tab_lat.include) & tab_lat.val;
tab_lat = tab_lat(idx_include, :);
idx_upright = strcmpi(tab_lat.cond, 'face_up');
tab_lat = tab_lat(idx_upright, :);

% ERPs
    
    % 1. whole sample
    [fig_erp, fig_bp, ~, ~, res_t] = eegPlotFactorialGA2(tab_lat, 'N170p',...
        'compare', 'group', 'cols', 'hemi', 'plotBoxPlot', true,...
        'fontsize', fontsize, 'ttest', true);
    set(fig_erp, 'Position', [0, 700, 1600, 450])
    set(fig_bp, 'Position', [0, 700, 1600, 450])

    file_out_erp = fullfile(path_fig, 'N170_lat_whole_sample_erp.png');
    export_fig(fig_erp, file_out_erp, '-r150')
    
    file_out_bp = fullfile(path_fig, 'N170_lat_whole_sample_bp.png');
    export_fig(fig_bp, file_out_bp, '-r150')
    
    close all
    
    % 2. children
    idx_kids = tab_lat.age_years < 13;
    tab_kids_lat = tab_lat(idx_kids, :);
    
    [fig_erp, fig_bp] = eegPlotFactorialGA2(tab_kids_lat, 'N170p',...
        'compare', 'group', 'cols', 'hemi', 'plotBoxPlot', true,...
        'fontsize', fontsize, 'plotHist', false, 'ttest', true);
    set(fig_erp, 'Position', [0, 700, 1600, 450])
    set(fig_bp, 'Position', [0, 700, 1600, 450])

    file_out_erp = fullfile(path_fig, 'N170_lat_kids_erp.png');
    export_fig(fig_erp, file_out_erp, '-r150')
    
    file_out_bp = fullfile(path_fig, 'N170_lat_kids_bp.png');
    export_fig(fig_bp, file_out_bp, '-r150')
    
    close all
    
    % 2. adolescents
    idx_adol = tab_lat.age_years >= 13 & tab_lat.age_years < 18;
    tab_kids_lat = tab_lat(idx_adol, :);
    
    [fig_erp, fig_bp] = eegPlotFactorialGA2(tab_kids_lat, 'N170p',...
        'compare', 'group', 'cols', 'hemi', 'plotBoxPlot', true,...
        'fontsize', fontsize, 'plotHist', false, 'ttest', true);
    set(fig_erp, 'Position', [0, 700, 1600, 450])
    set(fig_bp, 'Position', [0, 700, 1600, 450])

    file_out_erp = fullfile(path_fig, 'N170_lat_adol_erp.png');
    export_fig(fig_erp, file_out_erp, '-r150')
    
    file_out_bp = fullfile(path_fig, 'N170_lat_adol_bp.png');
    export_fig(fig_bp, file_out_bp, '-r150')
    
    close all
    
    % 3. site
    [fig_erp, fig_bp] = eegPlotFactorialGA2(tab_lat, 'N170p',...
        'compare', 'group', 'cols', 'site', 'plotBoxPlot', true,...
        'fontsize', 12, 'plotHist', false, 'rows', 'hemi', 'ttest', true);
    delete(fig_erp)
    set(fig_bp, 'Position', [0, 0, 1400, 900])

    file_out_bp = fullfile(path_fig, 'N170_lat_site.png');
    export_fig(fig_bp, file_out_bp, '-r150')
    
    close all
    
    % 4. gender
    [fig_erp, fig_bp] = eegPlotFactorialGA2(tab_lat, 'N170p',...
        'compare', 'group', 'cols', 'hemi', 'plotBoxPlot', true,...
        'fontsize', fontsize, 'rows', 'sex', 'ttest', true);
    set(fig_erp, 'Position', [967         127         824        1050])
    set(fig_bp, 'Position', [967         127         824        1050])

    file_out_erp = fullfile(path_fig, 'N170_lat_sex_erp.png');
    export_fig(fig_erp, file_out_erp, '-r150')
    
    file_out_bp = fullfile(path_fig, 'N170_lat_sex_bp.png');
    export_fig(fig_bp, file_out_bp, '-r150')
    
    close all
    
    % 5. strict diagnostic criteria
    idx_thresh = ~strcmpi(tab_lat.asd_thresh, '777') &...
        ~strcmpi(tab_lat.asd_thresh, 'N/A');
    tab_lat_thresh = tab_lat(idx_thresh, :);
    
    [fig_erp, fig_bp] = eegPlotFactorialGA2(tab_lat_thresh, 'N170p',...
        'compare', 'asd_thresh', 'cols', 'hemi', 'plotBoxPlot', true,...
        'fontsize', fontsize, 'plotHist', true, 'ttest', true);
    set(fig_erp, 'Position', [0, 700, 1600, 450])
    set(fig_bp, 'Position', [0, 700, 1600, 450])

    file_out_erp = fullfile(path_fig, 'N170_lat_thresh_erp.png');
    export_fig(fig_erp, file_out_erp, '-r150')
    
    file_out_bp = fullfile(path_fig, 'N170_lat_thresh_bp.png');
    export_fig(fig_bp, file_out_bp, '-r150')
    
    close all    
    
    % 6. strict tpc - just ASD
    idx_tpc = tab_lat.tpc >= 50;
    tab_lat_tpc = tab_lat;
    tab_lat_tpc.HighTPC = repmat({'No'}, size(tab_lat_tpc, 1), 1);
    tab_lat_tpc.HighTPC(idx_tpc) = repmat({'Yes'}, sum(idx_tpc), 1);
    idx_asd = strcmpi(tab_lat_tpc.group, 'ASD');
    tab_lat_tpc = tab_lat_tpc(idx_asd, :);
    
    [fig_erp, fig_bp] = eegPlotFactorialGA2(tab_lat_tpc, 'N170p',...
        'compare', 'HighTPC', 'cols', 'hemi', 'plotBoxPlot', true,...
        'fontsize', fontsize, 'plotHist', true, 'ttest', true);
    set(fig_erp, 'Position', [0, 700, 1600, 450])
    set(fig_bp, 'Position', [0, 700, 1600, 450])

    file_out_erp = fullfile(path_fig, 'N170_lat_tpc_erp.png');
    export_fig(fig_erp, file_out_erp, '-r150')
    
    file_out_bp = fullfile(path_fig, 'N170_lat_tpc_bp.png');
    export_fig(fig_bp, file_out_bp, '-r150')
    
    close all       
    
%     % 7. double peaks
%     idx_asd = strcmpi(tab_lat.group, 'ASD');
%     tab_lat_dbl = tab_lat(idx_asd, :);
%     
%     [fig_erp, fig_bp] = eegPlotFactorialGA2(tab_lat_dbl, 'N170p',...
%         'compare', 'val_code', 'cols', 'hemi', 'plotBoxPlot', true,...
%         'fontsize', 24, 'plotHist', false);
%     set(fig_erp, 'Position', [0, 700, 1600, 450])
%     set(fig_bp, 'Position', [0, 700, 1600, 450])
% 
%     file_out_erp = fullfile(path_fig, 'N170_lat_tpc_erp.png');
%     export_fig(fig_erp, file_out_erp, '-r150')
%     
%     file_out_bp = fullfile(path_fig, 'N170_lat_tpc_bp.png');
%     export_fig(fig_bp, file_out_bp, '-r150')
%     
%     close all       
    
    % 8. no meds
    idx_nomed = ~strcmpi(tab_lat.med_use, '1');
    tab_lat_med = tab_lat(idx_nomed, :);
    
    [fig_erp, fig_bp] = eegPlotFactorialGA2(tab_lat_med, 'N170p',...
        'compare', 'group', 'cols', 'hemi', 'plotBoxPlot', true,...
        'fontsize', fontsize, 'plotHist', false, 'ttest', true);
    set(fig_erp, 'Position', [0, 700, 1600, 450])
    set(fig_bp, 'Position', [0, 700, 1600, 450])

    file_out_erp = fullfile(path_fig, 'N170_lat_meds_erp.png');
    export_fig(fig_erp, file_out_erp, '-r150')
    
    file_out_bp = fullfile(path_fig, 'N170_lat_meds_bp.png');
    export_fig(fig_bp, file_out_bp, '-r150')
    
    close all    
    
    % 9. schedule LH
    idx_sched = strcmpi(tab_lat.hemi, 'left');
    tab_sched = tab_lat(idx_sched, :);
    
    [fig_erp, fig_bp] = eegPlotFactorialGA2(tab_sched, 'N170p',...
        'compare', 'group', 'cols', 'schedule_adj', 'plotBoxPlot', true,...
        'fontsize', fontsize, 'plotHist', false, 'ttest', true);
    set(fig_erp, 'Position', [0, 700, 1600, 450])
    set(fig_bp, 'Position', [0, 700, 1600, 450])

    file_out_erp = fullfile(path_fig, 'N170_lat_sched_erp.png');
    export_fig(fig_erp, file_out_erp, '-r150')
    
    file_out_bp = fullfile(path_fig, 'N170_lat_sched_bp.png');
    export_fig(fig_bp, file_out_bp, '-r150')
    
    close all    
    
    
% age fit
    
    fig_age = figure('name', 'Age Fit');
    set(fig_age, 'defaultaxesfontsize', fontsize);
    
    idx_asd = strcmpi(tab_lat.group, 'ASD');
    idx_td = strcmpi(tab_lat.group, 'TD');
    
    [hemi_u, ~, hemi_s] = unique(tab_lat.hemi);
    
    cols = lines(2);
    
    % left hemi
    subplot(1, 2, 1)
    
        % TD
        idx = hemi_s == 1 & idx_td;
        [ft_age_left_td, gof_age_left_td] = fit(tab_lat.age_years(idx),...
            tab_lat.lat(idx), 'poly1');
        scatter(tab_lat.age_years(idx), tab_lat.lat(idx), [], cols(2, :))
        hold on 
        pl = plot(ft_age_left_td);
        pl.Color = cols(2, :);
        pl.LineWidth = 3;
        xlabel('Age')
        ylabel('N170 latency (s)')
    
        % ASD
        idx = hemi_s == 1 & idx_asd;
        [ft_age_left_asd, gof_age_left_asd] = fit(tab_lat.age_years(idx),...
            tab_lat.lat(idx), 'poly1');
        scatter(tab_lat.age_years(idx), tab_lat.lat(idx), [], cols(1, :))
        pl = plot(ft_age_left_asd);
        pl.Color = cols(1, :);
        pl.LineWidth = 3;
        xlabel('Age')
        ylabel('N170 latency (s)')
        
    title(hemi_u{1})
    
    legend(...
        'TD',...
        sprintf('R2=%.2f', gof_age_left_td.rsquare),...
        'ASD',...
        sprintf('R2=%.2f', gof_age_left_asd.rsquare))
    
    % right hemi
    subplot(1, 2, 2)
    
        % TD
        idx = hemi_s == 2 & idx_td;
        [ft_age_left_td, gof_age_left_td] = fit(tab_lat.age_years(idx),...
            tab_lat.lat(idx), 'poly1');
        scatter(tab_lat.age_years(idx), tab_lat.lat(idx), [], cols(2, :))
        hold on 
        pl = plot(ft_age_left_td);
        pl.Color = cols(2, :);
        pl.LineWidth = 3;
        xlabel('Age')
        ylabel('N170 latency (s)')
    
        % ASD
        idx = hemi_s == 2 & idx_asd;
        [ft_age_left_asd, gof_age_left_asd] = fit(tab_lat.age_years(idx),...
            tab_lat.lat(idx), 'poly1');
        scatter(tab_lat.age_years(idx), tab_lat.lat(idx), [], cols(1, :))
        pl = plot(ft_age_left_asd);
        pl.Color = cols(1, :);
        pl.LineWidth = 3;
        xlabel('Age')
        ylabel('N170 latency (s)')
        
    title(hemi_u{2})
   
    legend(...
        'TD',...
        sprintf('R2=%.2f', gof_age_left_td.rsquare),...
        'ASD',...
        sprintf('R2=%.2f', gof_age_left_asd.rsquare))    
    
    set(fig_age, 'position', [0, 0, 1700, 900])
    set(fig_age, 'color', 'w')
    
    file_out_age = fullfile(path_fig, 'N170_lat_age_fit.png');
    export_fig(fig_age, file_out_age, '-r150')
    
    close all
    
% clusters and warping outliers

    tab_clus = readtable('/Users/luke/Google Drive/Experiments/face erp/LEAP_EEG_faces_bm_clusterIDs.xlsx');
    
    % convert IDs to string
    tab_clus.ID = arrayfun(@num2str, tab_clus.ID, 'uniform', false);
    
    % join cluster membership info to main table
    tab_clus = join(tab_lat, tab_clus, 'Keys', 'ID');
    
    % filter for P7/O1
    idx_elec = strcmpi(tab_clus.elec, 'P7') | strcmpi(tab_clus.elec, 'O1');
    tab_clus = tab_clus(idx_elec, :);
    
    % 1. P7 by cluster
    [fig_erp, fig_bp, ~, ~, ~] = eegPlotFactorialGA2(tab_clus, 'N170p',...
        'compare', 'Gaussian', 'cols', 'group', 'plotBoxPlot', true,...
        'fontsize', fontsize, 'ttest', true, 'plotSEM', false);
    
    set(fig_erp, 'Position', [0, 700, 1600, 450])
    set(fig_bp, 'Position', [0, 700, 1600, 450])

    file_out_erp = fullfile(path_fig, 'N170_lat_clus_erp.png');
    export_fig(fig_erp, file_out_erp, '-r150')
    
    file_out_bp = fullfile(path_fig, 'N170_lat_clus_bp.png');
    export_fig(fig_bp, file_out_bp, '-r150')
    
    close all    
    
    % 2. O1 by cluster
    [fig_erp, fig_bp, ~, ~, ~] = eegPlotFactorialGA2(tab_clus, 'P1o',...
        'compare', 'Gaussian', 'cols', 'group', 'plotBoxPlot', true,...
        'fontsize', fontsize, 'ttest', true, 'plotSEM', false);
    set(fig_erp, 'Position', [0, 700, 1600, 450])
    set(fig_bp, 'Position', [0, 700, 1600, 450])

    file_out_erp = fullfile(path_fig, 'P1_lat_clus_erp.png');
    export_fig(fig_erp, file_out_erp, '-r150')
    
    file_out_bp = fullfile(path_fig, 'P1_lat_clus_bp.png');
    export_fig(fig_bp, file_out_bp, '-r150')
    
    close all        
    
    % 3. P7 by warp outlier
    [fig_erp, fig_bp, ~, ~, ~] = eegPlotFactorialGA2(tab_clus, 'N170p',...
        'compare', 'P7dispBIN', 'cols', 'group', 'plotBoxPlot', true,...
        'fontsize', fontsize, 'ttest', true, 'plotSEM', false);
    set(fig_erp, 'Position', [0, 700, 1600, 450])
    set(fig_bp, 'Position', [0, 700, 1600, 450])

    file_out_erp = fullfile(path_fig, 'N170_lat_warpol_erp.png');
    export_fig(fig_erp, file_out_erp, '-r150')
    
    file_out_bp = fullfile(path_fig, 'N170_lat_warpol_bp.png');
    export_fig(fig_bp, file_out_bp, '-r150')
    
    close all    
    
    % 4. O1 by warp outlier
    [fig_erp, fig_bp, ~, ~, ~] = eegPlotFactorialGA2(tab_clus, 'P1o',...
        'compare', 'P7dispBIN', 'cols', 'group', 'plotBoxPlot', true,...
        'fontsize', fontsize, 'ttest', true, 'plotSEM', false);
    set(fig_erp, 'Position', [0, 700, 1600, 450])
    set(fig_bp, 'Position', [0, 700, 1600, 450])

    file_out_erp = fullfile(path_fig, 'P1_lat_warpol_erp.png');
    export_fig(fig_erp, file_out_erp, '-r150')
    
    file_out_bp = fullfile(path_fig, 'P1_lat_warpol_bp.png');
    export_fig(fig_bp, file_out_bp, '-r150')
    
    close all        
    