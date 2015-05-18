function normal = estimateNormal(data, tree, query, radius, min_neighbors)
% ESTIMATENORMAL Given a point cloud and query point, estimate the surface 
% normal by performing an eigendecomposition of the covariance matrix created 
% from the nearest neighbors of the query point for a fixed radius.
%
%  Example: 
%       data = randn(256,3);
%       tree = KDTreeSearcher(data);
%       query = [data(1,1) data(1,2) data(1,3)];
%       radius = 1.0;
%       min_neighbors = 8;
%       normal = estimateNormal(data, tree, query, radius, min_neighbors)
%
%  Copyright (c) 2014, William J. Beksi <beksi@cs.umn.edu>
% 

% Find neighbors within the fixed radius 
idx = rangesearch(tree, query, radius);                                                   
idxs = idx{1};
neighbors = [data(idxs(:),1) data(idxs(:),2) data(idxs(:),3)];

if size(neighbors) < min_neighbors
    normal = {1};
    return;
end

% Compute the covariance matrix C
C = cov(neighbors);

% Compute the eigenvector of C
[v, lambda] = eig(C);

% Find the eigenvector corresponding to the minimum eigenvalue in C
[~, i] = min(diag(lambda));

% Normalize
normal = v(:,i) ./ norm(v(:,i));

end 
