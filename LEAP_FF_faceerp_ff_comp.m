set(0,'defaultAxesFontSize',20)

% fleeting films

    file_ff = '/Users/luke/Google Drive/Experiments/face erp/may19/LEAP_ET_FF_results.xlsx';
    ff = readtable(file_ff);
    
    % convert IDs to string
    ff.id = arrayfun(@num2str, ff.subjects, 'uniform', false);
    
    % just the vars we want
    ff = ff(:, {'id', 'z_acc_ff', 'z_acc_rmet', 'Mick_ASD_clusters', 'perf_ff'});
    
    % convert 'NA' to NaN for z_acc score
    idx_missing = contains(ff.z_acc_ff, 'NA');
    z_acc_ff = cellfun(@str2num, ff.z_acc_ff, 'UniformOutput', false);
    z_acc_ff(idx_missing) = repmat({nan}, sum(idx_missing), 1);
    ff.z_acc_ff = cell2mat(z_acc_ff);
    
    % convert 'NA' to NaN for clusters
    idx_missing = contains(ff.Mick_ASD_clusters, 'NA');
    clus = cellfun(@str2num, ff.Mick_ASD_clusters, 'UniformOutput', false);
    clus(idx_missing) = repmat({nan}, sum(idx_missing), 1);
    ff.Mick_ASD_clusters = cell2mat(clus);
    
% face ERP

    file_faces = teFindFile('/Users/luke/Google Drive/Experiments/face erp', 'LEAP_EEG_faces_measures*.mat', '-latest');
    load(file_faces)

    idx = strcmpi(tab_mes.cond, 'face_up') & strcmpi(tab_mes.elec, 'P7') & strcmpi(tab_mes.comp, 'N170p');
    faces = tab_mes(idx, :);
    faces.Properties.VariableNames{'ID'} = 'id';
    
% nat scenes

    file_ns = '/Volumes/Projects/LEAP/_preproc/out/et/bl/06_results/ns_combined/LEAP_ET_ns_combined_results_20200424T134039.xlsx';
    ns = readtable(file_ns);
    
    ns(~ns.include, :) = [];
    ns = ns(:, {'id', 'video', 'z_face_peakLook', 'z_face_propInAOI', 'z_body_peakLook', 'z_body_propInAOI'});
    ns = aggregateTable(ns, 'id', {'z_face_peakLook', 'z_face_propInAOI', 'z_body_peakLook', 'z_body_propInAOI'}, @nanmean);
    ns.video = [];
    ns.face_body_ratio_plt = ns.z_face_propInAOI + (ns.z_face_propInAOI + ns.z_body_propInAOI);
    ns.face_body_ratio_pld = ns.z_face_peakLook + (ns.z_face_peakLook + ns.z_body_peakLook);

% join data
tab = innerjoin(faces, ff, 'Keys', 'id');
tab = innerjoin(tab, ns, 'Keys', 'id');


%% plot EEG

figure
idx_asd = cellfun(@(x) contains(x, 'ASD'), tab.group);
cols = lines(2);
subplot(2, 2, 1)
hold on
    
    mdl_mamp_asd = fitlm(tab.mamp(idx_asd), tab.z_acc_ff(idx_asd), 'linear');
    mdl_mamp_nt = fitlm(tab.mamp(~idx_asd), tab.z_acc_ff(~idx_asd), 'linear');
    
    pl = plot(mdl_mamp_asd);
    pl(1).Color = cols(1, :);
    pl(2).Color = cols(1, :);
    pl(3).Color = cols(1, :);
    pl(4).Color = cols(1, :);
    
    pl = plot(mdl_mamp_nt);
    pl(1).Color = cols(2, :);
    pl(2).Color = cols(2, :);
    pl(3).Color = cols(2, :);
    pl(4).Color = cols(2, :);    
    
    strLeg_ASD = sprintf('ASD Fit (R2=%.2f, p=%.3f)', mdl_mamp_asd.Rsquared.Ordinary,...
        mdl_mamp_asd.Coefficients.pValue(2));
    strLeg_NT = sprintf('NT Fit (R2=%.2f, p=%.3f)', mdl_mamp_nt.Rsquared.Ordinary,...
        mdl_mamp_nt.Coefficients.pValue(2));
    
    legend('ASD Data', strLeg_ASD, 'ASD Lower Bound', 'ASD Upper Bound',...
        'NT Data', strLeg_NT, 'NT Lower Bound', 'NT Upper Bound')
    title('N170 Mean Amplitude')
    xlabel('N170 Mean Amplitude (µV)')
    ylabel('Z_FF Accuracy')
    
