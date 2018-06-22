% IN4393-16 Computer Vision: Final Assignment
%
% David Enthoven & Randy Prozee

% Clear all old data
clc; 
clear; 
close all;

% run('~/Documents/TU/Year 2 (Master)/Q3/IN4393 - Computer Vision/LAB/vlfeat/vlfeat-0.9.21/toolbox/vl_setup')

%Load the image data
disp('Loading images...')

% Images
image_files = dir('modelCastlePNG/*.png');

for i = 1:length(image_files)
    
    current_image = imread([image_files(i).folder '/' image_files(i).name]);
    
    % Init array based on the image size
    if i == 1
        images_original = uint8(zeros([size(current_image) length(image_files)]));
    end
    
    images_original(:, :, :, i) = uint8(current_image);
    
end

% Convert images to greyscale
images_grey = uint8(mean(images_original, 3));

%(4 pts) Feature point detection, and the extraction of SIFT descriptors

%(4 pts) Apply normalized 8-point RANSAC algorithm to find best matches

%(8 pts) Chaining: Create point-view matrix to represent point correspondences for different camera views

%(12 pts) Stiching:

%(4 pts) Apply bundle adjustment

%(4 pts) Eliminate ane ambiguity

%(4 pts) 3D Model Plotting:


