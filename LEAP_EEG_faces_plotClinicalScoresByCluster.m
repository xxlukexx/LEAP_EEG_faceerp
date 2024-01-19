addpath('/users/luke/code/Experiments/face erp/')
addpath('/users/luke/code/Experiments/face erp/clustering')

% load and format cluster membership 
file_clus = '/Users/luke/code/Experiments/face erp/clustering/DataforLuke-figclust.xlsx';
if ~exist(file_clus, 'file') 
    error('Cluster membership file not found at: %s', file_clus)
end
tab_clus = readtable(file_clus, 'Range', [2, 3]);
tab_clus.ID = arrayfun(@num2str, tab_clus.ID, 'uniform', false);

% append clinical data
tab = LEAP_appendMetadata_t1t2(tab_clus, 'ID');

% filter for wanted clinical vars only
wantedVars = {...
    't1_fsiq'                       ;...
    't1_adi_social_total'           ;...
    't1_adi_communication_total'    ;...
    't1_adi_rrb_total'              ;...
    't1_sa_css'                     ;...
    't1_rrb_css'                    ;...
    't1_srs_tscore'                 ;...
    't1_dawba_int'                  ;...
    't1_dawba_ext'                 ;...
    't1_dawba_adhd'                  ;...
    't1_vabsdscoresc_dss'           ;...
    't1_vabsdscoresd_dss'           ;...
    't1_vabsdscoress_dss'           ;...
    };
tab = tab(:, [{'ClusterBIN'}, {'diag'}, wantedVars(:)']);

% convert missing to NaN
tab = standardizeMissing(tab, {777, 999, nan});

% format for spiderplot [groups, vars]
m = tab{:, 3:end};
vars = strrep(tab.Properties.VariableNames(3:end), '_', ' ');
numVars = size(m, 2);
numGrps = length(unique(tab.ClusterBIN));
agg = nan(numGrps, numVars);
for c = 1:numVars
    agg(:, c) = accumarray(tab.ClusterBIN, m(:, c), [], @nanmean);
end

%%

spider_plot(agg, 'AxesLabels', vars, 'FillOption', 'on', 'axesfontsize', 16)
legend('Cluster 1', 'Cluster 2', 'Cluster 3')