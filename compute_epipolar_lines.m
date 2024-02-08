% Init 
clc
clear

% Read images
I1 = imread('data\desk_left.png');
I2 = imread('data\desk_right.png');

% Show images
figure(1);
imshowpair(I1, I2, 'montage'); 

% Detect feature points
imagePoints1 = detectSURFFeatures(im2gray(I1));
imagePoints2 = detectSURFFeatures(im2gray(I2));

% Track the points
[featuresOriginal1,  validPtsOriginal1] = extractFeatures(im2gray(I1),  imagePoints1);
[featuresOriginal2,  validPtsOriginal2] = extractFeatures(im2gray(I2),  imagePoints2);

% Match features
indexPairs = matchFeatures(featuresOriginal1, featuresOriginal2);
matchedPoints1  = validPtsOriginal1(indexPairs(:,1)).Location;
matchedPoints2 = validPtsOriginal2(indexPairs(:,2)).Location;

% Visualize correspondences
figure(3)
showMatchedFeatures(I1, I2, matchedPoints1, matchedPoints2, 'montage','PlotOptions',{'ro','go','y--'});

% Compute Fundamental matrix
[fLMedS, inliers] = estimateFundamentalMatrix(matchedPoints1, matchedPoints2,'NumTrials',2000);
matchedPoints1 = matchedPoints1(inliers,:);
matchedPoints2 = matchedPoints2(inliers,:);

% Visualize correspondences
figure(4);
showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2,'montage','PlotOptions',{'ro','go','y--'});

% Plot image with features
figure(5); 
subplot(121);
imshow(I1); 
hold on;
plot(matchedPoints1(1,1),matchedPoints1(1,2),'go')

% Compute epilines for image 2
subplot(122); 
imshow(I2);
hold on;
plot(matchedPoints2(:,1),matchedPoints2(:,2),'go')
epiLines2 = epipolarLine(fLMedS, matchedPoints1);
points2 = lineToBorderPoints(epiLines2, size(I2));
line(points2(:,[1,3])',points2(:,[2,4])');

figure(6)
subplot(121);
imshow(I1); 
hold on;
plot(matchedPoints1(:,1),matchedPoints1(:,2),'go')
epiLines1 = epipolarLine(fLMedS', matchedPoints2);
points1 = lineToBorderPoints(epiLines1,size(I2));
line(points1(:,[1,3])',points1(:,[2,4])');
subplot(122); 
imshow(I2);
hold on;
plot(matchedPoints2(:,1),matchedPoints2(:,2),'go')

