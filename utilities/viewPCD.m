function viewPCD(in_file)
% VIEWPCD Load an organized point cloud data file and display the RGB image.

pcd_data = loadpcd(in_file);

% Display the RGB image
im = cat(3, pcd_data(:,:,4), pcd_data(:,:,5), pcd_data(:,:,6));
imshow(im) 

end
