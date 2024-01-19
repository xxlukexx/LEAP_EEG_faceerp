% load measures
load('/Users/luke/Google Drive/Experiments/face erp/LEAP_EEG_faces_measures_20190517T164602.mat')
figure('name', 'new')
path_out = '/users/luke/desktop/n170_lat_corr';

% filter for valid trials and valid peaks
tab_mes = tab_mes(logical(tab_mes.include) & logical(tab_mes.val), :);

% subscripts for compononent and condition
[comp_u, ~, comp_s] = unique(tab_mes.comp);
numComp = length(comp_u);
[cond_u, ~, cond_s] = unique(tab_mes.cond);
numCond = length(cond_u);

% preallocate output
compcond = cell(numComp * numCond, 1);
cond = cell(numComp * numCond, 1);
ids = cell(numComp * numCond, 1);
mds = nan(numComp * numCond, 1);
comps = cell(numComp * numCond, 1);
lat_old = cell(numComp * numCond, 1);
lat_new = cell(numComp * numCond, 1);

sp = 1;
for cmp = 1:length(comp_u)
    for cnd = 1:length(cond_u)
        
        % filter for only the current component and condition
        idx_compcond = comp_s == cmp & cond_s == cnd;
        tab_cc = tab_mes(idx_compcond, :);
        
        % depending upon component, find problematic latencies
        if strcmpi(comp_u{cmp}, 'N170p')
            
            % find N170 with latencies around 170ms and 230ms
            idx_check = (tab_cc.lat >= 0.169 & tab_cc.lat <= 0.171) |...
                (tab_cc.lat >= 0.229 & tab_cc.lat <= 0.231);
            
        elseif strcmpi(comp_u{cmp}, 'P1o') || strcmpi(comp_u{cmp}, 'P1p')
            
            % find P1 with latencies around 120ms
            idx_check = tab_cc.lat >= 0.119 & tab_cc.lat <= 0.121;
            
        else
            
            % nothing to check for other components
            idx_check = false(size(tab_cc, 1), 1);
            
        end
        
        % plot all latencies, with problematic ones in red
        subplot(length(cond_u), length(comp_u), sp)
        y = tab_cc.lat;
        x = 1:length(y);
        cols = lines(2);
        scatter(x, y, [], cols(idx_check + 1, :))
        title(sprintf('comp: %s | cond: %s | mode: %.3f', comp_u{cmp}, cond_u{cnd}, mode(y)))
        
%         % store mode, comp/condition and ids that need checking
%         mds(sp) = mode(y);
%         compcond{sp} = sprintf('%s_%s', comp_u{cmp}, cond_u{cnd});
%         ids{sp} = tab_cc.ID(idx_check);
%         cond{sp} = cond_u{cnd};
%         comps{sp} = comp_u{cmp};
%         lat_old{sp} = tab_cc.lat(idx_check);
        
        sp = sp + 1;
        
    end
    
end

tab_check = table;
tab_check.compcond = compcond;
tab_check.cond = cond;
tab_check.comp = comps;
tab_check.mode = mds;
tab_check.ids = ids;
tab_check.lat_old = lat_old;

idx_compcond = instr(tab_check.compcond, 'N170') | instr(tab_check.compcond, 'P1');
tab_check = tab_check(idx_compcond, :);


clear ac
ac = teAnalysisClient;
ac.HoldQuery = {'Study', 'LEAP', 'faceerp_avged', 1};
ac.ConnectToServer('193.61.45.196', 3000)
md_all = ac.Metadata;
% [erps, guid_erps] = ac.GetVariable('faceerp_avg30');
% 
% if ~isequal(cellfun(@(x) x.GUID, md_all, 'UniformOutput', false), guid_erps)
%     error('GUID mismatch')
% end

%%

% loop through all IDs
for d = 1:length(md_all)
    
    md = md_all{d};
    needsUpdate = false;
    
    % loop through all comd/comp
    for ch = 1:size(tab_check, 1)
        
