function [erps, ops] = LEAP_EEG_faces_03_doAverage(path_in, path_out)
        
    % get ID
    [~, id, ~] = fileparts(path_in);
    
    % make output filename
    file_out = [id, '.average', '.mat'];
    
    % summary defaults 
    ops.file_erps = '';
    erps = [];
    ops.avgValid = false;
    ops.avgError = 'Unknown error';
    ops.avg_PathOut = path_out;
    ops.avg_FileOut = file_out;
    
    % load
    data = [];
    load(path_in);
    if isempty(data)
        ops.avgValid = false;
        ops.avgError = 'Load error';
        return
    end
        
    % get audit and summary structs from data 
    if isfield(data, 'summary')
        ops = catstruct(data.summary, ops);
        art = data.art;
        chanExcl = data.chanExcl;
        data = rmfield(data, {'interp', 'interpNeigh', 'cantInterp',...
            'summary', 'chanExcl', 'art_type', 'art'});
    end

    % check output path exists
    if ~exist(path_out, 'dir')
        ops.avgError = 'Output path does not exist.';
        return
    end
    
%     try
        
        %% make ERPs
        
        % flatten arterfact matrix
        art = any(art, 3);
        
        % drop trials with artefacts
        cfg = [];
        badTrials = any(art(~chanExcl, :), 1);
        if sum(badTrials) == length(data.trial)
            ops.avgValid = false;
            ops.avgError = 'No good trials';
            return
        end
        cfg.trials = ~badTrials;
        if any(badTrials), data = ft_selectdata(cfg, data); end
        
        % avg ref
        cfg = [];
        cfg.reref = 'yes';
        cfg.refchannel = data.label(~chanExcl);
        data = ft_preprocessing(cfg, data);

        % face up
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

        % face inv
        cfg = [];
        cfg.trials = find(...
            data.trialinfo == 226 |...
            data.trialinfo == 227 |...
            data.trialinfo == 228);
        if ~isempty(cfg.trials)
            erps.face_inv = ft_timelockanalysis(cfg, data);
            cfg = [];
            cfg.baseline = [-.2, 0];
            erps.face_inv = ft_timelockbaseline(cfg, erps.face_inv);
        else
            erps.face_up = [];
        end
        
        if isempty(erps.face_up) || isempty(erps.face_inv)
            ops.avgValid = false;
            ops.avgError = 'At least one condition has zero trials.';
            return
        end
        
        %% find peaks
        
        erps = LEAP_EEG_faces_findPeaks(erps);
        
        %% store
        
        ops.avgValid = true;
        ops.avgError = 'None';
    
        % store summary and audit
        erps.summary = ops;
        
        % save
        save(fullfile(path_out, file_out), 'erps', '-v6');
        
%     catch ERR
%         
%         ops.avgError = ERR.message;
%         ops.avgValid = false;
%         erps = [];
%         return
%         
%     end
    


end