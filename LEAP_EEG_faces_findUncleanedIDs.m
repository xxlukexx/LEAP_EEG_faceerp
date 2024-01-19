ac = teAnalysisClient;
ac.HoldQuery = {'Study', 'LEAP', 'faceerp_cleaned', false};
ac.ConnectToServer('193.61.45.196', 3000)
tab = ac.Table;
ids = tab.ID;
save('/Volumes/Projects/LEAP/EEG/faces/20181214/ids_to_be_cleaned.mat', 'ids');