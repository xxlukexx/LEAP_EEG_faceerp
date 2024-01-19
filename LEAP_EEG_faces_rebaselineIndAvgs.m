lm_addCommonPaths
addpath('/users/luke/Google Drive/dev/fieldtrip-20180320/')
ft_defaults

ac = teAnalysisClient;
ac.HoldQuery = {'Study', 'LEAP', 'faceerp_avged', true};
ac.ConnectToServer('localhost', 3000)

tab = ac.Table;
tab = LEAP_appendMetadata(tab, 'ID');

md_all = ac.Metadata;
guid_md = cellfun(@(x) x.GUID, md_all, 'UniformOutput', false);
if ~isequal(guid_md, tab.GUID)
    error('Table and metadata GUIDs do not match.')
end

erps = ac.GetVariable('faceerp_avg30');

% % detrend
% parfor i = 1:size(tab, 1)
%     
%     % get data and metadata
%     md = md_all{i};
%     erp = erps{i};
%     
%     if isfield(erp, 'face_up')
%         cfg = [];
%         cfg.detrend = 'yes';
%         erp.face_up = ft_preprocessing(cfg, erp.face_up);
%         cfg = [];
%         cfg.baseline = [-0.200, 0.000];
%         erp.face_up = ft_timelockbaseline(cfg, erp.face_up);        
%     end
%     
%     if isfield(erp, 'face_inv')
%         cfg = [];
%         cfg.detrend = 'yes';
%         erp.face_inv = ft_preprocessing(cfg, erp.face_inv);
%         cfg = [];
%         cfg.baseline = [-0.200, 0.000];
%         erp.face_inv = ft_timelockbaseline(cfg, erp.face_inv);        
%     end
%     
%     erps{i} = erp;
%     
%     fprintf('<strong>\t\t%d of %d...</strong>\n', i, size(tab, 1));
%  
% end

% update peaks
for i = 1:length(md_all)
    
    md = md_all{i};
    erp = erps{i};
    
    if ~isprop(md, 'peakrating'), continue, end
    pr = md.peakrating;
    
    
    % remove summary fields
    pr = rmfield(pr, {...
        'total_not_clear', 'total_dbl_peak', 'total_needs_checking'});
    
    % get fieldnames
    fnames = fieldnames(pr);
    
    % split on underscore
    parts = cellfun(@(x) strsplit(x, '_'), fnames, 'UniformOutput', false);
    
    % name is first part, before electrode (e.g. face_up_P1o)
    name = cellfun(@(x) sprintf('%s_', x{1:end - 1}), parts,...
        'UniformOutput', false);
    
    % elec is last part
    elec = cellfun(@(x) x{end}, parts, 'UniformOutput', false);
    
    % make name of mean amp fields (e.g. face_up_P1o_meanmp_P7)
    name_mamp = cellfun(@(name, elec) sprintf('%smeanamp_%s', name, elec),...
        name, elec, 'UniformOutput', false);
    
    % do same for lat and peak amp
    name_lat = cellfun(@(name, elec) sprintf('%slat_%s', name, elec),...
        name, elec, 'UniformOutput', false);   
    name_pamp = cellfun(@(name, elec) sprintf('%samp_%s', name, elec),...
        name, elec, 'UniformOutput', false); 
    
    % condition
    conds = cellfun(@(x) sprintf('%s_%s', x{1}, x{2}), parts,...
        'UniformOutput', false);
    
    % loop through names and find peaks
    numPeaks = length(name_mamp);
    for p = 1:numPeaks
        
        f_lat = name_lat{p};
        f_pamp = name_pamp{p};
        
        if isfield(md.erp_peaks, f_lat) && isfield(md.erp_peaks, f_pamp)
            
            cond = conds{p};
            erp_tmp = erp.(cond);
            idx_ch = strcmpi(elec{p}, erp_tmp.label);

            % get sample number of current peak latency
            s = find(erp_tmp.time >= md.erp_peaks.(f_lat), 1);

            % get peak amplitude of the peak
            md.erp_peaks.(f_pamp) = erp_tmp.avg(idx_ch, s);
            
            fprintf('<strong>%s %s success\n</strong>', md.ID, fnames{p})
            
        else
            
            fprintf('<strong>%s %s FAILED\n</strong>', md.ID, fnames{p})
            
        end

    end
    
%     % save to temp file
%     file_temp = fullfile(tempdir, sprintf('%s_tmp_baseline.mat', md.GUID));
%     save(file_temp, 'erp')
%     ac.UploadExternalData(md, 'faceerp_avg30', file_temp);
%     delete(file_temp)

    ac.UpdateMetadata(md);
    
end