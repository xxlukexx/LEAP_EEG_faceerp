%%
load(path_file)

numChans = length(data.label);
numTrials = length(data.trial);

[pth, fl, ext] = fileparts(path_file);
filename = [fl, ext];
path_plot = '/Users/luke/Desktop/eegplots';

parfor tr = 1:50
    
    tab = table;
    tab.noise = nan(numChans, 1);
    tab.noise_bl = nan(numChans, 1);
    tab.noise_trial = nan(numChans, 1);

    for ch = 1:numChans

        idx_bl = data.time{tr} < 0;

        diff_all = diff(data.trial{tr}(ch, :));
        diff_bl = diff(data.trial{tr}(ch, idx_bl));
        diff_trial = diff(data.trial{tr}(ch, ~idx_bl));

        tab.noise(ch) = mean(sqrt(diff_all .^ 2));
        tab.noise_bl(ch) = mean(sqrt(diff_bl .^ 2));
        tab.noise_trial_mu(ch) = mean(sqrt(diff_trial .^ 2));
        tab.noise_trial_sd(ch) = mean(sqrt(diff_trial .^ 2));

    end

    tab.channel = data.label;
    tab.noise_ratio = tab.noise_trial ./ tab.noise_bl;
    tab.noise_trial_mu_z = abs(zscore(tab.noise_trial_mu));
    tab.noise_trial_sd_z = abs(zscore(tab.noise_trial_sd));

    var = 'noise_trial_sd';

    fig = figure('position', [351.0000 70 1.7272e+03 1.0638e+03],...
        'visible', 'off',...
        'name', path_file);
    whitebg(gcf, 'k')

    nsp = numSubplots(numChans);
    [~, tab.rank] = sort(tab.(var));
    tab = tab(tab.rank, :);

    thresh = 35;

    cols = jet(numChans);
    for ch = 1:numChans

        subplot(nsp(1), nsp(2), ch)

        idx_ch = strcmpi(data.label, tab.channel{ch});
        plot(data.time{tr}, data.trial{tr}(idx_ch, :))
        box on
        set(gca, 'xcolor', cols(ch, :))
        title(sprintf('%s = %.2f', data.label{idx_ch}, tab.(var)(ch)))

        if tab.(var)(ch) > thresh, set(gca, 'Color', [.5, 0, 0]), end

    end

%     tightfig
%     set(fig, 'visible', 'on');
    export_fig(fullfile(path_plot, sprintf('%s_trial_%.2d', filename, tr)));
    
    fprintf('%d of %d\n', tr, 10);
    
end

tilefigs

%%a