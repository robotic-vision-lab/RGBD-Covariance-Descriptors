function [x y z r g b nx ny nz c1 c2 K I Ix Iy Ixx Iyy Ixy Imag Dx Dy Dmag] ...
          = computeFeatures(pcd_data, rgb_data, depth_data) 
% COMPUTEFEATURES Construct the feature vectors corresponding to the given input 
% parameters. 

min_pts = 32;

% Initialization
x = []; y = []; z = []; 
r = []; g = []; b = []; 
nx = []; ny = []; nz = []; 
c1 = []; c2 = []; K = []; 
Ix = []; Iy = []; Ixx = []; 
Iyy = []; Ixy = []; Imag = [];
I = []; Dx = []; Dy = []; Dmag = [];

% Position and color
fprintf('Extracting positions and colors ... ');
if size(pcd_data, 3) > 1  % Organized point cloud 
    [m,n] = size(pcd_data(:,:,1));
    k = 1;
    for i=1:m
        for j=1:n
            if ~isnan(pcd_data(i,j,1))
                x(k) = pcd_data(i,j,1);
                y(k) = pcd_data(i,j,2);
                z(k) = pcd_data(i,j,3);
                r(k) = pcd_data(i,j,4);
                g(k) = pcd_data(i,j,5);
                b(k) = pcd_data(i,j,6);
                k = k + 1;
            end
        end
    end
else  % Unorganized point cloud 
    for i=1:size(pcd_data, 2)
        x(i) = pcd_data(1,i);
        y(i) = pcd_data(2,i);
        z(i) = pcd_data(3,i);
        r(i) = pcd_data(4,i);
        g(i) = pcd_data(5,i);
        b(i) = pcd_data(6,i);
    end
end
fprintf('done\n');

% Make sure the object has a minimum number of points
if size(x, 2) < min_pts
    return
end

% Image intensity, gradient, and magnitude of the gradient
fprintf('Computing image features ... ');
img = imread(rgb_data);
H = fspecial('gaussian', [5 5], 3);                                                                                        
img = imfilter(img, H, 'replicate'); 
gray_img = rgb2gray(img);

[Ix, Iy] = imgradientxy(gray_img, 'sobel');
[Ixx, Ixy] = imgradientxy(Ix, 'sobel');
[~, Iyy] = imgradientxy(Iy, 'sobel');
Imag = sqrt(Ix.^2 + Iy.^2);
Ix = rescale(Ix);
Iy = rescale(Iy);
Ixx = rescale(Ixx);
Iyy = rescale(Iyy);
Ixy = rescale(Ixy);
Imag = rescale(Imag);

I = reshape(gray_img.', 1, []);
Ix = reshape(Ix.', 1, []);
Iy = reshape(Iy.', 1, []);
Ixx = reshape(Ixx.', 1, []);
Iyy = reshape(Iyy.', 1, []);
Ixy = reshape(Ixy.', 1, []);
Imag = reshape(Imag.', 1, []);
fprintf('done\n');

% Depth image gradient and magnitude of the gradient
fprintf('Computing depth features ... ');
img = imread(depth_data);
H = fspecial('gaussian', [5 5], 3);                                                                                        
img = imfilter(img, H, 'replicate'); 

[Dx, Dy] = imgradientxy(img, 'sobel');
Dmag = sqrt(Dx.^2 + Dy.^2);
Dx = rescale(Dx);
Dy = rescale(Dy);
Dmag = rescale(Dmag);
Dx = reshape(Dx.', 1, []);
Dy = reshape(Dy.', 1, []);
Dmag = reshape(Dmag.', 1, []);
fprintf('done\n');

% Normals
fprintf('Computing normals ... ');
data = [x' y' z'];
tree = KDTreeSearcher(data);                                                                    
radius = 0.01;
min_neighbors = 32;
parfor i=1:size(x, 2)
    query = [x(i) y(i) z(i)];
    n = estimateNormal(data, tree, query, radius, min_neighbors);
    if size(n, 1) == 1
        nx(i) = 0;
        ny(i) = 0;
        nz(i) = 0;
        continue;
    end
    nx(i) = n(1);
    ny(i) = n(2);
    nz(i) = n(3);
end
fprintf('done\n');

% Curvature 
fprintf('Computing curvatures ... ');
normals = [nx' ny' nz'];
parfor i=1:size(x, 2)
    query = [x(i) y(i) z(i)];
    [pc1, pc2] = estimateCurvatures(normals, tree, query, radius);
    c1(i) = pc1;
    c2(i) = pc2;
    K(i) = pc1*pc2; % Gaussian curvature
end
fprintf('done\n');

end

function A = rescale(A)
    scale = 1.0 / (max(max(A)) - (min(min(A))));
    delta = -min(min(A)) / (max(max(A)) - (min(min(A))));
    A = A .* scale; 
    A = A + delta;
end
