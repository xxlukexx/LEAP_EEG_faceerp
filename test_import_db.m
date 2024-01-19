path_data = '/Volumes/Projects/LEAP/EEG/faces/20181214/01_preproc100';
d = dir(path_data);
d([d.isdir]) = [];
numData = length(d);

suc = false(numData, 1);
err = cell(numData, 1);

for f = 1:length(d)
    
    md = teMetadata;
    md.GUID = GetGUID;
    
    parts = strsplit(d(f).name, '.');
    md.ID = parts{1};
    md.Study = 'LEAP';
    md.Wave = 1;
    md.Task = 'faceerp';
    
    [suc_ingest, ops_ingest] = ac.Ingest(md);
    [suc_copy, ops_preproc, md] = ac.UploadExternalData(md.GUID, 'faceerp_preproc_40',...
        fullfile(path_data, d(f).name));
    [suc_update, err{f}] = ac.UpdateMetadata(md);
    suc(f) = suc_ingest && suc_copy && suc_update;
  
    
end