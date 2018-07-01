clear all;

%image names
imagedir = 'modelCastlePNG/modelCastlePNG';
image_files = dir(strcat(imagedir,'/*.png'));
%imread([imagedir '/' image_files(i).name])

disp('--- Loading features ---')
load Features_hasher.mat;

disp('--- calculating matches ---')
threshold = 15;

% for i = 1:19
%     j = mod(i,19)+1;
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
%     Desc.B = Desc.B';
% 
%     %find matches (can lower threshold if more points are needed)
%     %[matches{i},~] = vl_ubcmatch(Desc.A,Desc.B);
%     [matches{i},~] = vl_ubcmatch(Desc.A,Desc.B,1);
%     %[matches,scores] = vl_ubcmatch(Desc.A,Desc.B);
%     clear Desc;
% 
%     fprintf("matches found: %d \n", size(matches{i},2))
% 
%     %Apply normalized 8-point RANSAC algorithm to find best matches.
%     [inliers{i},F{i}] = EightpointRansac(Feat{i}.A,Feat{i}.B,matches{i},threshold);
% end
% clear i j;

load('Feat_set.mat')
%load('matches_set.mat')
load('inliers_set.mat')
%load('F_set.mat')

disp('--- make PVM ---')
PVM = Make_PVM(inliers);

% imshow(imfuse((imread([imagedir '/' image_files(1).name])),(imread([imagedir '/' image_files(2).name])),'falsecolor'));
% hold on;
% plot(Feat{1,1}.A(1,inliers{1,1}(1,:)), Feat{1,1}.A(2,inliers{1,1}(1,:)), 'r.', 'LineWidth', 2, 'MarkerSize', 5);
% plot(Feat{1,1}.B(1,inliers{1,1}(2,:)), Feat{1,1}.B(2,inliers{1,1}(2,:)), 'g.', 'LineWidth', 2, 'MarkerSize', 5);

disp('--- make blocks ---')
rPVM3 = PVM(:,(3 == sum((PVM > 0),1))); %reduce PVM to colums with 3 or 4 active rows.
rPVM4 = PVM(:,(4 == sum((PVM > 0),1)));

for i = 1:19
    j = mod(i,19)+1;
    k = mod(i+1,19)+1;
    l = mod(i+2,19)+1;
    Block3{i} = rPVM3([i j k],   (sum(rPVM3([i j k]  ,:)>0,1)==3));
    Block4{i} = rPVM4([i j k l], (sum(rPVM4([i j k l],:)>0,1)==4));
end
clear rPVM3 rPVM4 i j k l;

disp('--- Make SFM ---');
for i = 1:19
    h = mod(i+17,19)+1; % 1 back
    j = mod(i,19)+1;
    k = mod(i+1,19)+1;
    l = mod(i+2,19)+1;
    
   %get trippels from previous 4 block
    D4prev =[   Feat{i}.A(1:2,Block4{h}(2,:));
                Feat{j}.A(1:2,Block4{h}(3,:));
                Feat{k}.A(1:2,Block4{h}(4,:))];
             
    %all trippel coords
    D3 = [  Feat{i}.A(1:2,Block3{i}(1,:));
            Feat{j}.A(1:2,Block3{i}(2,:));
            Feat{k}.A(1:2,Block3{i}(3,:))];
    
    %get trippels from next 4 block 
    D4next = [Feat{i}.A(1:2,Block4{i}(1,:));
              Feat{j}.A(1:2,Block4{i}(2,:));
              Feat{k}.A(1:2,Block4{i}(3,:))];
          
    %store lengths for easy use later
    Dlenght(i).d    = (size(D3,2));
    Dlenght(i).prev = (size(D4prev,2));
    Dlenght(i).next = (size(D4next,2));
    
    D = [D4prev D3 D4next];

    if size(D,2)>2
        [~,S{i}] = SFM(D);
    end
end
clear i j k l D;

disp('--- Stitching ---');
finS = S{1};

for i = 1:19
    j = mod(i,19)+1;
    
    %map already known points on the known points
    start = Dlenght(i).prev + Dlenght(i).d +1;
    Q1 = S{i}(:,start:end);
    Q2 = S{j}(:,1:Dlenght(i).next);
    Q3 = S{j}(:,Dlenght(i).next+1:end);
    [d, Z, transform] = procrustes(Q1',Q2');
    d
    %apply same transform on the triplets. and the next quads
    Z = (transform.b*Q3'*transform.T+transform.c(1,:))';
    
    
    close all;
    plot3(finS(1,:),finS(2,:),finS(3,:),'.r');
    hold on
    plot3(Z(1,:),Z(2,:),Z(3,:),'.g');
    
    finS = [finS Z];
end