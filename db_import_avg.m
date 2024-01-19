ac = teAnalysisClient;
ac.ConnectToServer('lm-analysis.local', 3000)

path_data = '/Volumes/Projects/LEAP/EEG/faces/20181214/04_avg30';
d = dir(path_data);
d([d.isdir]) = [];
numData = length(d);

suc = false(numData, 1);
err = cell(numData, 1);

for f = 1:length(d)
    
    if strcmpi(d(f).name, '_results.mat')
        continue
    end
    
    % get ID
    parts = strsplit(d(f).name, '.');
    id = parts{1};
    
    % get metadata
    [md, guid] = ac.GetMetadata('ID', id, 'Study', 'LEAP');
    
    if ~isempty(md) && md.Checks.faceerp_cleaned && isempty(md.Paths('faceerp_avg30'))
        
        % upload data
        [suc_copy, ops_copy, md] = ac.UploadExternalData(md.GUID, 'faceerp_avg30',...
            fullfile(path_data, d(f).name));

        md.Checks.faceerp_avged = suc_copy;

        [suc_update, err{f}] = ac.UpdateMetadata(md);
        suc(f) = suc_copy && suc_update;
            
    end
    
    cprintf('*cyan', '%s [%d of %d]\n', id, f, length(d))
  
    
end