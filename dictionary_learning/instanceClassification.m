function instanceClassification(train_paths, test_paths, num_atoms)
% INSTANCECLASSIFICATION Dictionary learning on RGB-D covariance descriptors
% using instance classification as outlined in "A Large-Scale Hierarchical 
% Multi-View RGB-D Object Dataset" by Lai et al. 

verbose = 0;
log_output = 1;

if log_output
    fid = fopen('instance_classification.log', 'w');
end 

% Number of features used in the covariance matrix
num_features = 15;  % x, y, z, r, g, b, nx, ny, nz, ...

% Obtain the training and test covariance data for each object 
train_data = readCovariances(train_paths, num_features);
test_data = readCovariances(test_paths, num_features);

% Dictionary learning parameters 
param.K = num_atoms;
param.lambda = 0.15;
param.numThreads = -1;
param.batchsize = 400;
param.verbose = false;
param.iter = 1000; 

fprintf('Building dictionary ... ');
t_start = tic;
D = trainDictionaryLearning(train_data, param);
t_end = toc(t_start);
fprintf('done\n');
fprintf('Dictionary build time: %d mins and %.2f secs\n', ...
    floor(t_end / 60), rem(t_end, 60)); 

fprintf('Number of dictionary classes: %d\n', size(train_data, 2));
if log_output
    fprintf(fid, 'Number of dictionary classes: %d\n', size(train_data, 2));
end

% Compute the error on the test data
param.numThreads = 1;
error_count = 0;
t_start = tic;
parfor i=1:size(test_data, 2)
    votes = zeros(size(train_data, 2), 1);
    num_covs = size(test_data(i).covariances, 2);
    for j=1:num_covs
        C = cell2mat(test_data(i).covariances(j));
        p = predictDictionaryLearning(C, D, param);
        votes(p) = votes(p) + 1;
    end
    [~, v] = max(votes);
    if strcmpi(test_data(i).name, train_data(v).name) ~= 1
        error_count = error_count + 1;
    end
    if verbose 
        fprintf('Class "%s" labeled as "%s"\n', test_data(i).name, test_data(v).name);
    end
end
t_end = toc(t_start);
fprintf('Test time: %d mins and %.2f secs\n', floor(t_end / 60), rem(t_end, 60)); 

fprintf('Mean test error rate: %.4f\n', error_count / size(test_data, 2));
if log_output
    fprintf(fid, 'Mean test error rate: %.4f\n', error_count / size(test_data, 2));
    fclose(fid);
end

end
