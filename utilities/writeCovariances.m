function writeCovariances(in_file)
% WRITECOVARIANCES Given a file list of point cloud data files, read in each 
% file and compute the covariance matrix.  The covariance matrices are then 
% written to an ASCII-delimited file.

min_pts = 32;
fid = fopen(in_file);
tline = fgetl(fid);
while ischar(tline)
    covariance_matrices = [];
    dirs = dir(fullfile(tline));
    [~, class, ~] = fileparts(tline);
    parfor i=1:length(dirs)
        if strcmp(dirs(i).name, '.') == 1 || strcmp(dirs(i).name, '..')  == 1
            continue
        end
        pcd_obj = dir(fullfile([tline '/' dirs(i).name], '*.pcd'));
        pcd_data = loadpcd([tline '/' dirs(i).name '/' pcd_obj.name]);
        rgb_obj = dir(fullfile([tline '/' dirs(i).name], '*_crop.png'));
        rgb_data = [tline '/' dirs(i).name '/' rgb_obj.name];
        depth_obj = dir(fullfile([tline '/' dirs(i).name], '*_depthcrop.png'));
        depth_data = [tline '/' dirs(i).name '/' depth_obj.name];

        % Construct the feature vectors and covariance matrices
        [x, y, z, r, g, b, nx, ny, nz, c1, c2, K, I, Ix, Iy, Ixx, Iyy, Ixy, Imag ...
            Dx, Dy, Dmag] = computeFeatures(pcd_data, rgb_data, depth_data);
        if ~checkFeatures(x, y, z, r, g, b, nx, ny, nz, c1, c2, K, min_pts)
            continue;
        end
        C = computeCovariance(x, y, z, r, b, g, nx, ny, nz, c1, c2, K, ...
                              I, Ix, Iy, Ixx, Iyy, Ixy, Imag, Dx, Dy, Dmag);
        if isreal(C)
            covariance_matrices = [covariance_matrices; C];
        end
    end
    if size(covariance_matrices)
        dlmwrite([class '.cov'], covariance_matrices);
    end
    tline = fgetl(fid);
end
fclose(fid);

end

function val = checkFeatures(x, y, z, r, g, b, nx, ny, nz, c1, c2, K, min_pts)
    if size(x, 2)  < min_pts || ...
       size(y, 2)  < min_pts || ...
       size(z, 2)  < min_pts || ...
       size(r, 2)  < min_pts || ...
       size(g, 2)  < min_pts || ...
       size(b, 2)  < min_pts || ... 
       size(nx, 1) == 0 || ...
       size(ny, 1) == 0 || ...
       size(nz, 1) == 0 || ...
       size(c1, 1) == 0 || ...
       size(c2, 1) == 0 || ...
       size(K, 1)  == 0
        val = 0;
    else
        val = 1;
    end
end
