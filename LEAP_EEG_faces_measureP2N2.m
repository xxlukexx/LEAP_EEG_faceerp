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
    
% peak centres
%
% Age		P2		N2
% 6-10		269		328
% 11-15		257		341
% 16-20		247		360
% 21-30		242		380

ctrAge = [5; 12.5; 18; 25];
ctrP2 = [269; 257; 247; 242] / 1e3;
ctrN2 = [328; 341; 360; 380] / 1e3;
mdlP2 = fitlm(ctrAge, ctrP2);
mdlN2 = fitlm(ctrAge, ctrN2);
    
% measure
   
    for d = 1:numData
        
        if mod(d, 50) == 0
            fprintf('Measuring peaks %d of %d...\n', d, numData);
        end        
        
        % basic checks that this metadata has the fields we need
        if ~isprop(md{d}, 'erp_peaks'), continue, end
        if ~isstruct(md{d}.erp_peaks), continue, end
               
        % get erps
        erps = allErps{d};
        
        % update metadata with subject age
        idx_tab = find(strcmpi(tab.ID, md{d}.ID), 1);
        md{d}.Age = tab.age_years(idx_tab);
        
        % get age centres for this subject
        latP2 = mdlP2.predict(md{d}.Age);
        latN2 = mdlN2.predict(md{d}.Age);
        
        % store peak rating
        md{d}.peakrating.face_up_P2p_P7 = 'OK';
        md{d}.peakrating.face_up_P2p_P8 = 'OK';
        md{d}.peakrating.face_up_N2p_P7 = 'OK';
        md{d}.peakrating.face_up_N2p_P8 = 'OK';
        md{d}.peakrating.face_inv_P2p_P7 = 'OK';
        md{d}.peakrating.face_inv_P2p_P8 = 'OK';
        md{d}.peakrating.face_inv_N2p_P7 = 'OK';
        md{d}.peakrating.face_inv_N2p_P8 = 'OK';
        
        % store centres
        md{d}.erp_window_centre.face_up_P2p_lat_P7  = latP2;
        md{d}.erp_window_centre.face_up_P2p_lat_P8  = latP2;
        md{d}.erp_window_centre.face_up_N2p_lat_P7  = latN2;
        md{d}.erp_window_centre.face_up_N2p_lat_P8  = latN2;
        md{d}.erp_window_centre.face_inv_P2p_lat_P7 = latP2;
        md{d}.erp_window_centre.face_inv_P2p_lat_P8 = latP2;
        md{d}.erp_window_centre.face_inv_N2p_lat_P7 = latN2;
        md{d}.erp_window_centre.face_inv_N2p_lat_P8 = latN2;

        % measure mean amp
        md{d}.erp_peaks.face_up_P2p_meanamp_P7  = measureERP(erps.face_up,  latP2, 'P7', maWidth);
        md{d}.erp_peaks.face_up_P2p_meanamp_P8  = measureERP(erps.face_up,  latP2, 'P8', maWidth);        
        md{d}.erp_peaks.face_up_N2p_meanamp_P7  = measureERP(erps.face_up,  latN2, 'P7', maWidth);
        md{d}.erp_peaks.face_up_N2p_meanamp_P8  = measureERP(erps.face_up,  latN2, 'P8', maWidth);   
        md{d}.erp_peaks.face_inv_P2p_meanamp_P7 = measureERP(erps.face_inv, latP2, 'P7', maWidth);
        md{d}.erp_peaks.face_inv_P2p_meanamp_P8 = measureERP(erps.face_inv, latP2, 'P8', maWidth);        
        md{d}.erp_peaks.face_inv_N2p_meanamp_P7 = measureERP(erps.face_inv, latN2, 'P7', maWidth);
        md{d}.erp_peaks.face_inv_N2p_meanamp_P8 = measureERP(erps.face_inv, latN2, 'P8', maWidth);   
        
        % latency
        md{d}.erp_peaks.face_up_P2p_lat_P7  = latP2;
        md{d}.erp_peaks.face_up_P2p_lat_P8  = latP2;     
        md{d}.erp_peaks.face_up_N2p_lat_P7  = latN2;
        md{d}.erp_peaks.face_up_N2p_lat_P8  = latN2;
        md{d}.erp_peaks.face_inv_P2p_lat_P7 = latP2;
        md{d}.erp_peaks.face_inv_P2p_lat_P8 = latP2;    
        md{d}.erp_peaks.face_inv_N2p_lat_P7 = latN2;
        md{d}.erp_peaks.face_inv_N2p_lat_P8 = latN2;
        
        % peak amp
        md{d}.erp_peaks.face_up_P2p_amp_P7  = nan;
        md{d}.erp_peaks.face_up_P2p_amp_P8  = nan;     
        md{d}.erp_peaks.face_up_N2p_amp_P7  = nan;
        md{d}.erp_peaks.face_up_N2p_amp_P8  = nan;
        md{d}.erp_peaks.face_inv_P2p_amp_P7 = nan;
        md{d}.erp_peaks.face_inv_P2p_amp_P8 = nan;    
        md{d}.erp_peaks.face_inv_N2p_amp_P7 = nan;
        md{d}.erp_peaks.face_inv_N2p_amp_P8 = nan;        
        
        md{d}.Checks.p2n2measured = true;
        ac.UpdateMetadata(md{d});
                
    end
           
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
    
