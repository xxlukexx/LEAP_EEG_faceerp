path_face_erp = '/Users/luke/code/Experiments/face erp/LEAP_EEG_faces_measures_20190522T094851.mat';
load(path_face_erp);
tab_mes = tab_mes(logical(tab_mes.include), :);

path_erps = '/Volumes/Projects/LEAP/EEG/faces/20181214/04_avg30';
d = dir([path_erps, filesep, '*.mat']);
erps = cellfun(@load, fullfile({d.folder}, {d.name}), 'UniformOutput', false);
val = cellfun(@(x) hasField(x, 'erps') && hasField(x.erps, 'face_up') && hasField(x.erps, 'face_inv'), erps);
face_up = cellfun(@(x) x.erps.face_up, erps(val), 'UniformOutput', false);
face_inv = cellfun(@(x) x.erps.face_inv, erps(val), 'UniformOutput', false);

parts = cellfun(@(x) strsplit(x, '.'), {d.name}, 'UniformOutput', false);
id = cellfun(@(x) x{1}, parts, 'UniformOutput', false);
tab = cell2table(id(val)', 'VariableNames', {'id'});
[tab, ~, ~, diag_u, diag_s] = LEAP_appendMetadata_t1t2(tab, 'id');

cfg = [];
ga_fu_asd = ft_timelockgrandaverage(cfg, face_up{diag_s == 1});
ga_inv_asd = ft_timelockgrandaverage(cfg, face_inv{diag_s == 1});
ga_fu_nt = ft_timelockgrandaverage(cfg, face_up{diag_s == 2});
ga_inv_nt = ft_timelockgrandaverage(cfg, face_inv{diag_s == 2});

cfg = [];
cfg.detrend = 'yes';
ga_fu_asd = ft_preprocessing(cfg, ga_fu_asd);
ga_inv_asd = ft_preprocessing(cfg, ga_inv_asd);
ga_fu_nt = ft_preprocessing(cfg, ga_fu_nt);
ga_inv_nt = ft_preprocessing(cfg, ga_inv_nt);


%% N170

figure('defaultaxesfontsize', 20)
clf
cfg.layout = 'EEG1010.lay';
cfg.comment = 'no';
cfg.xlim = [0.150, 0.250];
cfg.highlight = 'labels';
cfg.highlightcolor = [.9, .1, .1];
cfg.highlightfontsize = 24;
cfg.highlightchannel = {'P7', 'P8'};
cfg.colorbar = 'no';
cfg.zlim = [-2, 4];

subplot(2, 2, 1)
    ft_topoplotER(cfg, ga_fu_asd)
    title('ASD | Face Upright')

subplot(2, 2, 2)
    ft_topoplotER(cfg, ga_inv_asd)
    title('ASD | Face Inverted')
    
subplot(2, 2, 3)
    ft_topoplotER(cfg, ga_fu_nt)
    title('CTRL | Face Upright')
    
subplot(2, 2, 4)
    cfg.colorbar = 'yes';
    ft_topoplotER(cfg, ga_inv_nt)
    title('CTRL | Face Inverted')

h = findobj(gcf, 'type', 'text');
for i = 1:length(h)
    h(i).Color = [1, 1, 1];
end
set(gcf, 'color', 'w')

h_cb = findobj('type', 'colorbar');
ylabel(h_cb, 'N170 Mean Amplitude (µV)')


path_fig = '/Users/luke/code/Experiments/face erp/paper/v5/figures';
file_out = fullfile(path_fig, sprintf('N170_topomap_%s.png',...
    datestr(now, 30)));
export_fig(file_out, '-r300')  



%% P2

figure('defaultaxesfontsize', 20)
clf
cfg.layout = 'EEG1010.lay';
cfg.comment = 'no';
cfg.xlim = [0.210, 0.310];
cfg.highlight = 'labels';
cfg.highlightcolor = [.9, .1, .1];
cfg.highlightfontsize = 24;
cfg.highlightchannel = {'P7', 'P8'};
cfg.colorbar = 'no';
cfg.zlim = [-2, 4];

% subplot(2, 2, 1)
    ft_topoplotER(cfg, ga_fu_asd)
    title('ASD | Face Upright')

% subplot(2, 2, 2)
    ft_topoplotER(cfg, ga_inv_asd)
    title('ASD | Face Inverted')
    
% subplot(2, 2, 3)
    ft_topoplotER(cfg, ga_fu_nt)
    title('CTRL | Face Upright')
    
% subplot(2, 2, 4)
    cfg.colorbar = 'yes';
    ft_topoplotER(cfg, ga_inv_nt)
    title('CTRL | Face Inverted')

h = findobj(gcf, 'type', 'text');
for i = 1:length(h)
    h(i).Color = [1, 1, 1];
end
set(gcf, 'color', 'w')

h_cb = findobj('type', 'colorbar');
ylabel(h_cb, 'N2 Mean Amplitude (µV)')

% 
% path_fig = '/Users/luke/code/Experiments/face erp/paper/v5/figures';
% file_out = fullfile(path_fig, sprintf('N170_topomap_%s.png',...
%     datestr(now, 30)));
% export_fig(file_out, '-r300')  


%% N2

figure('defaultaxesfontsize', 20)
clf
cfg.layout = 'EEG1010.lay';
cfg.comment = 'no';
cfg.xlim = [0.290, 0.320];
cfg.highlight = 'labels';
cfg.highlightcolor = [.9, .1, .1];
cfg.highlightfontsize = 24;
cfg.highlightchannel = {'P7', 'P8'};
cfg.colorbar = 'no';
cfg.zlim = [-2, 4];

subplot(2, 2, 1)
    ft_topoplotER(cfg, ga_fu_asd)
    title('ASD | Face Upright')

subplot(2, 2, 2)
    ft_topoplotER(cfg, ga_inv_asd)
    title('ASD | Face Inverted')
    
subplot(2, 2, 3)
    ft_topoplotER(cfg, ga_fu_nt)
    title('CTRL | Face Upright')
    
subplot(2, 2, 4)
    cfg.colorbar = 'yes';
    ft_topoplotER(cfg, ga_inv_nt)
    title('CTRL | Face Inverted')

h = findobj(gcf, 'type', 'text');
for i = 1:length(h)
    h(i).Color = [1, 1, 1];
end
set(gcf, 'color', 'w')

h_cb = findobj('type', 'colorbar');
ylabel(h_cb, 'N2 Mean Amplitude (µV)')

% 
% path_fig = '/Users/luke/code/Experiments/face erp/paper/v5/figures';
% file_out = fullfile(path_fig, sprintf('N170_topomap_%s.png',...
%     datestr(now, 30)));
% export_fig(file_out, '-r300')  
