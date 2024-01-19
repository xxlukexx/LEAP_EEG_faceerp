path_raw = '/Users/luke/Desktop/leap_raw/raw_files/101129844643.eeg';

        % load raw continuous data, do hp filter at 0.1 Hz (since this will
        % apply to data used for ERP and ERO)
        cfg = struct;
        cfg.dataset = path_raw;
        cfg.layout = 'EEG1010.lay';
        data_c = ft_preprocessing(cfg);
        
        
 % define trial structure and segment
        cfg = struct;
        cfg.id = 101129844643;
        cfg.site = 'KCL';
        cfg.fsample = data_c.fsample;
        cfg.dataset = path_raw;
        cfg.trl = LEAP_EEG_faces_trialfun_bv(cfg);
        data_seg = ft_redefinetrial(cfg, data_c);
        
                % resample to 500Hz
        if data_seg.fsample ~= 500
            cfg = struct;
            cfg.resamplefs = 500;
            cfg.detrend = 'no';
            data_seg = ft_resampledata(cfg, data_seg);
        end  
        
        cfg = struct;
        cfg.lpfilter = 'yes';
        cfg.lpfreq = 40;
        cfg.lpfiltord = 4; 
        cfg.hpfilter = 'yes';
        cfg.hpfreq = .1;
        cfg.hpfiltord = 4; 
        cfg.dftfilter = 'yes';        
        cfg.padding = 2;
%         cfg.channel = lab_nanChan;
        data = ft_preprocessing(cfg, data_seg);     
        
        
  cfg = [];
        cfg.trials = find(...
            data.trialinfo == 223 |...
            data.trialinfo == 224 |...
            data.trialinfo == 225);
        if ~isempty(cfg.trials)
            erps.face_up = ft_timelockanalysis(cfg, data);
            cfg = [];
            cfg.baseline = [-.2, 0];
            erps.face_up = ft_timelockbaseline(cfg, erps.face_up);
        else
            erps.face_up = [];
        end        
        
        
        
        