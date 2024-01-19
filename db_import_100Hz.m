ac = teAnalysisClient;
ac.ConnectToServer('lm-analysis.local', 3000)

path_data = '/Volumes/Projects/LEAP/EEG/faces/20170817/03_clean';
d = dir(path_data);
d([d.isdir]) = [];
numData = length(d);

suc = false(numData, 1);
err = cell(numData, 1);

for f = 1:length(d)
    
    % get ID
    parts = strsplit(d(f).name, '.');
    id = parts{1};
    
    % get metadata
    [md, guid] = ac.GetMetadata('ID', id, 'Study', 'LEAP');
    
    if ~isempty(md)

        % upload data
        [suc_copy, ops_copy, md] = ac.UploadExternalData(md.GUID, 'faceerp_clean',...
            fullfile(path_data, d(f).name));
        [suc_update, err{f}] = ac.UpdateMetadata(md);
        suc(f) = suc_copy && suc_update;
        
    end
    
    
  
    
end