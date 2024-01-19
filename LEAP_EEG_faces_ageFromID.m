function age = LEAP_EEG_faces_ageFromID(id)

    % hard-coded path for now
    file_ccv = '/Volumes/Projects/LEAP/EEG/faces/N170 analysis/CE LEAP_Core clinical variables_02012019.xlsx';
    if ~exist(file_ccv, 'file')
        error('Cannot find core clinical variables file:\n\t%s', file_ccv)
    end
    ccv = readtable(file_ccv);
    
    strSub = arrayfun(@num2str, ccv.subjects, 'uniform', false);
    idx = find(strcmpi(id, strSub), 1);
    ccv = ccv(idx, :);
    age = ccv.age_years;

end