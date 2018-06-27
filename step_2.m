%Apply normalized 8-point RANSAC algorithm to find best matches.

clear all;
load Features_hasher.mat;

All_matches = [];   %global matches
All_F = {};         %all fundamental matrices

for i = 1:18
    
    Feat.A = [Features.har(i).x Features.hes(i).x;
              Features.har(i).y Features.hes(i).y];
    Feat.B = [Features.har(i+1).x Features.hes(i+1).y;
              Features.har(i+1).y Features.hes(i+1).y];
          
    Desc.A = [Features.har(i).desc Features.hes(i).desc];
    Desc.B = [Features.har(i+1).desc Features.hes(i+1).desc];
    
    %remove duplicates (possible not needed any longer)
    [Desc.A,ia.A,ic.A] = unique(Desc.A','stable','rows');
    [Desc.B,ia.B,ic.B] = unique(Desc.B','stable','rows');
    Feat.A = Feat.A(:,ia.A); %remove coords from features
    Feat.B = Feat.B(:,ia.B);
    clear ia ib;
    Desc.A = Desc.A';
    Desc.B = Desc.B';
  
    %TODO threshold scores
    [matches,scores] = vl_ubcmatch(Desc.A,Desc.B);
    clear Desc;
    
    % N RANSAC ATTEMPTS
    N = 200; %RANSAC attempts
    for ri = 1:N
        P = 8;
        %random index number of matches
        seed = randperm(size(matches,2),P);
        
        %get all coords for the 8randomly chosen matches
        xy.A = [];
        xy.B = [];
        for s = seed(1:P)
            xy.A = [xy.A; Feat.A(1,s) Feat.A(2,s)];
            xy.B = [xy.B; Feat.B(1,s) Feat.B(2,s)];
        end
        
        %normalize coordinates
        [T.A,n_xy.A] = normalizecoords(xy.A);
        [T.B,n_xy.B] = normalizecoords(xy.B);
        clear xy seed;
    
        %start with empty A array
        A = horzcat(n_xy.A(:,1).*n_xy.B(:,1),n_xy.A(:,1).*n_xy.B(:,2),n_xy.A(:,1),n_xy.A(:,2).*n_xy.B(:,1),n_xy.A(:,2).*n_xy.B(:,2),n_xy.A(:,2),n_xy.B(:,1), n_xy.B(:,2),ones(size(n_xy.A,1),1));
        
        %calculate F matrix
        [~,~,Vt] = svd(A);
        f = reshape(Vt(:,end),3,3);
        [U,D,V] = svd(f);
        %singularity forcing??
        D(end,end) = 0;
        F = U*D*V';
        %denormalize
        F = T.B'*F*T.A;
        clear U D V f Vt T A;
        
        %check how much inliers there are
        num_matches = size(matches,2);
        Points.A = [Feat.A(:,matches(1,:));ones(1,num_matches)]; %xy image a
        Points.B = [Feat.B(:,matches(2,:));ones(1,num_matches)]; %xy image b    
        Distance = [];
        for point = 1:num_matches
            d.top = (Points.B(:,point)'*F*Points.A(:,point)).^2;
            d.bt1 = F*Points.A(:,point);
            d.bt2 = F'*Points.B(:,point);
            d.bottom = (d.bt1(1)^2)+(d.bt1(2)^2)+(d.bt2(1)^2)+(d.bt2(2)^2);
            Distance(point) = d.top/d.bottom;
            clear d;
        end
        %optimize max handeling
        threshold = 10;
        if 
        Ransac_d = sum(Distance(:)<threshold);
        
        %only use the inliers.
        Ransac__inliers{ri} = matches(:,find(Distance<threshold));
        Ransac_F{ri} = F;
        clear F

    end  
    
    %store the best F
    All_F{i} = Ransac_F{find(Ransac_d_value == max(Ransac_d_value))};
    All_matches = [All_matches; zeros(1,size(All_matches,2))];
    newpoints = Ransac_inliers{find(Ransac_d_value == max(Ransac_d_value))};
    if i == 1
            All_matches = [newpoints];
    else
            All_matches = [All_matches[ zeros(1,size(newpoints,2)); newpoints]];
    end
        
    %give some insight
    %max(Ransac_d_value)
    %sum(Ransac_d_value>100)
    clear Ransac_F  Ransac_d_value Ransac_d_points_inliers matches newpoints;
end

function [T,coord_out] = normalizecoords(coordsin)
n = size(coordsin,1);
%get normalized coords
mx = (1/n)*sum(coordsin(:,1));
my = (1/n)*sum(coordsin(:,2));
d = (1/n)*sum(sqrt(((coordsin(:,1)-mx).^2)+(coordsin(:,2)-my).^2));
T = [sqrt(2)/d 0 -mx*sqrt(2)/d;
    0 sqrt(2)/d -my*sqrt(2)/d;
    0 0 1];
p = T*([coordsin ones(n,1)]');
coord_out = p(1:2,:)';
end