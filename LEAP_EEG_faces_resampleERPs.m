addpath(genpath('/Users/luke/Google Drive/Dev/lm_tools'))
addpath('/Users/luke/Google Drive/Dev/ECKAnalyse/')
addpath('/users/luke/Google Drive/Experiments/LEAP/Baseline/')
addpath('/users/luke/Google Drive/Dev/fieldtrip-20180320/')
ft_defaults
ac = teAnalysisClient;
ac.ConnectToServer('lm-analysis.local', 3000)
ac.HoldQuery = {'Study', 'LEAP', 'faceerp_avged', true, 'Site', 'Mannheim'};
md = ac.Metadata;

for i = 1:ac.NumDatasets
    
    erps = ac.GetVariable('faceerp_avg30', 'GUID', md{i}.GUID);
    
    cfg.resamplefs = 1000;
    changed = false;
    
    if isfield(erps, 'face_up') &&...
            abs(1 / mean(diff(erps.face_up.time)) - 1000) > 1
        erps.face_up = ft_resampledata(cfg, erps.face_up);
        changed = true;
    end
    
    if isfield(erps, 'face_inv') &&...
            abs(1 / mean(diff(erps.face_inv.time)) - 1000) > 1
        erps.face_inv = ft_resampledata(cfg, erps.face_inv);
        changed = true;
    end
    
    if changed
        file_tmp = fullfile(tempdir, sprintf('%s_erptmp.mat', md{i}.GUID));
        save(file_tmp, 'erps')
        ac.UploadExternalData(md{i}, 'faceerp_avg30', file_tmp);
        delete(file_tmp)
    end
    
end