subplot(2, 2, 2)
hold on

    mdl_lat_asd = fitlm(tab.lat(idx_asd), tab.z_acc_ff(idx_asd), 'linear');
    mdl_lat_nt = fitlm(tab.lat(~idx_asd), tab.z_acc_ff(~idx_asd), 'linear');
    
    pl = plot(mdl_lat_asd);
    pl(1).Color = cols(1, :);
    pl(2).Color = cols(1, :);
    pl(3).Color = cols(1, :);
    pl(4).Color = cols(1, :);
    
    pl = plot(mdl_lat_nt);
    pl(1).Color = cols(2, :);
    pl(2).Color = cols(2, :);
    pl(3).Color = cols(2, :);
    pl(4).Color = cols(2, :);    
    
    strLeg_ASD = sprintf('ASD Fit (R2=%.2f, p=%.3f)', mdl_lat_asd.Rsquared.Ordinary,...
        mdl_lat_asd.Coefficients.pValue(2));
    strLeg_NT = sprintf('NT Fit (R2=%.2f, p=%.3f)', mdl_lat_nt.Rsquared.Ordinary,...
        mdl_lat_nt.Coefficients.pValue(2));    
    
    legend('ASD Data', strLeg_ASD, 'ASD Lower Bound', 'ASD Upper Bound',...
        'NT Data', strLeg_NT, 'NT Lower Bound', 'NT Upper Bound')   
    title('N170 Latency')
    xlabel('N170 Latency (s)')
    ylabel('Z_FF Accuracy')
    
idx_c1 = tab.Mick_ASD_clusters == 1;
idx_c2 = tab.Mick_ASD_clusters == 2;
subplot(2, 2, 3)
hold on

    y = tab.mamp;
    g = tab.Mick_ASD_clusters;
    idx_missing = isnan(y) | isnan(g);
    y(idx_missing) = [];
    g(idx_missing) = [];
    notBoxPlot(y, g)
    
    [~, p, ~, stats] = ttest2(y(g == 1), y(g == 2));
    sd_pooled = sdpooled(y(g == 1), y(g == 2));
    mu = [mean(y(g == 1)), mean(y(g == 2))];
    d = diff(mu) / sd_pooled;
    title(sprintf('Cluster N170 Mean Amplitude | t(%d)=%.2f, p=%.3f, d=%.2f)',...
        stats.df, stats.tstat, p, d));
    xlabel('Cluster')
    ylabel('N170 Mean Amplitude (µV)')

subplot(2, 2, 4)
hold on

    y = tab.lat;
    g = tab.Mick_ASD_clusters;
    idx_missing = isnan(y) | isnan(g);
    y(idx_missing) = [];
    g(idx_missing) = [];
    notBoxPlot(y, g)
    
    [~, p, ~, stats] = ttest2(y(g == 1), y(g == 2));
    sd_pooled = sdpooled(y(g == 1), y(g == 2));
    mu = [mean(y(g == 1)), mean(y(g == 2))];
    d = diff(mu) / sd_pooled;
    title(sprintf('Cluster N170 Mean Latency | t(%d)=%.2f, p=%.3f, d=%.2f)',...
        stats.df, stats.tstat, p, d));
    xlabel('Cluster')
    ylabel('N170 Latency(s)')
    
%% plot ns

figure
subplot(2, 2, 1)
hold on
    
    mdl_plt_asd = fitlm(tab.face_body_ratio_plt(idx_asd), tab.z_acc_ff(idx_asd), 'linear');
    mdl_plt_nt = fitlm(tab.face_body_ratio_plt(~idx_asd), tab.z_acc_ff(~idx_asd), 'linear');
    
    pl = plot(mdl_plt_asd);
    pl(1).Color = cols(1, :);
    pl(2).Color = cols(1, :);
    pl(3).Color = cols(1, :);
    pl(4).Color = cols(1, :);
    
    pl = plot(mdl_plt_nt);
    pl(1).Color = cols(2, :);
    pl(2).Color = cols(2, :);
    pl(3).Color = cols(2, :);
    pl(4).Color = cols(2, :);    
    
    strLeg_ASD = sprintf('ASD Fit (R2=%.2f, p=%.3f)', mdl_plt_asd.Rsquared.Ordinary,...
        mdl_plt_asd.Coefficients.pValue(2));
    strLeg_NT = sprintf('NT Fit (R2=%.2f, p=%.3f)', mdl_plt_nt.Rsquared.Ordinary,...
        mdl_plt_nt.Coefficients.pValue(2));
    
    legend('ASD Data', strLeg_ASD, 'ASD Lower Bound', 'ASD Upper Bound',...
        'NT Data', strLeg_NT, 'NT Lower Bound', 'NT Upper Bound')
    title('N170 Mean Amplitude')
    xlabel('N170 Mean Amplitude (µV)')
    ylabel('Z_FF Accuracy')
    
