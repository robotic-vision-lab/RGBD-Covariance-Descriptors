function [c1, c2] = estimateCurvatures(normals, tree, query, radius)
% ESTIMATECURVATURES Given a vector of normals from a point cloud and a query
% point, estimate the principal curvatures based on the minimum and maximum 
% eigenvalues of neighboring points within a fixed radius.
%
%  Example: 
%       data = randn(256,3);
%       tree = KDTreeSearcher(data);
%       radius = 1.0;
%       min_neighbors = 8;
%       for i=1:size(data, 1)
%           query = [data(i,1) data(i,2) data(i,3)];
%           normal = estimateNormal(data, tree, query, radius, min_neighbors);
%           if size(normal, 1) == 1
%               continue;
%           end
%           nx(i) = normal(1);
%           ny(i) = normal(2);
%           nz(i) = normal(3);
%       end
%       normals = [nx' ny' nz'];
%       for i=1:size(data, 1)
%           query = [data(i,1) data(i,2) data(i,3)];
%           [c1(i), c2(i)] = estimateCurvatures(normals, tree, query, radius);
%           k(i) = c1(i)*c2(i);  % Gaussian curvature
%       end
%
%  See also estimateNormal.
%
%  Copyright (c) 2014, William J. Beksi <beksi@cs.umn.edu>
%

% Find neighbors within the fixed radius
idx = rangesearch(tree, query, radius);
idxs = idx{1};
neighbors = [normals(idxs(:),1) normals(idxs(:),2) normals(idxs(:),3)];

% Compute the projection matrix
M = eye(3) - query'*query; 

% Project normals onto the tangent plane
projected_normals = (M*neighbors')';

% Compute the covariance matrix
C = cov(projected_normals);

% Compute the eigenvalues
[~, lambda] = eig(C);

% Estimate the principal curvatures based on the minimum and maximum eigenvalues
c1 = min(diag(lambda));
c2 = max(diag(lambda));

end
