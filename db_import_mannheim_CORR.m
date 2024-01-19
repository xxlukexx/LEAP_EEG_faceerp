% ac = teAnalysisClient;
% ac.ConnectToServer('lm-analysis.local', 3000)

path_clean30 = '/Volumes/Projects/LEAP/EEG/faces/20181214/03_clean30_mannheim';
d = dir(path_clean30);
d([d.isdir]) = [];
files_clean30 = {d.name};
parts = cellfun(@(x) strsplit(x, '.'), files_clean30, 'UniformOutput', false);
ids_clean30 = cellfun(@(x) x{1}, parts, 'UniformOutput', false);

path_clean100 = '/Volumes/Projects/LEAP/EEG/faces/20181214/03_clean100_mannheim';
d = dir(path_clean100);
d([d.isdir]) = [];
files_clean100 = {d.name};
parts = cellfun(@(x) strsplit(x, '.'), files_clean100, 'UniformOutput', false);
ids_clean100 = cellfun(@(x) x{1}, parts, 'UniformOutput', false);

path_avg30 = '/Volumes/Projects/LEAP/EEG/faces/20181214/04_avg30_mannheim';
d = dir(path_avg30);
d([d.isdir]) = [];
files_avg30 = {d.name};
parts = cellfun(@(x) strsplit(x, '.'), files_avg30, 'UniformOutput', false);
ids_avg30 = cellfun(@(x) x{1}, parts, 'UniformOutput', false);

if ~isequal(ids_clean30, ids_clean100, ids_avg30)
    error('IDs do not match.')
end

numData = length(ids_clean30);

suc = false(numData, 1);
err = cell(numData, 1);

for f = 1:numData
    
    % get metadata
    [md, guid] = ac.GetMetadata('ID', ids_clean30{f}, 'Study', 'LEAP');
    
    if ~isempty(md) 
        
        % upload data
        [suc_copy_clean30, ops_copy, md] = ac.UploadExternalData(...
            md, 'faceerp_clean30', fullfile(path_clean30, files_clean30{f}));
        md.Checks.faceerp_cleaned = suc_copy_clean30;
        
        [suc_copy_clean100, ops_copy, md] = ac.UploadExternalData(...
            md, 'faceerp_clean100', fullfile(path_clean100, files_clean100{f}));
        md.Checks.faceerp_cleaned_100hz = suc_copy_clean100;     
        
        [suc_copy_avg30, ops_copy, md] = ac.UploadExternalData(...
            md, 'faceerp_avg30', fullfile(path_avg30, files_avg30{f}));
        md.Checks.faceerp_avged = suc_copy_avg30;   
        ac.UpdateMetadata(md);
        
        suc(f) = suc_copy_clean30 & suc_copy_clean100 & suc_copy_avg30;
            
    end
    
    cprintf('*cyan', '%s [%d of %d]\n', ids_clean30{f}, f, numData)
  
    
end