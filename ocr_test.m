% Init
clc
clear

% Read image
A = imread('data/ocr_fig.png');

% To grayscale
Ags = im2gray(A);

% Adjust contrast
Aadj = imadjust(Ags);

% Automated and adaptive threshold
Abin = imbinarize(Aadj);
imshow(Abin)

% OCR
ocrResults = ocr(Abin);
recognizedText = ocrResults.Text
