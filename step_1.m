clear all;

% Feature point detection, and the extraction of SIFT descriptors.
imagedir = 'modelCastlePNG/modelCastlePNG';
image_files = dir(strcat(imagedir,'/*.png'));

Features = {};
for i = 1:length(image_files)
    im =  im2single(rgb2gray(imread([imagedir '/' image_files(i).name])));   
    [frame, desc] = vl_sift(im);
    Features(i,:) = {frame,desc};
    clear frame;
    clear desc;
    clear im;
end

%we saved the features as featuresset.mat (a 19x2 cell array of variable
%cell sizes. Since the feature detection taks a some processing time from
%here on we use the saved featureset.