    addpath(genpath('/Users/luke/Google Drive/Dev/lm_tools'))
    addpath('/Users/luke/Google Drive/Dev/ECKAnalyse/')
    addpath('/users/luke/Google Drive/Experiments/LEAP/Baseline/')

% params

    % width of mean amplitude measurement window
    maWidth = .040;
    
% db

    ac = teAnalysisClient;
    ac.ConnectToServer('lm-analysis.local', 3000)
    ac.HoldQuery = {'Study', 'LEAP', 'faceerp_avged', true};
    
    % get metadata
    md = ac.Metadata;
    guids_md = cellfun(@(x) x.GUID, md, 'UniformOutput', false);

    % get ERPs
    [allErps, guids_erp] = ac.GetVariable('faceerp_avg30');
    numData = length(allErps);
    
    % get table
    tab = ac.Table;
    
    if ~isequal(guids_md, guids_erp, tab.GUID)
        error('Metadata/table/ERP GUIDs do not match.')
    end

    % get LEAP metadata
    [tab, ~, id_notFound] = LEAP_appendMetadata(tab, 'ID');
    
    % empty measures table
    tab_mes = table;
    
% measure

    % define expected peaks
    fnames_pr_exp = {...
                    'face_up_P1o_O1'...      
                    'face_up_P1o_O2'...      
                    'face_up_N170p_P7'...    
                    'face_up_N170p_P8'...    
                    'face_inv_P1o_O1'...     
                    'face_inv_P1o_O2'...     
                    'face_inv_N170p_P7'...   
                    'face_inv_N170p_P8'...   
                    };
    
    for d = 1:numData
        
        if mod(d, 50) == 0
            fprintf('Measuring peaks %d of %d...\n', d, numData);
        end        
        
        % basic checks that this metadata has the fields we need
        if ~isprop(md{d}, 'erp_peaks'), continue, end
        if ~isstruct(md{d}.erp_peaks), continue, end
        if ~isstruct(md{d}.peakrating), continue, end
        
        % pull peak ratings and peaks, get fieldnames
        pr = md{d}.peakrating;
        pk = md{d}.erp_peaks;
        fnames_pr = fieldnames(pr);
        fnames_pk = fieldnames(pk);
        
        % remove peak rating fields that don't start with 'face' (these are
        % used to checking/tracking and don't refer to peaks themselves)
        idx_rem = ~instr(fnames_pr, 'face');
        fnames_pr(idx_rem) = [];
        
        % get erps
        erps = allErps{d};
        
        % full check of expected fieldnames against actual
        if ~all(ismember(fnames_pr_exp, fnames_pr)), continue, end
        
        % loop through peaks
        numPeaks = length(fnames_pr);
        for p = 1:numPeaks
            
            % get peak name
            pn = fnames_pr{p};
            
            % build latency fieldname
            parts = strsplit(pn, '_');
            fname_lat = sprintf('%s_%s_%s_lat_%s', parts{:});

            % get cond
            cond = sprintf('%s_%s', parts{1:2});

            % get elec
            elec = parts{4};

            % get latency
            if ~isfield(pk, fname_lat)
                continue
            end 
            lat = pk.(fname_lat);

            % measure ERP
            meanAmp = measureERP(erps.(cond), lat, elec, maWidth);
        
            % write to peaks struct
            fname_meanAmp = sprintf('%s_%s_%s_meanamp_%s', parts{:});
            pk.(fname_meanAmp) = meanAmp;
            
        end
        
        % sort field order
        pk = orderfields(pk);
        
        % write back to md
        md{d}.erp_peaks = pk;
        md{d}.Checks.faceerp_measured = true;
        ac.UpdateMetadata(md{d});
        
        % tabulate
        tab_mes = [tab_mes; LEAP_EEG_faces_tabulatePeaks(md{d}, erps)];
                
    end
    
    tab_mes = LEAP_appendMetadata(tab_mes, 'ID');
        
    function ma = measureERP(erp, lat, elec, maWidth)
    
        % find widow edges
        t1 = lat - maWidth / 2;
        t2 = lat + maWidth / 2;
        
        % convert time to samples
        s1 = find(erp.time >= t1, 1);
        s2 = find(erp.time >= t2, 1);
        
        % find channel index
        idx_ch = find(strcmpi(elec, erp.label), 1);
        
        % measure
        ma = mean(erp.avg(idx_ch, s1:s2));
    
    end
 