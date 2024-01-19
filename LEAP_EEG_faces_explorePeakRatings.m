client = teAnalysisClient;
client.HoldQuery = {'Study', 'LEAP', 'faceerp_avged', true};
client.ConnectToServer('193.61.45.196', 3000)

%%

tab = client.Table;
vars = tab.Properties.VariableNames;
idx_vars = instr(vars, 'rating') & ~instr(vars, 'summary') &...
    ~instr(vars, 'N2') & ~instr(vars, 'P2');
tab = [tab(:, 1:5), tab(:, idx_vars)];

%%
% 
% rating_cell = tab{:, 6:end};
% rating_pnc = false(size(rating_cell));
% rating_dbl = false(size(rating_cell));
% rating_chk = false(size(rating_cell));
% 
% idx_pnc = cellfun(@(x) strcmpi(x, 'Peaks not clear'), rating_cell);
% idx_dbl = cellfun(@(x) strcmpi(x, 'Double peak'), rating_cell);
% idx_chk = cellfun(@(x) strcmpi(x, 'Other (needs checking)'), rating_cell);
% 
% rating_pnc(idx_pnc) = true;
% rating_dbl(idx_dbl) = true;
% rating_chk(idx_chk) = true;
% 
% figure('Name', 'Peaks not clear')
% heatmap(double(rating_pnc), 'GridVisible', 'off', 'XDisplayLabels', vars(idx_vars))
% 
% figure('Name', 'Double peak')
% heatmap(double(rating_dbl), 'GridVisible', 'off', 'XDisplayLabels', vars(idx_vars))
% 
% figure('Name', 'Needs checking')
% heatmap(double(rating_chk), 'GridVisible', 'off', 'XDisplayLabels', vars(idx_vars))

%%
tab.peakrating_any_unclear = any(idx_pnc, 2);
tab.peakrating_any_double = any(idx_pnc, 2);

prop(tab.peakrating_any_unclear)

vars_elec = tab.Properties.VariableNames;
idx_vars_elec = instr(vars_elec, 'P1o') | instr(vars_elec, 'N170p');
idx_vars_elec(1:5) = true;
tab_elec = tab(:, idx_vars_elec);
ratings_elec = tab_elec{:, 6:end};

rating_pnc = false(size(rating_cell));
rating_dbl = false(size(rating_cell));
rating_chk = false(size(rating_cell));

idx_pnc = cellfun(@(x) strcmpi(x, 'Peaks not clear'), rating_cell);
idx_dbl = cellfun(@(x) strcmpi(x, 'Double peak'), rating_cell);
idx_chk = cellfun(@(x) strcmpi(x, 'Other (needs checking)'), rating_cell);

rating_pnc(idx_pnc) = true;
rating_dbl(idx_dbl) = true;
rating_chk(idx_chk) = true;

figure('Name', 'Peaks not clear')
heatmap(double(rating_pnc), 'GridVisible', 'off', 'XDisplayLabels', vars(idx_vars))

figure('Name', 'Double peak')
heatmap(double(rating_dbl), 'GridVisible', 'off', 'XDisplayLabels', vars(idx_vars))

figure('Name', 'Needs checking')
heatmap(double(rating_chk), 'GridVisible', 'off', 'XDisplayLabels', vars(idx_vars))

tab_elec.any_unclear = any(idx_pnc, 2);
prop(tab_elec.any_unclear)