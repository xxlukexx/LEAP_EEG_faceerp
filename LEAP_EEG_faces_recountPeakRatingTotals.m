client = teAnalysisClient;
client.HoldQuery = {'Study', 'LEAP', 'faceerp_avged', true};
client.ConnectToServer('193.61.45.196', 3000)

numData = client.NumDatasets;
tab = client.Table;
for i = 1:numData
    
    md = client.GetMetadata('GUID', tab.GUID{i});
    
    % count each category of peak ratings
    if isprop(md, 'peakrating')
        c = struct2cell(md.peakrating);
        fnames = fieldnames(md.peakrating);
        idx = instr(fnames, 'P1o') | instr(fnames, 'N170p');
        md.peakrating.total_not_clear = sum(strcmpi(c(idx), 'Peaks not clear'));
        md.peakrating.total_dbl_peak = sum(strcmpi(c(idx), 'Double peak'));
        md.peakrating.total_needs_checking = sum(strcmpi(c(idx), 'Other (needs checking)'));
    end
    
    client.UpdateMetadata(md);
    
    fprintf('<strong>%d of %d</strong>\n', i, numData);
        
end
