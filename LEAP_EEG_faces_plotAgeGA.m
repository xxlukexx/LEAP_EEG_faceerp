load('/Users/luke/code/Experiments/face erp/LEAP_EEG_faces_measures_20190510T101236.mat')
    
% tab_mes = tab_mes(strcmpi(tab_mes.cond, 'face_up'), :);

% 3yr age bins
bins = 6:3:30;
idx_bin = discretize(tab_mes.age_years, bins);
numBins = length(bins);
tab_mes(isnan(idx_bin), :) = [];
idx_bin(isnan(idx_bin)) = [];
% tab_mes.agebin3 = bins(idx_bin)';
tab_mes.agebin3 = arrayfun(@num2str, bins(idx_bin), 'UniformOutput', false)';
eegPlotFactorialGA2(tab_mes, 'N170p', 'compare', 'agebin3')
eegPlotFactorialGA2(tab_mes, 'N170p', 'compare', 'cond', 'plotSEM', true, 'linewidth', 4, 'colMap', 'winter', 'fontsize', 20)

% 5 yr age bins
bins = 6:5:30;
idx_bin = discretize(tab_mes.age_years, bins);
numBins = length(bins);
tab_mes(isnan(idx_bin), :) = [];
idx_bin(isnan(idx_bin)) = [];
tab_mes.agebin5 = arrayfun(@num2str, bins(idx_bin), 'UniformOutput', false)';
eegPlotFactorialGA2(tab_mes, 'N170p', 'compare', 'agebin5')

% whole sample
eegPlotFactorialGA2(tab_mes, 'N170p')