function tab = LEAP_EEG_faces_tabulatePeaks(md, erps)

    tab = table;
    if ~isprop(md, 'erp_peaks'), return, end
    
    % get all fieldnames
    fnames = fieldnames(md.peakrating);
    
    % remove unwanted
    idx_rem = ~instr(fnames, 'face');
    fnames(idx_rem) = [];
    
    % split peaks
    parts       = cellfun(@(x) strsplit(x, '_'), fnames,...
                    'UniformOutput', false);
    cond        = cellfun(@(x) sprintf('%s_%s', x{1}, x{2}), parts,...
                    'UniformOutput', false);
    comp        = cellfun(@(x) x{3}, parts, 'UniformOutput', false);
    elec        = cellfun(@(x) x{4}, parts, 'UniformOutput', false);
    
    % find hemi from elec
    idx_l = strcmp(elec, 'P7') | strcmp(elec, 'O1');
    hemi = repmat({'right'}, size(elec, 1), 1);
    hemi(idx_l) = repmat({'left'}, sum(idx_l), 1);
    
    % get ID and GUID
    tab.GUID = repmat({md.GUID}, length(cond), 1);
    tab.ID = repmat({md.ID}, length(cond), 1);
    
    % check inclusion
    incl = ...
        md.dq.tpc_up >= 20 &...
        md.dq.tpc_inv >= 20 &...
        md.dq.num_chan_interp <= 10 &...
        md.dq.num_chan_excl <= 10;
    tab.include = repmat(incl, length(cond), 1);
    
    % put tpc in table
    idx_up = strcmpi(cond, 'face_up');
    idx_inv = strcmpi(cond, 'face_inv');
    tpc = zeros(size(cond));
    tpc(idx_up) = repmat(md.dq.tpc_up, sum(idx_up), 1);
    tpc(idx_inv) = repmat(md.dq.tpc_inv, sum(idx_inv), 1);
    tab.tpc = tpc;

    % put into table
    tab.cond = cond;
    tab.comp = comp;
    tab.elec = elec;
    tab.hemi = hemi;
    
    % form field names to look up measurements
    fnames_lat = cellfun(@(cond, comp, elec) sprintf('%s_%s_lat_%s',...
        cond, comp, elec), cond, comp, elec, 'uniform', false);
    fnames_pa = cellfun(@(cond, comp, elec) sprintf('%s_%s_amp_%s',...
        cond, comp, elec), cond, comp, elec, 'uniform', false);
    fnames_ma = cellfun(@(cond, comp, elec) sprintf('%s_%s_meanamp_%s',...
        cond, comp, elec), cond, comp, elec, 'uniform', false);
    
    % get measurements and peak validity
    for p = 1:size(tab, 1)
        
        % measures
        if isfield(md.erp_peaks, fnames_lat{p})
            tab.lat(p) = md.erp_peaks.(fnames_lat{p});
        else
            tab.lat(p) = nan;
        end
        if isfield(md.erp_peaks, fnames_pa{p})
            tab.pamp(p) = md.erp_peaks.(fnames_pa{p});
        else
            tab.pamp(p) = nan;
        end
        if isfield(md.erp_peaks, fnames_ma{p})
            tab.mamp(p) = md.erp_peaks.(fnames_ma{p});
        else
            tab.mamp(p) = nan;
        end
        
        % validity
        tab.val_code{p} = md.peakrating.(fnames{p});
        tab.val(p) = ~strcmpi(md.peakrating.(fnames{p}), 'peaks not clear');
        
        % erp
        idx_ch = find(strcmpi(erps.(cond{p}).label, elec{p}), 1);
        tab.erp_avg{p} = erps.(cond{p}).avg(idx_ch, :);
        tab.erp_time{p} = erps.(cond{p}).time;
        
    end

end

% function [val, cond, comp, measure, elec] = splitPeakInfo(s, fnames)
% 
%     % peak lat/amp are in the format of
%     %
%     %   face_cond_component_lat/amp_electrode
%     %   e.g.
%     %   face_up_P1o_lat_O1
%     %
%     % split these field names into their component parts
%     parts       = cellfun(@(x) strsplit(x, '_'), fnames,...
%                     'UniformOutput', false);
%     cond        = cellfun(@(x) sprintf('%s_%s', x{1}, x{2}), parts,...
%                     'UniformOutput', false);
%     comp        = cellfun(@(x) x{3}, parts, 'UniformOutput', false);
%     measure     = cellfun(@(x) x{4}, parts, 'UniformOutput', false);
%     elec        = cellfun(@(x) x{5}, parts, 'UniformOutput', false);
% 
%     val         = cell2mat(struct2cell(md.erp_peaks));
% 
% end
% 
% function [cond, comp, elec] = splitPeakRating(md)
% 
%     % peak ratings are in the format of
%     %
%     %   face_cond_component_electrode
%     %   e.g.
%     %   face_up_P1o_O1
%     %
%     % split these field names into their component parts
%     fnames      = fieldnames(md.peakrating);
%     parts       = cellfun(@(x) strsplit(x, '_'), fnames,...
%                     'UniformOutput', false);
%     cond        = cellfun(@(x) sprintf('%s_%s', x{1}, x{2}), parts,...
%                     'UniformOutput', false);
%     comp        = cellfun(@(x) x{3}, parts, 'UniformOutput', false);
%     elec        = cellfun(@(x) x{4}, parts, 'UniformOutput', false);
% 
% end   