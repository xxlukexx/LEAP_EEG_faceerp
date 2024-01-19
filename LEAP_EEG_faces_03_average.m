% try

    clear variables
    addpath('/Users/luke/Google Drive/Dev/fieldtrip-20180320')
    addpath('/Users/luke/Google Drive/Experiments/LEAP')
    addpath('/Users/luke/Google Drive/Dev/eegtools')
    addpath(genpath('/Users/luke/Google Drive/Dev/lm_tools'))
    ft_defaults    
    tic

    stat = ECKStatus('Starting up...');

    % get paths
    [expPath, dataPath, gPath] = getExperimentsPath;
    addpath('/Users/luke/Google Drive/Dev/fieldtrip-20180320')
    addpath('/Users/luke/Google Drive/Experiments/LEAP')
    addpath('/Users/luke/Google Drive/Dev/eegtools')
    addpath(genpath('/Users/luke/Google Drive/Dev/lm_tools'))
    ft_defaults

    % output path
    path_out = fullfile(dataPath, 'LEAP', 'EEG', 'faces',...
        '20181214', '04_avg30');
    if ~exist(path_out, 'dir'), mkdir(path_out); end

    % input path
    path_clean = fullfile(dataPath, 'LEAP', 'EEG', 'faces',...
        '20181214', '03_clean30');
    path_cleanRes = [path_clean, filesep, '_results.mat'];
    clean = load(path_cleanRes);
    files_clean = cellfun(@(x) horzcat(path_clean, filesep, x),...
        clean.res.clean_FileOut, 'uniform', false);
    clean_val = cellfun(@isempty, clean.res.error);
    files_clean = files_clean(clean_val);
    numFiles = length(files_clean);

    % send data to workers
    futCounter = 0;
    for f = 1:numFiles
        futCounter = futCounter + 1;
        path_in = files_clean{f};
        fut(futCounter) =...
            parfeval(@LEAP_EEG_faces_03_doAverage, 2, path_in, path_out);
        stat.Status =...
            sprintf('Load: Sending dataset %d to workers...', futCounter);
    end
    stat.Status = 'Waiting for first job to complete...';

    % retrieve loaded data
    summaries = cell(futCounter, 1);
    for f = 1:futCounter
        [idx, ~, tmpSummary] = fetchNext(fut);
        summaries{f} = tmpSummary;
        stat.Status =...
            sprintf('Load: Received dataset %d from worker (%.1f%% | %.1f datasets/m)...',...
            idx, (f / futCounter) * 100, f / (toc / 60));
    end

    tmp = vertcat(summaries{:});
    res = struct2table(tmp);
    save([path_out, filesep, '_results.mat'], 'res', 'summaries');

    toc
    
% catch ERR
%     
% %     notifyByEmail('Error', evalc('disp(ERR)'));
%     rethrow ERR
%     
% end

msg = tabulate(res.avgError);
% notifyByEmail('LEAP_EEG_faces_02_average - COMPLETE', evalc('disp(msg)'));
