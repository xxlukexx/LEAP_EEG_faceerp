ac = teAnalysisClient;
ac.ConnectToServer('lm-analysis.local', 3000)

path_data = '/Volumes/Projects/LEAP/EEG/faces/20181214/04_avg30';
d = dir(path_data);
d([d.isdir]) = [];

tab = ac.Table;
hasAvg = ~cellfun(@isempty, tab.faceerp_avg30);

guidNeedsAvg = tab.GUID(~hasAvg);
numData = length(guidNeedsAvg);
suc = false(numData, 1);
err = cell(numData, 1);


for g = 1:numData
    
    md = ac.GetMetadata(guidNeedsAvg{g});
    
    file_data = fullfile(path_data, sprintf('%s.clean.average.mat', md.ID));
    if exist(file_data, 'file')

        % upload data
        [suc_copy, ops_copy, md] = ac.UploadExternalData(md.GUID,...
            'faceerp_avg30', file_data);

        md.Checks.faceerp_avged = suc_copy;

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