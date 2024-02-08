% Load the stereoParameters object.
load('handshakeStereoParams.mat');

% Read frames
frameLeft = imread('./data/frame_left.jpg');
frameRight = imread('./data/frame_right.jpg');

% Show images
montage({frameLeft, frameRight})

% Rectify
[frameLeftRect, frameRightRect] = rectifyStereoImages(frameLeft, frameRight, stereoParams);

% Show images
imshow(stereoAnaglyph(frameLeftRect, frameRightRect));
title('Rectified Video Frames');

% Compute disparity
frameLeftGray  = rgb2gray(frameLeftRect);
frameRightGray = rgb2gray(frameRightRect);
disparityMap = disparitySGM(frameLeftGray, frameRightGray);
figure;
imshow(disparityMap, [0, 64]);
title('Disparity Map');
colormap jet
colorbar

% Reconstruct 3D scene
points3D = reconstructScene(disparityMap, stereoParams);

% Convert to meters and create a pointCloud object
points3D = points3D ./ 1000;
ptCloud = pointCloud(points3D, 'Color', frameLeftRect);

% Create a streaming point cloud viewer
player3D = pcplayer([-3, 3], [-3, 3], [0, 8], 'VerticalAxis', 'y', ...
    'VerticalAxisDir', 'down');

% Visualize the point cloud
view(player3D, ptCloud);