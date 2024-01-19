addpath(genpath('/Users/luke/Google Drive/Experiments/LEAP'))
addpath('/Users/luke/Google Drive/Dev/eegtools')
addpath(genpath('/Users/luke/Google Drive/Dev/lm_tools'))

ac = teAnalysisClient;
ac.HoldQuery = {'Study', 'LEAP'};
ac.ConnectToServer('lm-analysis.local', 3000)

tab = ac.Table;
tab = LEAP_appendMetadata(tab, 'ID');

md = ac.Metadata;
guid_md = cellfun(@(x) x.GUID, md, 'UniformOutput', false);
if ~isequal(guid_md, tab.GUID)
    error('Table and metadata GUIDs do not match.')
end

for i = 1:size(tab, 1)
    
    md{i}.Site = tab.site{i};
    ac.UpdateMetadata(md{i});
    fprintf('%d of %d\n', i, size(tab, 1));
    
end