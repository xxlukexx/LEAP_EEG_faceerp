client = teAnalysisClient;
client.HoldQuery = {'Study', 'LEAP', 'faceerp_avged', true};
client.ConnectToServer('193.61.45.196', 3000)

numData = client.NumDatasets;
tab = client.Table;
for i = 1:numData
    
    md = client.GetMetadata('GUID', tab.GUID{i});
    
    % N2/P2 peak ratings
    if isprop(md, 'peakrating')
        fnames = fieldnames(md.peakrating);
        idx = instr(fnames, 'P2') | instr(fnames, 'N2') | instr(fnames, 'summary_ce');
        md.peakrating = rmfield(md.peakrating, fnames(idx));
    end
    
    % N2/P2 window centres
    if isprop(md, 'erp_window_centre')
        fnames = fieldnames(md.erp_window_centre);
        idx = instr(fnames, 'P2') | instr(fnames, 'N2') | instr(fnames, 'summary_ce');
        md.erp_window_centre = rmfield(md.erp_window_centre, fnames(idx));
    end
    
    % N2/P2 window widths
    if isprop(md, 'erp_window_width')
        fnames = fieldnames(md.erp_window_width);
        idx = instr(fnames, 'P2') | instr(fnames, 'N2') | instr(fnames, 'summary_ce');
        md.erp_window_width = rmfield(md.erp_window_width, fnames(idx));
    end
    
    % N2/P2 peak lat/amp
    if isprop(md, 'erp_peaks')
        fnames = fieldnames(md.erp_peaks);
        idx = instr(fnames, 'P2') | instr(fnames, 'N2') | instr(fnames, 'summary_ce');
        md.erp_peaks = rmfield(md.erp_peaks, fnames(idx));
    end
    
    % count each category of peak ratings
    if isprop(md, 'peakrating')
        c = struct2cell(md.peakrating);
        md.peakrating.total_not_clear = sum(strcmpi(c, 'Peaks not clear'));
        md.peakrating.total_dbl_peak = sum(strcmpi(c, 'Double peak'));
        md.peakrating.total_needs_checking = sum(strcmpi(c, 'Other (needs checking)'));
    end
    
    client.UpdateMetadata(md);
    
    fprintf('<strong>%d of %d</strong>\n', i, numData);
        
end
