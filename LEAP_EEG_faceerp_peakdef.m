addpath(genpath('/Users/luke/Google Drive/Dev/eegtools'))
addpath(genpath('/Users/luke/Google Drive/Dev/stim/_master/TaskEngine2'))
addpath(genpath('/Users/luke/Google Drive/Dev/lm_tools'))

server_address = 'lm-analysis.local';

% define default peak locations
peak_P1 = 0.100;
peak_N1 = 0.170;
peak_P2 = 0.300;
peak_N2 = 0.350;

% define window width (windows are defined symetrically around the peaks)
winWidth = 0.030;

% translate peaks and window width to windows
win_p1 = [peak_P1 - winWidth, peak_P1 + winWidth];
win_n1 = [peak_N1 - winWidth, peak_N1 + winWidth];
win_p2 = [peak_P2 - winWidth, peak_P2 + winWidth];
win_n2 = [peak_N2 - winWidth, peak_N2 + winWidth];

% define peaks of interest
def = {...
    'P1o',      'O1',       'Left',         win_p1,     'face_up',      'positive'    ;...
    'P1o',      'O2',       'Right',        win_p1,     'face_up',      'positive'    ;...
    'P1p',      'P7',       'Left',         win_p1,     'face_up',      'positive'    ;...
    'P1p',      'P8',       'Right',        win_p1,     'face_up',      'positive'    ;...
    'N170p',    'P7',       'Left',         win_n1,     'face_up',      'negative'    ;...
    'N170p',    'P8',       'Right',        win_n1,     'face_up',      'negative'    ;...
    'P1o',      'O1',       'Left',         win_p1,     'face_inv',     'positive'    ;...
    'P1o',      'O2',       'Right',        win_p1,     'face_inv',     'positive'    ;...
    'P1p',      'P7',       'Left',         win_p1,     'face_inv',     'positive'    ;...
    'P1p',      'P8',       'Right',        win_p1,     'face_inv',     'positive'    ;...
    'N170p',    'P7',       'Left',         win_n1,     'face_inv',     'negative'    ;...
    'N170p',    'P8',       'Right',        win_n1,     'face_inv',     'negative'    ;...
    };
% def = {...
%     'P1o',      'O1',       'Left',         win_p1,     'face_up',      'positive'    ;...
%     'P1o',      'O2',       'Right',        win_p1,     'face_up',      'positive'    ;...
%     'P1p',      'P7',       'Left',         win_p1,     'face_up',      'positive'    ;...
%     'P1p',      'P8',       'Right',        win_p1,     'face_up',      'positive'    ;...
%     'N170p',    'P7',       'Left',         win_n1,     'face_up',      'negative'    ;...
%     'N170p',    'P8',       'Right',        win_n1,     'face_up',      'negative'    ;...
%     'P2p',      'P7',       'Left',         win_p2,     'face_up',      'positive'    ;...
%     'P2p',      'P8',       'Right',        win_p2,     'face_up',      'positive'    ;...
%     'N2p',      'P7',       'Left',         win_n2,     'face_up',      'negative'    ;...
%     'N2p',      'P8',       'Right',        win_n2,     'face_up',      'negative'    ;...
%     'P1o',      'O1',       'Left',         win_p1,     'face_inv',     'positive'    ;...
%     'P1o',      'O2',       'Right',        win_p1,     'face_inv',     'positive'    ;...
%     'P1p',      'P7',       'Left',         win_p1,     'face_inv',     'positive'    ;...
%     'P1p',      'P8',       'Right',        win_p1,     'face_inv',     'positive'    ;...
%     'N170p',    'P7',       'Left',         win_n1,     'face_inv',     'negative'    ;...
%     'N170p',    'P8',       'Right',        win_n1,     'face_inv',     'negative'    ;...
%     'P2p',      'P7',       'Left',         win_p2,     'face_inv',     'positive'    ;...
%     'P2p',      'P8',       'Right',        win_p2,     'face_inv',     'positive'    ;...
%     'N2p',      'P7',       'Left',         win_n2,     'face_inv',     'negative'    ;...
%     'N2p',      'P8',       'Right',        win_n2,     'face_inv',     'negative'    ;...
%     };

% put peak def into table
def = cell2table(def, 'VariableNames', {'component', 'electrode',...
    'hemi', 'window', 'condition', 'polarity'});

% set up database
client = teAnalysisClient;
client.HoldQuery = {'Study', 'LEAP', 'faceerp_avged', true, 'check_lat_N170p_face_inv', true};
% client.HoldQuery = {'Study', 'LEAP', 'faceerp_avged', true,...
%     'peakrating_total_not_clear', @(x) x > 0};
client.ConnectToServer(server_address, 3000)

% define variable name of ERP averages in the database
erpVarName = 'faceerp_avg30';

% define a temp folder (in case of lost connection to database)
path_temp = '/Users/luke/Desktop/pftemp';

% instantiate the peak finder
pf = tePeakFinder(def, erpVarName, client, path_temp);

