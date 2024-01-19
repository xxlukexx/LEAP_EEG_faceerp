path_mrk = '/Users/luke/Google Drive/CBCD/EU-AIMS/Task 2/EEG timing KCL/test09.vmrk';
ev =  ft_read_event(path_mrk);

fs = 5000;
tab = struct2table(ev);

% remove crap
idx_rem = ~strcmpi(tab.type, 'Toggle');
tab(idx_rem, :) = [];


tab.vals = cell2mat(extractNumeric(tab.value));
tab.t = tab.sample / fs;

% find first marker (==2)
idx_first = find(tab.vals ~= 128, 1);
tab = tab(idx_first:end, :);

% make table of markers
idx_marker = tab.vals ~= 128;
tab_marker = tab(idx_marker, :);

% make table of photodiode
idx_screen = tab.vals == 128;
tab_screen = tab(idx_screen, :);

% equalise sizes
sz_marker = size(tab_marker, 1);
sz_screen = size(tab_screen, 1);
if sz_marker > sz_screen
    tab_marker = tab_marker(1:sz_screen, :);
elseif sz_screen > sz_marker
    tab_screen = tab_screen(1:sz_marker, :);
end

tab_timing = table;
tab_timing.marker = tab_marker.t;
tab_timing.screen = tab_screen.t;

% calculate delta
tab_timing.delta = (tab_timing.screen - tab_timing.marker) * 1000;

histogram(tab_timing.delta)
title(path_mrk)