%         % does this peak need correcting for this ID?
%         if ismember(md.ID, tab_check.ids{ch})
            
            % get ERP for current condition
            if ~isempty(erps{d})
                erp = erps{d}.(tab_check.cond{ch});
            else
                continue
            end
            
            % build label for left and right elec
            if strcmpi(tab_check.comp{ch}, 'N170p') || strcmpi(tab_check.comp{ch}, 'P1p')
                
                lab_left_lat = sprintf('%s_%s_lat_P7', tab_check.cond{ch},...
                    tab_check.comp{ch});
                lab_right_lat = sprintf('%s_%s_lat_P8', tab_check.cond{ch},...
                    tab_check.comp{ch});   
                
                lab_left_pamp = sprintf('%s_%s_amp_P7', tab_check.cond{ch},...
                    tab_check.comp{ch});
                lab_right_pamp = sprintf('%s_%s_amp_P8', tab_check.cond{ch},...
                    tab_check.comp{ch});
                
                elec_left = 'P7';
                elec_right = 'P8';
                
            elseif strcmpi(tab_check.comp{ch}, 'P1o')
                
                lab_left_lat = sprintf('%s_%s_lat_O1', tab_check.cond{ch},...
                    tab_check.comp{ch});
                lab_right_lat = sprintf('%s_%s_lat_O2', tab_check.cond{ch},...
                    tab_check.comp{ch});   
                
                lab_left_pamp = sprintf('%s_%s_amp_O1', tab_check.cond{ch},...
                    tab_check.comp{ch});
                lab_right_pamp = sprintf('%s_%s_amp_O2', tab_check.cond{ch},...
                    tab_check.comp{ch});    
                
                elec_left = 'O1';
                elec_right = 'O2';
                
            end
            
            % determine whether to correct
            if isprop(md, 'erp_peaks') && isfield(md.erp_peaks, lab_left_lat)
                ll = md.erp_peaks.(lab_left_lat);
            else
                ll = nan;
            end

            if isprop(md, 'erp_peaks') && isfield(md.erp_peaks, lab_right_lat)
                lr = md.erp_peaks.(lab_right_lat);
            else
                lr = nan;
            end
                
            % set polarity
            if strcmpi(tab_check.comp{ch}, 'N170p')
                dir = 'negative';
                doLeft = (ll >= 0.169 & ll <= 0.171) | (ll >= 0.229 & ll <= 0.231);
                doRight = (lr >= 0.169 & lr <= 0.171) | (lr >= 0.229 & lr <= 0.231);                
            else 
                dir = 'positive';
                doLeft = ll >= .119 && ll <= .121;
                doRight = lr >= .119 && lr <= .121;                
            end            
            
            % find new peaks - only if latency is problematic
            newPeaks = struct;
            if doLeft
                
                lat_left = md.erp_peaks.(lab_left_lat);
                win_left = [lat_left - 0.012, lat_left + 0.012];
                
                [newPeaks.(lab_left_pamp), newPeaks.(lab_left_lat)] =...
                    eegFindPeak(erp, win_left, elec_left, [], dir);
                
                diff_lat_left = newPeaks.(lab_left_lat) - md.erp_peaks.(lab_left_lat);
                diff_amp_left = newPeaks.(lab_left_pamp) - md.erp_peaks.(lab_left_pamp);
                
                md.erp_peaks.(lab_left_lat) = newPeaks.(lab_left_lat);
                md.erp_peaks.(lab_left_pamp) = newPeaks.(lab_left_pamp);
                
            end
            
            if doRight
                
                lat_right = md.erp_peaks.(lab_right_lat);
                win_right = [lat_right - 0.012, lat_right + 0.012];

                [newPeaks.(lab_right_pamp), newPeaks.(lab_right_lat)] =...
                    eegFindPeak(erp, win_right, elec_right, [], dir);   

                diff_lat_right = newPeaks.(lab_right_lat) - md.erp_peaks.(lab_right_lat);
                diff_amp_right = newPeaks.(lab_right_pamp) - md.erp_peaks.(lab_right_pamp);  
                
                md.erp_peaks.(lab_right_lat) = newPeaks.(lab_right_lat);
                md.erp_peaks.(lab_right_pamp) = newPeaks.(lab_right_pamp);
                
            end
            
            % plot
            if doLeft || doRight
                figure('position', [0, 0, 1000, 750], 'Visible', 'off')
                idx_chan_left = find(strcmpi(erp.label, elec_left), 1);
                idx_chan_right = find(strcmpi(erp.label, elec_right), 1);
            end
            
            if doLeft
                
                subplot(2, 2, 1)
                plot(erp.time, erp.avg(idx_chan_left, :))
                hold on
                scatter(md.erp_peaks.(lab_left_lat), md.erp_peaks.(lab_left_pamp), 50, 'r')
                scatter(newPeaks.(lab_left_lat), newPeaks.(lab_left_pamp), 50, 'g')
                title(sprintf('Lat: %.3fs | Amp: %.3fµV', diff_lat_left, diff_amp_left))
                text(newPeaks.(lab_left_lat) + .050, newPeaks.(lab_left_pamp),...
                    sprintf('%.3fs -> %.3fs', md.erp_peaks.(lab_left_lat),...
                    newPeaks.(lab_left_lat)), 'Color', 'm')

                subplot(2, 2, 3)
                plot(erp.time, erp.avg(idx_chan_left, :))
                hold on
                scatter(md.erp_peaks.(lab_left_lat), md.erp_peaks.(lab_left_pamp), 50, 'r')
                scatter(newPeaks.(lab_left_lat), newPeaks.(lab_left_pamp), 50, 'g')
                xlim([win_left(1) - .050, win_left(2) + .050])
            
            end
            
            if doRight
                
                subplot(2, 2, 2)
                plot(erp.time, erp.avg(idx_chan_right, :))
                hold on
                scatter(md.erp_peaks.(lab_right_lat), md.erp_peaks.(lab_right_pamp), 50, 'r')
                scatter(newPeaks.(lab_right_lat), newPeaks.(lab_right_pamp), 50, 'g')
                title(sprintf('Lat: %.3fs | Amp: %.3fµV', diff_lat_right, diff_amp_right))

                subplot(2, 2, 4)
                plot(erp.time, erp.avg(idx_chan_right, :))
                hold on
                scatter(md.erp_peaks.(lab_right_lat), md.erp_peaks.(lab_right_pamp), 50, 'r')
                scatter(newPeaks.(lab_right_lat), newPeaks.(lab_right_pamp), 50, 'g')
                xlim([win_left(1) - .050, win_left(2) + .050])
                
            end
            
            if doLeft || doRight
                file_out = fullfile(path_out, sprintf('%s_%s.png', md.ID, lab_left_lat));
                fastSaveFigure(gcf, file_out)
                close(gcf)
                disp(d)
                needsUpdate = true;
            end
            
