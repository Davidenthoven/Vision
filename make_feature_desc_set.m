clear all;

% Feature point detection, and the extraction of SIFT descriptors.
directory = 'modelCastle_features/modelCastle_features';
files_har = dir(strcat(directory,'/*.png.haraff.sift'));
files_hes = dir(strcat(directory,'/*.png.hesaff.sift'));


Features = {};
for i = 1:length(files_har)
    haraff = strcat(directory,'/',files_har(i).name);
    File_har = dlmread(haraff,' ');
    har.x = File_har(3:end,1)';
    har.y = File_har(3:end,2)';
    har.abc = File_har(3:end,3:5)';
    har.desc = File_har(3:end,6:end)';
    
    hesaff = strcat(directory,'/',files_hes(i).name);
    File_hes = dlmread(hesaff,' ');
    hes.x = File_hes(3:end,1)';
    hes.y = File_hes(3:end,2)';
    hes.abc = File_hes(3:end,3:5)';
    hes.desc = File_hes(3:end,6:end)';
    
    Features.hes(i) = hes;
    Features.har(i) = har;
    clear har hes
end
