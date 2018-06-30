clear all;

%image names
imagedir = 'modelCastlePNG/modelCastlePNG';
image_files = dir(strcat(imagedir,'/*.png'));
%imread([imagedir '/' image_files(i).name])

disp('--- Loading features ---')
load Features_hasher.mat;

disp('--- calculating matches ---')
%TODO match 19 to 1
threshold = 10;

% for i = 1:19
%     
%     if i== 19
%         j=1;
%     else
%         j=i+1;
%     end
%     
%     %display
%     fprintf("Matching between image %d and %d \n", i, j)
%     
%     Feat{i}.A = [  Features.har(i).x Features.hes(i).x;
%                    Features.har(i).y Features.hes(i).y];
%     Feat{i}.B = [  Features.har(j).x Features.hes(j).x;
%                    Features.har(j).y Features.hes(j).y];
%     
%     Desc.A = [  Features.har(i).desc Features.hes(i).desc];
%     Desc.B = [  Features.har(j).desc Features.hes(j).desc];
%     
%     %remove duplicates (possible not needed any longer)
%     [Desc.A,ia.A,ic.A] = unique(Desc.A','stable','rows');
%     [Desc.B,ia.B,ic.B] = unique(Desc.B','stable','rows');
%     Feat{i}.A = Feat{i}.A(:,ia.A); %remove coords from features
%     Feat{i}.B = Feat{i}.B(:,ia.B);
%     clear ia ib ic;
%     Desc.A = Desc.A';
%    Desc.B = Desc.B';
%     
%     %find matches (can lower threshold if more points are needed)
%     [matches{i},~] = vl_ubcmatch(Desc.A,Desc.B);
%     %[matches,scores] = vl_ubcmatch(Desc.A,Desc.B);
%     clear Desc;
%     
%     fprintf("matches found: %d \n", size(matches{i},2))
%     
%     %Apply normalized 8-point RANSAC algorithm to find best matches.
%     [inliers{i},F{i}] = EightpointRansac(Feat{i}.A,Feat{i}.B,matches{i},threshold);
%end
clear i j;

load('Feat_set.mat')
%load('matches_set.mat')
load('inliers_set.mat')
%load('F_set.mat')

disp('--- make PVM ---')
PVM = Make_PVM(inliers);
%load('PVM_set.mat')

% imshow(imfuse((imread([imagedir '/' image_files(1).name])),(imread([imagedir '/' image_files(2).name])),'falsecolor'));
% hold on;
% plot(Feat{1,1}.A(1,inliers{1,1}(1,:)), Feat{1,1}.A(2,inliers{1,1}(1,:)), 'r.', 'LineWidth', 2, 'MarkerSize', 5);
% plot(Feat{1,1}.B(1,inliers{1,1}(2,:)), Feat{1,1}.B(2,inliers{1,1}(2,:)), 'g.', 'LineWidth', 2, 'MarkerSize', 5);

disp('--- make blocks ---')
rPVM3 = PVM(:,(3 == sum((PVM > 0),1))); %reduce PVM to colums with 3 or 4 active rows.
rPVM4 = PVM(:,(4 == sum((PVM > 0),1)));

for i = 1:17
    Block3{i} = rPVM3(i:i+2,        (sum(rPVM3(i:i+2    ,:)>0,1)==3));
end
    Block3{18} = rPVM3([18 19 1],   (sum(rPVM3([18 19 1],:)>0,1)==3));
    Block3{19} = rPVM3([19 1 2],    (sum(rPVM3([19 1 2] ,:)>0,1)==3));
    
for i = 1:16
    Block4{i}  = rPVM4(i:i+3,       (sum(rPVM4(i:i+3       ,:)>0,1)==4));
end
    Block4{17} = rPVM4([17 18 19 1],(sum(rPVM4([17 18 19 1],:)>0,1)==4));
    Block4{18} = rPVM4([18 19 1  2],(sum(rPVM4([18 19 1  2],:)>0,1)==4));
    Block4{19} = rPVM4([19 1  2  3],(sum(rPVM4([19 1  2  3],:)>0,1)==4));
    
clear rPVM3 rPVM4;

disp('--- Make SFM ---');
for i = 1:19
    [M{i},S{i}] = SFM(Block3{i})
    plot3(S{i}(1,:),S{i}(2,:),S{i}(3,:),'.r');
    pause();
end


disp('--- Stitching ---');
