function p = predictDictionaryLearning(C, D, param)
% PREDICTDICTIONARYLEARNING For a given test covariance matrix, predict the 
% corresponding class based on the minimum residual error.

residual = zeros(size(D, 2) / param.K, 1);
num_classes = size(D, 2) / param.K;

for i=1:num_classes
    start_range = (i - 1) * param.K + 1;
    end_range = i * param.K;
    alpha = mexLasso(C, D(:,start_range:end_range), param);
    residual(i) = mean(0.5 * sum((C - D(:,start_range:end_range) * alpha).^2) + ...
                  param.lambda * sum(abs(alpha)));
end

[~, p] = min(residual);

end
