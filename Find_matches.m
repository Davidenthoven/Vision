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

%the harris/Hessian implementation did not work for us. In later parts of
%the assignments we used the included hessian and harris sift features. A
%script called make_feature_desc_set (included in this project) read
%these files to a easy to use matlab structure.