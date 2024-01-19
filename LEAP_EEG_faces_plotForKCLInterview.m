file_tab = teFindFile('/Users/luke/code/Experiments/face erp', 'LEAP_EEG_faces_measures*.mat', '-latest');
load(file_tab)
tab_mes = LEAP_recode(tab_mes);

% % detrend ERPs
% erp_avg = tab_mes.erp_avg;
% parfor i = 1:size(tab_mes, 1)
%     erp_avg{i} = ft_preproc_polyremoval(erp_avg{i}, 1);
%     erp_avg{i} = highpass(erp_avg{i}, 10, 1000);
% end
% tab_mes.erp_avg = erp_avg;

path_fig = '/Users/luke/code/Experiments/face erp/paper/final';
% load('/Users/luke/code/Experiments/face erp/LEAP_EEG_faces_measures_20190522T094851.mat')

% replace low IQ true/false with string 'yes'/'no'
idx_lowiq = tab_mes.lowiq;
tab_mes.lowiq = [];
tab_mes.lowiq = repmat({'yes'}, size(tab_mes, 1), 1);
tab_mes.lowiq(~idx_lowiq) = repmat({'no'}, sum(~idx_lowiq), 1);

%%  face up

% sort properly by age (not alphabetically by age label)
[ag_u, ~, ag_s] = unique(tab_mes.agegrp);
idx_col_kids = find(strcmpi(ag_u, 'Children'), 1);
idx_col_teens = find(strcmpi(ag_u, 'Adolescents'), 1);
idx_col_adults = find(strcmpi(ag_u, 'Adults'), 1);
idx_kids = ag_s == idx_col_kids;
idx_teens = ag_s == idx_col_teens;
idx_adults = ag_s == idx_col_adults;
tab_mes.so_age = ones(size(tab_mes, 1), 1);               % children
tab_mes.so_age(idx_teens) = repmat(2, sum(idx_teens), 1);    % teens
tab_mes.so_age(idx_adults) = repmat(3, sum(idx_adults), 1);  % adults
tab_mes = sortrows(tab_mes, {'comp', 'cond', 'elec', 'so_age'});

% replace NT with CTRL
tab_mes.diag = strrep(tab_mes.diag, 'NT', 'CTRL');

idx_fu = strcmpi(tab_mes.cond, 'face_up');
tab_mes_fu = tab_mes(idx_fu, :);
tab_mes_fi = tab_mes(~idx_fu, :);

close all

    %% N170
    
        % ME of diag
        
            bgcol = [30, 24, 52] / 255;
            fgcol = [207, 146, 65] / 255;
            close all
            diag_fu_n170 = eegPlotFactorialGA2(...
                                tab_mes, 'N170p',...
                                'name', 'Diagnosis',...
                                'compare', 'diag',...
                                'plotHist', true,...
                                'makeTable', true,...
                                'plotBoxPlot', false,...
                                'linewidth', 7,...
                                'SEMAlpha', .2,...
                                'fontsize', 40,...
                                'detrend', true) 
            xlim([-.100, 0.400])