ac = teAnalysisClient;
ac.ConnectToServer('lm-analysis.local', 3000)

path_data = '/Volumes/Projects/LEAP/EEG/faces/20181214/03_clean100';
d = dir(path_data);
d([d.isdir]) = [];

tab = ac.Table;
if ~ismember('faceerp_clean100', tab.Properties.VariableNames)
    isClean = false(size(tab, 1), 1);
else
    isClean = ~cellfun(@isempty, tab.faceerp_clean100);
end

guidNeedCleaning = tab.GUID(~isClean);
numData = length(guidNeedCleaning);
suc = false(numData, 1);
err = cell(numData, 1);


for g = 1:numData
    
    md = ac.GetMetadata(guidNeedCleaning{g});
    
    file_data = fullfile(path_data, sprintf('%s.clean.mat', md.ID));
    if exist(file_data, 'file')

        % upload data
        [suc_copy, ops_copy, md] = ac.UploadExternalData(md.GUID,...
            'faceerp_clean100', file_data);

        md.Checks.faceerp_cleaned_100hz = suc_copy;

        [suc_update, err{f}] = ac.UpdateMetadata(md);
        suc(f) = suc_copy && suc_update;
    
    end
    
end
    




% for f = 1:length(d)
%     
%     % get ID
%     parts = strsplit(d(f).name, '.');
%     id = parts{1};
%     
%     % get metadata
%     [md, guid] = ac.GetMetadata('ID', id, 'Study', 'LEAP');
%     
%     if ~isempty(md)
%         
%         if ~md.Checks.faceerp_cleaned
% 
%             % upload data
%             [suc_copy, ops_copy, md] = ac.UploadExternalData(md.GUID, 'faceerp_clean30',...
%                 fullfile(path_data, d(f).name));
% 
%             md.Checks.faceerp_cleaned = suc_copy;
% 
%             [suc_update, err{f}] = ac.UpdateMetadata(md);
%             suc(f) = suc_copy && suc_update;
%             
%         end
%         
%     end
%     
%     cprintf('*cyan', '%s [%d of %d]\n', id, f, length(d))
%   
%     
% end