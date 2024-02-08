% Init
clc
clear

% Read images
I1 = imread('data\image1.jpg');
I2 = imread('data\image2.jpg');

% Show images
figure(1);
imshowpair(I1, I2, 'montage'); 

% Load precomputed camera parameters
load upToScaleReconstructionCameraParameters.mat

% Undistort
I1 = undistortImage(I1, cameraParams);
I2 = undistortImage(I2, cameraParams);

% Show undistort
figure (2)
imshowpair(I1, I2, 'montage');
title('Undistorted Images');

% Detect feature points
imagePoints1 = detectMinEigenFeatures(im2gray(I1), 'MinQuality', 0.1);
imagePoints2 = detectMinEigenFeatures(im2gray(I2), 'MinQuality', 0.1);

% Visualize detected points
figure(3)
imshow(I1, 'InitialMagnification', 50);
title('150 Strongest Corners from the First Image');
hold on
plot(selectStrongest(imagePoints1, 150));

% Track the points
[featuresOriginal1,  validPtsOriginal1]  = extractFeatures(im2gray(I1),  imagePoints1);
[featuresOriginal2,  validPtsOriginal2]  = extractFeatures(im2gray(I2),  imagePoints2);

% Match features
indexPairs = matchFeatures(featuresOriginal1, featuresOriginal2);
matchedPoints1  = validPtsOriginal1(indexPairs(:,1));
matchedPoints2 = validPtsOriginal2(indexPairs(:,2));

% Visualize correspondences
figure(4)
showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2);
title('Tracked Features');

% Estimate the fundamental matrix
[fMatrix, epipolarInliers] = estimateFundamentalMatrix(...
  matchedPoints1, matchedPoints2, 'Method', 'MSAC', 'NumTrials', 10000);

% Find epipolar inliers
inlierPoints1 = matchedPoints1(epipolarInliers, :);
inlierPoints2 = matchedPoints2(epipolarInliers, :);

% Display inlier matches
figure(5)
showMatchedFeatures(I1, I2, inlierPoints1, inlierPoints2);
title('Epipolar Inliers');

% Compute camera pose
[R, t] = cameraPose(fMatrix, cameraParams, inlierPoints1, inlierPoints2);

% Compute the camera matrices for each position of the camera
% The first camera is at the origin looking along the X-axis. Thus, its
% rotation matrix is identity, and its translation vector is 0.
camMatrix1 = cameraMatrix(cameraParams, eye(3), [0 0 0]);
camMatrix2 = cameraMatrix(cameraParams, R', -t*R');

% Detect feature points
imagePoints1 = detectMinEigenFeatures(im2gray(I1), 'MinQuality', 0.001);
imagePoints2 = detectMinEigenFeatures(im2gray(I2), 'MinQuality', 0.001);

% Track the points
[featuresOriginal1,  validPtsOriginal1]  = extractFeatures(im2gray(I1),  imagePoints1);
[featuresOriginal2,  validPtsOriginal2]  = extractFeatures(im2gray(I2),  imagePoints2);

% Match features
indexPairs = matchFeatures(featuresOriginal1, featuresOriginal2);
matchedPoints1  = validPtsOriginal1(indexPairs(:,1));
matchedPoints2 = validPtsOriginal2(indexPairs(:,2));

% Compute the 3-D points
points3D = triangulate(matchedPoints1, matchedPoints2, camMatrix1, camMatrix2);

% Get the color of each reconstructed point
%numPixels = size(I1, 1) * size(I1, 2);
%allColors = reshape(I1, [numPixels, 3]);
%colorIdx = sub2ind([size(I1, 1), size(I1, 2)], matchedPoints2, matchedPoints1);
%color = allColors(colorIdx, :);

% Create the point cloud
ptCloud = pointCloud(points3D);

% Visualize the camera locations and orientations
cameraSize = 0.3;
figure
plotCamera('Size', cameraSize, 'Color', 'r', 'Label', '1', 'Opacity', 0);
hold on
grid on
plotCamera('Location', t, 'Orientation', R, 'Size', cameraSize, ...
    'Color', 'b', 'Label', '2', 'Opacity', 0);

% Visualize the point cloud
pcshow(ptCloud, 'VerticalAxis', 'y', 'VerticalAxisDir', 'down', ...
    'MarkerSize', 45);

% Rotate and zoom the plot
camorbit(0, -30);
camzoom(1.5);

% Label the axes
xlabel('x-axis');
ylabel('y-axis');
zlabel('z-axis')

title('Up to Scale Reconstruction of the Scene');
