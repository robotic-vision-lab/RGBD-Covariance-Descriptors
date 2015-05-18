function crossValidation(cov_paths, num_atoms)
% CROSSVALIDATION Dictionary learning on RGB-D covariance descriptors using 
% k-fold cross-validation.

verbose = 0;
log_output = 1;

if log_output
    [~, name, ~] = fileparts(cov_paths);
    log_file = [name '.log'];
    fid = fopen(log_file, 'w');
end

% K-fold cross-validation parameter
num_crossval = 10;

% Number of features used in the covariance matrix
num_features = 9;  % x, y, z, r, g, b, nx, ny, nz

% Obtain the covariance data for each object 
data = readCovariances(cov_paths, num_features);

% Randomly permute a set of indices to the class data
for i=1:size(data, 2)
    data(i).idx = randperm(size(data(i).covariances, 2));
end

% Dictionary learning parameters 
param.K = num_atoms;
param.lambda = 0.15;
param.numThreads = -1;
param.batchsize = 400;
param.verbose = false;
param.iter = 1000; 

fprintf('Building dictionary ... ');
t_start = tic;
D = trainDictionaryLearning(data, param);
t_end = toc(t_start);
fprintf('done\n');
fprintf('Dictionary build time: %d mins and %.2f secs\n', ...
        floor(t_end / 60), rem(t_end, 60));

fprintf('Number of classes: %d\n', size(data, 2));
if log_output
    fprintf(fid, 'Number of classes: %d\n', size(data, 2));
end

% Compute the training error
param.numThreads = 1;
num_covs = 0;
error_count = 0;
t_start = tic;
parfor i=1:size(data, 2)
    num_covs = num_covs + size(data(i).covariances, 2);
    t_start2 = tic;
    for j=1:size(data(i).covariances, 2)
        C = cell2mat(data(i).covariances(j));
        p = predictDictionaryLearning(C, D, param);
        if p ~= i
            error_count = error_count + 1;
            if verbose
                fprintf('Class "%s" mislabeled as "%s"\n', data(i).name, data(p).name);
            end 
        end
    end
end
t_end = toc(t_start);
fprintf('Train error time: %d mins and %.2f secs\n', ...
        floor(t_end / 60), rem(t_end, 60));

train_error = error_count / num_covs;                                                                             
fprintf('Mean train error rate: %.4f\n', train_error);
if log_output
    fprintf(fid, 'Mean train error rate: %.4f\n', train_error);
end

% Compute the test error
test_error = zeros(size(data, 2), 1);
t_start = tic;
parfor i=1:size(data, 2)
    num_covs = size(data(i).covariances, 2);

    % Compute the k-fold size based on the number of cross-validations
    fold_size = round(num_covs / num_crossval);

    class_error = zeros(num_crossval, 1);
    for j=1:num_crossval
        start_fold = (j-1) * fold_size + 1;
        end_fold = start_fold + fold_size - 1;
        if end_fold > num_covs 
            end_fold =  num_covs;
        end

        % Initialize the test and training indices
        test_idx = data(i).idx(start_fold:end_fold);
        train_idx = [data(i).idx(1:start_fold-1) data(i).idx(end_fold+1:num_covs)];

        % Build a dictionary minus the test covariance matrices of the current class
        D = [];
        fprintf('Building dictionary ... ');
        for k=1:size(data, 2)
            C = [];
            if k == i
                for l=1:size(train_idx, 2)
                    C = [C cell2mat(data(k).covariances(train_idx(l)))]; 
                end
            else
                for l=1:size(data(k).covariances, 2)
                    C = [C cell2mat(data(k).covariances(l))]; 
                end
            end
            D = [D mexTrainDL(C, param)];
        end
        % Compute the error on the test data
        error_count = 0;
        for k=1:size(test_idx, 2)
            C = cell2mat(data(i).covariances(test_idx(k)));
            p = predictDictionaryLearning(C, D, param);
            if p ~= i
                error_count = error_count + 1;
                if verbose
                    fprintf('Class "%s" mislabeled as "%s"\n', data(i).name, data(p).name);
                end
            end
        end
        class_error(j) = error_count / size(test_idx, 2);
    end
    fprintf('Class "%s" mean test error rate: %.4f\n', data(i).name, mean(class_error));
    if log_output
        fprintf(fid, 'Class "%s" mean test error rate: %.4f\n', data(i).name, mean(class_error));
    end
    test_error(i) = mean(class_error);
end
t_end = toc(t_start);
fprintf('Test error time: %d mins and %.2f secs\n', ...
        floor(t_end / 60), rem(t_end, 60));
        
fprintf('Mean test error rate: %.4f\n', mean(test_error));
fprintf('Standard deviation: %.4f\n', std(test_error));

if log_output
    fprintf(fid, 'Mean test error rate: %.4f\n', mean(test_error));
    fprintf(fid, 'Standard deviation: %.4f\n', std(test_error));
    fclose(fid);
end
end
