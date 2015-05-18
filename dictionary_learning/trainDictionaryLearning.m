function D = trainDictionaryLearning(data, param)
% TRAINDICTIONARYLEARNING For each class, compute a dictionary and return the 
% set of computed dictionaries.

D = [];
for i=1:size(data, 2)
    C = [];
    data(i).start_range = (i - 1) * param.K + 1;
    data(i).end_range = i * param.K;
    for j=1:size(data(i).covariances, 2)
        C = [C cell2mat(data(i).covariances(j))]; 
    end
    D = [D mexTrainDL(C, param)];
end

end
