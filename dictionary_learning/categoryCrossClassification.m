function categoryCrossClassification(shape_train_paths, vision_train_paths, ...
                                     shape_test_paths, vision_test_paths, ...
                                     num_shape_atoms, num_vision_atoms)
% CATEGORYCROSSCLASSIFICATION Dictionary learning on RGB-D covariance 
% descriptors using category classification as outlined in "A Large-Scale 
% Hierarchical Multi-View RGB-D Object Dataset" by Lai et al. 

verbose = 0;
log_output = 1;

if log_output
    fid = fopen('cross_category_classification.log', 'w');
end 

% Number of features used in the covariance matricies
num_shape_features = 9;    % x, y, z, r, g, b, nx, ny, nz, ...
num_vision_features = 15;  % x, y, z, r, g, b, nx, ny, nz, ...

% Obtain the training and test covariance data for each category 
shape_train_data = readCovariances(shape_train_paths, num_shape_features);
vision_train_data = readCovariances(vision_train_paths, num_vision_features);
shape_test_data = readCovariances(shape_test_paths, num_shape_features);
vision_test_data = readCovariances(vision_test_paths, num_vision_features);

% Dictionary learning parameters 
shape_param.K = num_shape_atoms;
shape_param.lambda = 0.15;
shape_param.numThreads = -1;
shape_param.batchsize = 400;
shape_param.verbose = false;
shape_param.iter = 1000; 

vision_param.K = num_vision_atoms;
vision_param.lambda = 0.15;
vision_param.numThreads = -1;
vision_param.batchsize = 400;
vision_param.verbose = false;
vision_param.iter = 1000; 

% Build shape and vision dictionaries using the training data
fprintf('Building shape dictionary ... ');
t_start = tic;
shape_D = trainDictionaryLearning(shape_train_data, shape_param);
t_end = toc(t_start);
fprintf('done\n');
fprintf('Shape dictionary build time: %d mins and %.2f secs\n', ...
    floor(t_end / 60), rem(t_end, 60)); 

fprintf('Building vision dictionary ... ');
t_start = tic;
vision_D = trainDictionaryLearning(vision_train_data, vision_param);
t_end = toc(t_start);
fprintf('done\n');
fprintf('Vision dictionary build time: %d mins and %.2f secs\n', ...
    floor(t_end / 60), rem(t_end, 60)); 

fprintf('Number of dictionary classes: %d\n', size(shape_train_data, 2));
if log_output
    fprintf(fid, 'Number of dictionay classes: %d\n', size(shape_train_data, 2));
end

% Compute the error on the test data
error_count = 0;
t_start = tic;
for i=1:size(shape_test_data, 2)
    shape_votes = zeros(size(shape_train_data, 2), 1);
    vision_votes = zeros(size(vision_train_data, 2), 1);
    num_shape_covs = size(shape_test_data(i).covariances, 2);
    num_vision_covs = size(vision_test_data(i).covariances, 2);
    for j=1:num_shape_covs
        C = cell2mat(shape_test_data(i).covariances(j));
        p = predictDictionaryLearning(C, shape_D, shape_param);
        shape_votes(p) = shape_votes(p) + 1;
    end
    for j=1:num_vision_covs
        C = cell2mat(vision_test_data(i).covariances(j));
        p = predictDictionaryLearning(C, vision_D, vision_param);
        vision_votes(p) = vision_votes(p) + 1;
    end
    [~, shape_v] = max(shape_votes);
    [~, vision_v] = max(vision_votes);
    if shape_votes(shape_v) > vision_votes(vision_v)
        if strcmpi(shape_test_data(i).category, shape_train_data(shape_v).category) ~= 1
            error_count = error_count + 1;
        end
        fprintf('Category %d "%s" voted as "%s", shape votes (%d), vision votes (%d)\n', ...
                i, shape_test_data(i).category, shape_train_data(shape_v).category, shape_votes(shape_v), vision_votes(vision_v));
        if log_output
            fprintf(fid, '%dth category "%s" voted category: %s\n', i, shape_test_data(i).category, shape_train_data(shape_v).category);
            fprintf(fid, 'Error rate: %.4f\n', error_count / i);
        end
    else
        if strcmpi(vision_test_data(i).category, vision_train_data(vision_v).category) ~= 1
            error_count = error_count + 1;
        end
        fprintf('Category %d "%s" voted as "%s", shape votes (%d), vision votes (%d)\n', ...
                i, vision_test_data(i).category, vision_train_data(vision_v).category, shape_votes(shape_v), vision_votes(vision_v));
        if log_output
            fprintf(fid, '%dth category "%s" voted category: %s\n', i, vision_test_data(i).category, vision_train_data(vision_v).category);
            fprintf(fid, 'Error rate: %.4f\n', error_count / i);
        end
    end
    fprintf('Error rate: %.4f\n', error_count / i);
end
t_end = toc(t_start);

fprintf('Category test time: %d mins and %.2f secs\n', floor(t_end / 60), rem(t_end, 60));
fprintf('Error count: %d\n', error_count);
fprintf('Mean test error rate: %.4f\n', error_count / size(shape_test_data, 2));
if log_output
    fprintf(fid, 'Category test time: %d mins and %.2f secs\n', floor(t_end / 60), rem(t_end, 60));
    fprintf(fid, 'Error count: %d\n', error_count);
    fprintf(fid, 'Mean test error rate: %.4f\n', error_count / size(shape_test_data, 2));
    fclose(fid);
end

end
