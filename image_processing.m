%% Read and interpret

% Import image
A = imread("data/receipt1.jpg");

% Show size
sz = size(A);
disp(['Image size: ', num2str(sz)]);

% Split channels
[R,G,B] = imsplit(A);

% Show channels
figure(1)
montage({R,G,B})

%% Adjust contrast

% To grayscale
Ags = im2gray(A);

% Show histogram
figure(2)
imhist(Ags)

% Adjust contrast
Aadj = imadjust(Ags);

% Show histogram
figure(3)
imhist(Aadj)

%% Blur

% Create averaging filter
F = fspecial("average",3);
disp(num2str(F));

% Apply filter
Afltr = imfilter(Aadj,F, 'replicate');

% Show image
figure(4)
montage({Ags,Aadj,Afltr})

%% Morphological operations

% Create structuring element
SE = strel("disk",8);

% Perform closing operation
Aclosed = imclose(Afltr, SE);

% Substract images
Asub = Aclosed - Afltr;

% Automated and adaptive threshold
Abin = ~imbinarize(Asub);

% Show image
figure(5)
montage({Aclosed, Asub, Abin})

% Create structuring element
SE = strel("rectangle",[3 25]);
    
% Perform opening operation
Aopened = imopen(Abin, SE);

% Show image
figure(6)
imshowpair(Abin, Aopened, 'montage')

%% Classification

% Get sum of rows
signal = sum(Aopened,2) ;

% Plot sum of rows
figure(7)
plot(signal', flip(0:1:606));

% Search local minima
minIndices = islocalmin(signal,"MinProminence",70,"ProminenceWindow",25);

% Calculate amount of minima
nMin = nnz(minIndices);

% Decide
isReceipt = nMin >= 9;