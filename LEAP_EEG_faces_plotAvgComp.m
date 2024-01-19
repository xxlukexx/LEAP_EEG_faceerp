path_avg30 = '/Volumes/Projects/LEAP/EEG/faces/20181214/04_avg30';
path_avg40 = '/Volumes/Projects/LEAP/EEG/faces/20170817/04_avg';
path_plot = '/Volumes/Projects/LEAP/EEG/faces/20170817/avgcomp';
tryToMakePath(path_plot)

d30 = dir(path_avg30);
d40 = dir(path_avg40);

d30 = struct2table(d30);
d40 = struct2table(d40);

parts = cellfun(@(x) strsplit(x, '.'), d30.name, 'uniform', false);
d30.id = cellfun(@(x) x{1}, parts, 'uniform', false);

parts = cellfun(@(x) strsplit(x, '.'), d40.name, 'uniform', false);
d40.id = cellfun(@(x) x{1}, parts, 'uniform', false);

idx_rem = strcmpi(d30.id, '') | strcmpi(d30.id, '_results');
d30(idx_rem, :) = [];

idx_rem = strcmpi(d40.id, '') | strcmpi(d40.id, '_results');
d40(idx_rem, :) = [];

[~, i] = unique(d30.id);
d30 = d30(i, :);

[~, i] = unique(d40.id);
d40 = d40(i, :);

d = innerjoin(d30, d40, 'Keys', 'id');
d = LEAP_appendMetadata(d, 'id');

parfor f = 1:size(d, 1)
    
    fprintf('<strong>\n\n\n\n\n\n\n\t\t\t\tPROGRESS: %d of %d (%.2f%%)...\n</strong>', f, size(d, 1), f / size(d, 1))
    
    fig = figure('units', 'normalized', 'position', [0, 0, 1, 1])
    
    try

        erp30 = load(fullfile(d.folder_d30{f}, d.name_d30{f}));
        erp40 = load(fullfile(d.folder_d40{f}, d.name_d40{f}));


        cfg = [];
        cfg.detrend = 'yes';
        erp30.erps.face_up = ft_preprocessing(cfg, erp30.erps.face_up);
        erp40.erps.face_up = ft_preprocessing(cfg, erp40.erps.face_up);

        str = sprintf('%s\n%s\ntpc up 30: %d\ntpc up 40: %d\ntpc change:%d', d.id{f}, d.site{f},...
            erp30.erps.summary.tpc_up, erp40.erps.summary.tpc_up, erp40.erps.summary.tpc_up - erp30.erps.summary.tpc_up);

        cfg = [];
        cfg.baseline = [-.2, 0];
        cfg.showlabels = true;
        subplot(2, 2, 1)
        cfg.channel = 'P7';
        ft_singleplotER(cfg,  erp30.erps.face_up, erp40.erps.face_up)

        subplot(2, 2, 2)
        cfg.channel = 'P8';
        ft_singleplotER(cfg,  erp30.erps.face_up, erp40.erps.face_up)

        subplot(2, 2, 3)
        cfg.channel = 'O1';
        ft_singleplotER(cfg,  erp30.erps.face_up, erp40.erps.face_up)

        subplot(2, 2, 4)
        cfg.channel = 'O2';
        ft_singleplotER(cfg,  erp30.erps.face_up, erp40.erps.face_up)

        an = annotation('textbox', [0, .9, .5, .1], 'String', str, 'FontSize', 30,...
            'Color', 'r');

        file_plot = fullfile(path_plot, sprintf('%s.png', d.id{f}));
        export_fig(file_plot)
        
    catch ERR
        
        fprintf('Error on %s: %s', d{f}.id, ERR.message);
        
    end
    
    close all
    
end
    %     ft_multiplotER(cfg, erp30.erps.face_up, erp40.erps.face_up)

    