subplot(2, 2, 2)
hold on

    mdl_pld_asd = fitlm(tab.face_body_ratio_pld(idx_asd), tab.z_acc_ff(idx_asd), 'linear');
    mdl_pld_nt = fitlm(tab.face_body_ratio_pld(~idx_asd), tab.z_acc_ff(~idx_asd), 'linear');
    
    pl = plot(mdl_pld_asd);
    pl(1).Color = cols(1, :);
    pl(2).Color = cols(1, :);
    pl(3).Color = cols(1, :);
    pl(4).Color = cols(1, :);
    
    pl = plot(mdl_pld_nt);
    pl(1).Color = cols(2, :);
    pl(2).Color = cols(2, :);
    pl(3).Color = cols(2, :);
    pl(4).Color = cols(2, :);    
    
    strLeg_ASD = sprintf('ASD Fit (R2=%.2f, p=%.3f)', mdl_pld_asd.Rsquared.Ordinary,...
        mdl_pld_asd.Coefficients.pValue(2));
    strLeg_NT = sprintf('NT Fit (R2=%.2f, p=%.3f)', mdl_pld_nt.Rsquared.Ordinary,...
        mdl_pld_nt.Coefficients.pValue(2));    
    
    legend('ASD Data', strLeg_ASD, 'ASD Lower Bound', 'ASD Upper Bound',...
        'NT Data', strLeg_NT, 'NT Lower Bound', 'NT Upper Bound')   
    title('N170 Latency')
    xlabel('N170 Latency (s)')
    ylabel('Z_FF Accuracy')
    
idx_c1 = tab.Mick_ASD_clusters == 1;
idx_c2 = tab.Mick_ASD_clusters == 2;
subplot(2, 2, 3)
hold on

    y = tab.face_body_ratio_plt;
    g = tab.Mick_ASD_clusters;
    idx_missing = isnan(y) | isnan(g);
    y(idx_missing) = [];
    g(idx_missing) = [];
    notBoxPlot(y, g)
    
    [~, p, ~, stats] = ttest2(y(g == 1), y(g == 2));
    sd_pooled = sdpooled(y(g == 1), y(g == 2));
    mu = [mean(y(g == 1)), mean(y(g == 2))];
    d = diff(mu) / sd_pooled;
    title(sprintf('Body-Face Ratio, Prop. Looking Time | t(%d)=%.2f, p=%.3f, d=%.2f)',...
        stats.df, stats.tstat, p, d));
    xlabel('Cluster')
    ylabel('Body-Face Ratio, Prop. Looking Time')

subplot(2, 2, 4)
hold on

    y = tab.face_body_ratio_pld;
    g = tab.Mick_ASD_clusters;
    idx_missing = isnan(y) | isnan(g);
    y(idx_missing) = [];
    g(idx_missing) = [];
    notBoxPlot(y, g)
    
    [~, p, ~, stats] = ttest2(y(g == 1), y(g == 2));
    sd_pooled = sdpooled(y(g == 1), y(g == 2));
    mu = [mean(y(g == 1)), mean(y(g == 2))];
    d = diff(mu) / sd_pooled;
    title(sprintf('Body-Face Ratio, Peak Look Duration | t(%d)=%.2f, p=%.3f, d=%.2f)',...
        stats.df, stats.tstat, p, d));
    xlabel('Cluster')
    ylabel('Body-Face Ratio, Peak Look Duration (s)')    
    
% save data
tab.erp_avg = [];
tab.erp_time = [];
file_out = '/Users/luke/Google Drive/Experiments/face erp/may19/LEAP_faces_FF.xlsx';
writetable(tab, file_out);