 lm_addCommonPaths
set(0,'defaultAxesFontSize',20)

% prepare gaussian process model functions

    addpath('/Users/luke/code/Dev/gpml-matlab-master')
    startup

% load ERP measures, filter for N170 and 

    tmp = load('/Users/luke/Google Drive/Experiments/face erp/may19/LEAP_EEG_faces_casecontrol_data.mat',...
        'tab_up');
    tab = tmp.tab_up;
    
    % filter for just N170 parietal component
    idx_n170 = strcmpi(tab.comp, 'N170p');
    tab = tab(idx_n170, :);
       
    % average P7/P8
    tab = aggregateTable(tab, {'ID'}, {'lat', 'mamp', 'include', 'val'}, @mean);
    
    % remove invalid
    tab(tab.include ~= 1 | tab.val ~= 1, :) = [];
    
    % recode schedule/group to agegrp/diag
    tab = LEAP_recode(tab);
    
% prepare NT data
    
    % find NT participants
    idx_nt = strcmpi(tab.diag, 'NT');
    
    % get [age, latency] for NT participants
    xc = tab.age_years(idx_nt);
    yc = tab.lat(idx_nt);
    
    %Make figure for controls
    subplot(2,1,1)
    plot(xc, yc, '+', 'MarkerSize', 12)
    grid on
    xlabel('Age (years)')
    ylabel('N170 latency (µV)')
    
% estimation of the model
    
    meanfunc = []; % empty: don't use a mean function
    
    covfunc = @covSEiso; % Squared Exponental covariance function
    ell=365; 
    sf=1;
    hyp.cov = log([ell;sf]);
    likfunc = @likGauss; sn = 1; hyp.lik = log(sn); % Gaussian likelihood
    
    nlml = gp(hyp, @infExact, meanfunc, covfunc, likfunc, xc, yc);
    
    hyp = minimize(hyp, @gp, -1000, @infExact, meanfunc, covfunc, likfunc, xc, yc);
    z = linspace(min(xc), max(xc), 100)';
    [m, s2] = gp(hyp, @infExact, meanfunc, covfunc, likfunc, xc, yc, z);
    f = [m+2*sqrt(s2); flipdim(m-2*sqrt(s2),1)];
    fill([z; flipdim(z,1)], f, [7 7 7]/8);
    hold on;
    f = [m+sqrt(s2); flipdim(m-sqrt(s2),1)];
    fill([z; flipdim(z,1)], f, [5 5 5]/8)
    plot(z, m);
    h1 = plot(xc, yc, 'b+');
    
% plot ASD

    xa = tab.age_years(~idx_nt);
    ya = tab.lat(~idx_nt);
    
    [mp s2p] = gp(hyp, @infExact, meanfunc, covfunc, likfunc, xc, yc, xa);
    za = (ya-mp)./sqrt(s2p);
    
    [mc s2c] = gp(hyp, @infExact, meanfunc, covfunc, likfunc, xc, yc, xc);
    zc = (yc-mc)./sqrt(s2c);
   
    subplot(2,1,2)
    M = ceil(max(abs(za)));
    edges = linspace(-M, M, 100);
    
    distC = histc(zc, edges);
    distP = histc(za, edges);
    
    b1 = bar(edges, [distC, distP]);
    set(b1(1),'FaceColor','b');
    set(b1(2),'FaceColor','r');
    legend('NT', 'ASD')
    
    [h,p,k] = kstest2(distC,distP);
    title(['Two-sample Kolmogorov-Smirnov test: K=',num2str(k),' (p=',num2str(p),')'])
    xlabel('Z-score (deviation from TD norm)')
    ylabel('Frequency')
    subplot(2,1,1)
    clear rank
   
    flipFlag = 1;
    for i = 1: length(ya)
        % 0 score, between mean and 1SD either side
        if ya(i) <= mp(i)+(sqrt(s2p(i))) && ya(i) >= mp(i)-(sqrt(s2p(i)));
            rank(i)= 0 * flipFlag;   
            % -1 score, between +1SD and +2SD
        elseif ya(i) > mp(i)+(sqrt(s2p(i)))  && ya(i) <= mp(i)+(2*sqrt(s2p(i)));
            rank(i)= -1 * flipFlag;  
            % +1 score, between -1SD and -2SD
        elseif ya(i) < mp(i)-(sqrt(s2p(i)))  && ya(i) >= mp(i)-(2*sqrt(s2p(i)));
            rank(i)= 1 * flipFlag; 
            % -2 score, greater than +2SD
        elseif ya(i) > mp(i)+(2*sqrt(s2p(i)));
            rank(i)= -2 * flipFlag;  
            % +2 score, less than -2SD
        elseif ya(i) < mp(i)-(2*sqrt(s2p(i)));
            rank(i)= 2 * flipFlag;
        end
    end
    rank=rank';
    
    tab_norm_z_asd = table;
    tab_norm_z_asd.id = tab.ID(~idx_nt);
    tab_norm_z_asd.n170p_lat_raw = tab.lat(~idx_nt);
    tab_norm_z_asd.n170p_lat_norm_z = za;
    
 % check fit
 
    age = xc;
    age_bins = z;
    
    % find age bin for each subject
    bin_idx = nan(size(age));
    for i = 1:length(age)
        delta = abs(age(i) - age_bins);
        bin_idx(i) = find(delta == min(delta));
    end
    
    % for each subject, find the N170 latency predicted by the model
    pred = m(bin_idx);
    
    % calculate RMSE for the model
    rmse_model = rms(pred - yc);
    
    % do linear fit
    mdl = fitlm(age, yc, 'linear')
    rmse_linear = mdl.RMSE;
    
    % get sum of squared errors for mean, linear, and gpml
    ss_mu = sum((mean(yc) - yc) .^ 2);
    ss_lin = sum(mdl.Residuals.Raw .^ 2);
    ss_gp = sum((pred - yc) .^ 2);
    ss_total = sum(yc .^ 2);
