function data = readCovariances(cov_paths, num_features)
% READCOVARIANCES Given a path list of covariance files, return a structure
% containing the name, category, and covariance matrices of each class.

fid = fopen(cov_paths);
cov_file = fgetl(fid);
i = 1;
while ischar(cov_file)
    ncovs = 0;
    D = dlmread(cov_file);
    [path, name, ~] = fileparts(cov_file);
    data(i).name = name;
    [~, category, ~] = fileparts(path);
    data(i).category = category;
    data(i).covariances = [];   
    j = 1;
    while j <= size(D, 1)
        C = {D(j:(j + num_features - 1), 1:end)};
        data(i).covariances = [data(i).covariances C];
        j = j + num_features;
        ncovs = ncovs + 1;
    end
    i = i + 1;
    cov_file = fgetl(fid);
end

fclose(fid);

end

function category = extractCategory(class)
    v = strsplit(class, '_');
    split_str = regexp(class, '_\d', 'split');
    category = split_str(1);
end
