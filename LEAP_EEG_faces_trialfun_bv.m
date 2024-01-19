function [trl, event] = LEAP_EEG_faces_trialfun_bv(cfg)

    % define trial events
    events = {...
        'FACE_ONSET_UPRIGHT_CAUC',         223,     'Face',     'Upright',   'Caucasian'    ;...
        'FACE_ONSET_UPRIGHT_ASIAN',        224      'Face',     'Upright',   'Asian'        ;...
        'FACE_ONSET_UPRIGHT_AFRICAN',      225      'Face',     'Upright',   'African'      ;...
        'FACE_ONSET_INVERTED_CAUC',        226      'Face',     'Inverted',  'Caucasian'    ;...
        'FACE_ONSET_INVERTED_ASIAN',       227      'Face',     'Inverted',  'Asian'        ;...
        'FACE_ONSET_INVERTED_AFRICAN',     228      'Face',     'Inverted',  'African'      ;...
        'HOUSE_ONSET_UPRIGHT_01',          21       'House',    'Upright',   '1'            ;...
        'HOUSE_ONSET_UPRIGHT_02',          22       'House',    'Upright',   '2'            ;...
        'HOUSE_ONSET_UPRIGHT_03',          23       'House',    'Upright',   '2'            ;...
    };

    % define ERP correction factor by site in seconds
    switch cfg.site
        case 'KCL'
            corr = 0.0492;
            
        case 'Mannheim'
            corr = 0.0000;
            
        case 'Nijmegen'
            corr = 0.0258;
            
        case 'Rome'
            corr = 0.0000;
            
        case 'Utrecht'
            corr = 0.0065;
            
        otherwise
            corr = 0.0000;
            warning('Site %s not recognised, applying a default correction factor of %.5fs',...
                site, corr)
            
    end
    corr = 0;
    
    % read events
    event = ft_read_event(cfg.dataset);
    
    tab = struct2table(event);
    idx_rem = ~strcmpi(tab.type, 'Toggle');
    tab(idx_rem, :) = [];
    
    % get trial onset samples and event values
    samps = tab.sample;
    vals = cell2mat(extractNumeric(tab.value));
    
    % face -> 500ms
    idx = (vals >= 223 & vals <= 228) | (vals >= 21 & vals <= 23);
    samps = samps(idx);
    vals = vals(idx);
    
    % convert timing error correction to samples
    corr_samps = round(corr * cfg.fsample);

    % define trial duration and baseline
%     duration_secs = .500;
%     baseline_secs = .200;
    duration_secs = .800;
    baseline_secs = .200;
    duration_samps = round(duration_secs * cfg.fsample);
    baseline_samps = round(baseline_secs * cfg.fsample);
    
    % define trials
    s1 = round(samps - baseline_samps) + corr_samps;
    s2 = round(samps + duration_samps) + corr_samps;
    offset = repmat(-baseline_samps, size(s1));
    
    % return fieldtrip trial definition
    trl = [s1, s2, offset, vals];
    
end