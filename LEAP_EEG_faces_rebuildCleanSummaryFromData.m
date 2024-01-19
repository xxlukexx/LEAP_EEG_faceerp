path_avg =     '/Volumes/Projects/LEAP/EEG/faces/20181214/03_clean30';
d = dir(sprintf('%s%s*.mat', path_avg, filesep));

smry = cell(length(path_avg), 1);
parfor f = 1:length(d)
    
    tmp = load(fullfile(path_avg, d(f).name));
    try
        smry{f} = tmp.data.summary;
    catch ERR
        smry{f} = struct;
        smry{f}.error = ERR.message;
    end
    fprintf('%.2f%%\n', f / length(d) * 100)
    
end

