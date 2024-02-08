% Init
clc
clear

% Read image
boxImage = imread('data/box.jpg');
elephantImage = imread('data/elephant.jpg');
sceneImage = imread('data/scene.jpg');

% Show image
figure(1);
montage({boxImage, elephantImage, sceneImage});

% Detect features
boxPoints = detectSURFFeatures(boxImage);
elephantPoints = detectSURFFeatures(elephantImage);
scenePoints = detectSURFFeatures(sceneImage);

% Show features
figure(2);
subplot(1, 3, 1)
imshow(boxImage);
hold on;
plot(selectStrongest(boxPoints, 100));
subplot(1, 3, 2);
imshow(elephantImage);
hold on;
plot(selectStrongest(elephantPoints, 100));
subplot(1, 3, 3);
imshow(sceneImage);
hold on;
plot(selectStrongest(scenePoints, 100));

% Extract features
[boxFeatures, boxPoints] = extractFeatures(boxImage, boxPoints);
[elephantFeatures, elephantPoints] = extractFeatures(elephantImage, elephantPoints);
[sceneFeatures, scenePoints] = extractFeatures(sceneImage, scenePoints);

% Match features
boxPairs = matchFeatures(boxFeatures, sceneFeatures);
elephantPairs = matchFeatures(elephantFeatures, sceneFeatures, 'MaxRatio', 0.9);

% Retrieve matched points
matchedBoxPoints = boxPoints(boxPairs(:, 1), :);
matchedScenePointsBox = scenePoints(boxPairs(:, 2), :);
matchedElephantPoints = elephantPoints(elephantPairs(:, 1), :);
matchedScenePointsElephant = scenePoints(elephantPairs(:, 2), :);

% Estimate transform of box
[tformBox, inlierBoxPoints, inlierScenePointsBox] = estimateGeometricTransform(matchedBoxPoints, matchedScenePointsBox, 'affine');
tformBox.T

% Estimate transform of elephant
[tformElephant, inlierElephantPoints, inlierScenePointsElephant] = estimateGeometricTransform(matchedElephantPoints, matchedScenePointsElephant, 'affine');
tformElephant.T

% Plot matched points with outiers removed
figure(3);
subplot(2, 1, 1);
showMatchedFeatures(boxImage, sceneImage, inlierBoxPoints, inlierScenePointsBox, 'montage');
subplot(2, 1, 2);
showMatchedFeatures(elephantImage, sceneImage, inlierElephantPoints, inlierScenePointsElephant, 'montage');

% Define bounding box
boxPolygon = [1, 1;...                           % top-left
        size(boxImage, 2), 1;...                 % top-right
        size(boxImage, 2), size(boxImage, 1);... % bottom-right
        1, size(boxImage, 1);...                 % bottom-left
        1, 1];                   % top-left again to close the polygon
    
% Define bounding elephant
elephantPolygon = [1, 1;...                                 % top-left
        size(elephantImage, 2), 1;...                       % top-right
        size(elephantImage, 2), size(elephantImage, 1);...  % bottom-right
        1, size(elephantImage, 1);...                       % bottom-left
        1,1];                         % top-left again to close the polygon

% Transform bounding box
newBoxPolygon = transformPointsForward(tformBox, boxPolygon);
newElephantPolygon = transformPointsForward(tformElephant, elephantPolygon);

% Display detection
figure(4);
imshow(sceneImage);
hold on;
line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'y');
line(newElephantPolygon(:, 1), newElephantPolygon(:, 2), 'Color', 'g');





