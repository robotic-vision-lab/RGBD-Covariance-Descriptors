function [C] = computeCovariance(x, y, z, r, g, b, nx, ny, nz, c1, c2, K, ...
                                 I, Ix, Iy, Ixx, Iyy, Ixy, Imag, Dx, Dy, Dmag)
% COMPUTECOVARIANCE Compute the covariance matrix for a given set of features 

% Initialization
feature_matrix = zeros(22, size(x, 2));

% Position
x_mean = mean(x);
x_max = max(abs(x));
feature_matrix(1,1:size(x, 2)) = (x - x_mean) ./ x_max; 

y_mean = mean(y);
y_max = max(abs(y));
feature_matrix(2,1:size(y, 2)) = (y - y_mean) ./ y_max; 

z_mean = mean(z);
z_max = max(abs(z));
feature_matrix(3,1:size(z, 2)) = (z - z_mean) ./ z_max; 

% Color
r_mean = mean(r);
feature_matrix(4,1:size(r, 2)) = (r - r_mean); 

g_mean = mean(g);
feature_matrix(5,1:size(g, 2)) = (g - g_mean); 

b_mean = mean(b);
feature_matrix(6,1:size(b, 2)) = (b - b_mean); 

% Image features 
Ix_mean = mean(Ix);
feature_matrix(7,1:size(Ix, 2)) = (Ix - Ix_mean); 

Iy_mean = mean(Iy);
feature_matrix(8,1:size(Iy, 2)) = (Iy - Iy_mean); 

Ixx_mean = mean(Ixx);
feature_matrix(9,1:size(Ixx, 2)) = (Ixx - Ixx_mean); 

Iyy_mean = mean(Iyy);
feature_matrix(10,1:size(Iyy, 2)) = (Iyy - Iyy_mean); 

Ixy_mean = mean(Ixy);
feature_matrix(11,1:size(Ixy, 2)) = (Ixy - Ixy_mean); 

Imag_mean = mean(Imag);
feature_matrix(12,1:size(Imag, 2)) = (Imag - Imag_mean); 

I_mean = mean(I);
feature_matrix(13,1:size(Ix, 2)) = (I - I_mean); 

%Depth features
Dx_mean = mean(Dx);
feature_matrix(14,1:size(Dx, 2)) = (Dx - Dx_mean); 

Dy_mean = mean(Dy);
feature_matrix(15,1:size(Dy, 2)) = (Dy - Dy_mean); 

Dmag_mean = mean(Dmag);
feature_matrix(16,1:size(Dmag, 2)) = (Dmag - Dmag_mean); 

% Normals
nx_mean = mean(nx);
feature_matrix(17,1:size(nx, 2)) = (nx - nx_mean); 

ny_mean = mean(ny);
feature_matrix(18,1:size(ny, 2)) = (ny - ny_mean); 

nz_mean = mean(nz);
feature_matrix(19,1:size(nz, 2)) = (nz - nz_mean); 

% Curvature 
c1_mean = mean(c1);
feature_matrix(20,1:size(c1, 2)) = (c1 - c1_mean); 

c2_mean = mean(c2);
feature_matrix(21,1:size(c2, 2)) = (c2 - c2_mean); 

K_mean = mean(K);
feature_matrix(22,1:size(K, 2)) = (K - K_mean); 

% Construct the covariance matrix
C = feature_matrix * feature_matrix' ./ (size(x, 2) - 1);
C = (C + C') ./ 2;
C = logm(C);

end 
