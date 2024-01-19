client = teAnalysisClient;
client.HoldQuery = {'Study', 'LEAP', 'faceerp_avged', true};
client.ConnectToServer('193.61.45.196', 3000)

numData = client.NumDatasets;
tab = client.Table;
for i = 1:numData
    
    md = client.GetMetadata('GUID', tab.GUID{i});
    erp = client.GetVariable('faceerp_avg30', 'GUID', md.GUID);
    if ~isempty(erp) && isfield(erp, 'summary')
        if isfield(erp.summary, 'totaltrials')
            md.dq.total_trials = erp.summary.totaltrials;
        end        
        if isfield(erp.summary, 'tpc_up')
            md.dq.tpc_up = erp.summary.tpc_up;
        end
        if isfield(erp.summary, 'tpc_inv')
            md.dq.tpc_inv = erp.summary.tpc_inv;
        end
        if isfield(erp.summary, 'numChanInterp')
            md.dq.num_chan_interp = erp.summary.numChanInterp;
        end        
        if isfield(erp.summary, 'numChanExcl')
            md.dq.num_chan_excl = erp.summary.numChanExcl;
        end           
        if isfield(erp.summary, 'propInterp')
            md.dq.prop_interp = erp.summary.propInterp;
        end
        
    end
    client.UpdateMetadata(md);
    fprintf('<strong>%d of %d</strong>\n', i, numData);
        
end