%             md.check_lat.(tab_check.compcond{ch}) = true;
            
%         else
            
%             md.check_lat.(tab_check.compcond{ch}) = false;
            
%         end
        
        
    end
    
    if needsUpdate
        md_all{d} = md;
        ac.UpdateMetadata(md);
        disp(d)
    end
    
end


%%
% update peaks
for i = 1:length(md_all)
    
    md = md_all{i};
    erp = erps{i};
    
    if ~isprop(md, 'peakrating'), continue, end
    pr = md.peakrating;
    
    
    % remove summary fields
    pr = rmfield(pr, {...
        'total_not_clear', 'total_dbl_peak', 'total_needs_checking'});
    
    % get fieldnames
    fnames = fieldnames(pr);
    
    % split on underscore
    parts = cellfun(@(x) strsplit(x, '_'), fnames, 'UniformOutput', false);
    
    % name is first part, before electrode (e.g. face_up_P1o)
    name = cellfun(@(x) sprintf('%s_', x{1:end - 1}), parts,...
        'UniformOutput', false);
    
    % elec is last part
    elec = cellfun(@(x) x{end}, parts, 'UniformOutput', false);
    
    % make name of mean amp fields (e.g. face_up_P1o_meanmp_P7)
    name_mamp = cellfun(@(name, elec) sprintf('%smeanamp_%s', name, elec),...
        name, elec, 'UniformOutput', false);
    
    % do same for lat and peak amp
    name_lat = cellfun(@(name, elec) sprintf('%slat_%s', name, elec),...
        name, elec, 'UniformOutput', false);   
    name_pamp = cellfun(@(name, elec) sprintf('%samp_%s', name, elec),...
        name, elec, 'UniformOutput', false); 
    
    % condition
    conds = cellfun(@(x) sprintf('%s_%s', x{1}, x{2}), parts,...
        'UniformOutput', false);
    
    % loop through names and find peaks
    numPeaks = length(name_mamp);
    for p = 1:numPeaks
        
        f_lat = name_lat{p};
        f_pamp = name_pamp{p};
        
        if isfield(md, f_lat) && isfield(md, f_pamp)
            
            cond = conds{p};
            erp_tmp = erp.(cond);
            idx_ch = strcmpi(elec{p}, erp_tmp.label);

            % get sample number of current peak latency
            s = find(erp_tmp.time >= md.erp_peaks.(f_lat), 1);

            % get peak amplitude of the peak
            md.erp_peaks.(f_pamp) = erp_tmp.avg(idx_ch, s);
            
        end

    end
    
    ac.UpdateMetadata(md)
    
end