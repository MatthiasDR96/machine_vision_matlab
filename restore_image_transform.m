% Init
clc
clear

% Read image
im = imread('data/photographer.jpg');

% Show original image
imshow(im);

% Scale the image
scale = 0.7;
im_scaled = imresize(im, scale); 

% Rotate the image
theta = 30;
im_distorted = imrotate(im_scaled, theta);

% Projective transform
%theta = 10;
%tm = [cosd(theta) -sind(theta) 0.001; ...
    %sind(theta) cosd(theta) 0.01; ...
    %0 0 1];
%tform = projective2d(tm);

% Show distortion
figure(1);
montage({im, im_distorted})

% Detect SURF features
ptsOriginal  = detectSURFFeatures(im);
ptsDistorted = detectSURFFeatures(im_distorted);

% Detect FAST features
%ptsOriginal = detectFASTFeatures(im);
%ptsDistorted = detectFASTFeatures(im_distorted);

% Detect Harris features
%ptsOriginal = detectHarrisFeatures(im);
%ptsDistorted = detectHarrisFeatures(im_distorted);


% Extract feature descriptors
[featuresOriginal,  validPtsOriginal]  = extractFeatures(im,  ptsOriginal)
[featuresDistorted, validPtsDistorted] = extractFeatures(im_distorted, ptsDistorted);

% Show features
figure(2);
imshow(im);
hold on;
plot(validPtsOriginal.selectStrongest(20),'showOrientation',true);

figure(3);
imshow(im_distorted);
hold on;
plot(validPtsDistorted.selectStrongest(20),'showOrientation',true);

% Match featuresd
indexPairs = matchFeatures(featuresOriginal, featuresDistorted);
matchedOriginal  = validPtsOriginal(indexPairs(:,1));
matchedDistorted = validPtsDistorted(indexPairs(:,2));

% Show matches
figure(4);
showMatchedFeatures(im,im_distorted,matchedOriginal,matchedDistorted, 'montage');
title('Putatively matched points (including outliers)');

% Estimate transformation with MSAC
[tform, inlierIdx] = estimateGeometricTransform2D(matchedDistorted, matchedOriginal, 'similarity');
tform.T
inlierDistorted = matchedDistorted(inlierIdx, :);
inlierOriginal  = matchedOriginal(inlierIdx, :);

% Plot restored figure
figure(5);
showMatchedFeatures(im, im_distorted, inlierOriginal, inlierDistorted, 'montage');
title('Matching points');

% Get inverse transform
Tinv  = tform.invert.T;
ss = Tinv(2,1);
sc = Tinv(1,1);
scaleRecovered = sqrt(ss*ss + sc*sc)
thetaRecovered = atan2(ss,sc)*180/pi

% Recover original image
outputView = imref2d(size(im)); % For size and location of output image
recovered  = imwarp(im_distorted, tform, 'OutputView', outputView);

% Show restored image
figure(6);
imshowpair(im,recovered,'montage');




