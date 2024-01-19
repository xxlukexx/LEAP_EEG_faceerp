ac = teAnalysisClient;
ac.ConnectToServer('lm-analysis.local', 3000)
ac.HoldQuery = {'Study', 'LEAP', 'faceerp_avged', true};
tab = ac.Table;
idx_pr = instr(tab.Properties.VariableNames, 'peakrating') &...
    ~instr(tab.Properties.VariableNames, 'P2') &...
    ~instr(tab.Properties.VariableNames, 'N2') &...
    ~instr(tab.Properties.VariableNames, 'summary');
tab_pr = [tab(:, 1:2), tab(:, idx_pr)];
vars_pr = tab.Properties.VariableNames(idx_pr);

% remove empty
idx_empty = false(size(tab_pr, 1), size(tab_pr, 2) - 2);
for i = 3:size(tab_pr, 2)
    val = tab_pr{:, i};
    idx_empty(:, i - 2) = cellfun(@isempty, val);
end
idx_empty = any(idx_empty, 2);
tab_pr(idx_empty, :) = [];

% tabulate across table
tbl_n = cell(length(vars_pr), 1);
tbl_p = cell(length(vars_pr), 1);
for i = 3:size(tab_pr, 2)
    val = tab_pr{:, i};
    tmp = tabulate(val);
    tbl_n{i - 2} = cell2struct(tmp(:, 2), fixTableVariableNames(tmp(:, 1)));
    tbl_p{i - 2} = cell2struct(tmp(:, 3), fixTableVariableNames(tmp(:, 1)));
end
smry_n = teLogExtract(tbl_n);
smry_n = [cell2table(vars_pr', 'VariableNames', {'Component'}), smry_n];

smry_p = teLogExtract(tbl_p);
smry_p = [cell2table(vars_pr', 'VariableNames', {'Component'}), smry_p];
    
% find datasets with at least one unclear peak


    