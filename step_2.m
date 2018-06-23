%Apply normalized 8-point RANSAC algorithm to find best matches.

clear all;
load Features_hasher.mat;

for i = 1 % 2:(sizeFeaures,1)
    
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
        A = [];
        %todo remove s
        for ai = 1:P
            x1 = n_xy.A(ai,1);
            y1 = n_xy.A(ai,2);
            x2 = n_xy.B(ai,1);
            y2 = n_xy.B(ai,2);
            newA = [x1*x2 x1*y2 x1 y1*x2 y1*y2 y1 x2 y2 1];
            A = [A; newA]; %add to array A
        end
        clear n_xy x1 x2 y1 y2 newA;
        
        %calculate F matrix
        [~,~,Vt] = svd(A);
        f = reshape(Vt(:,end),3,3);
        [U,D,V] = svd(f);
        D(end,end) = 0;
        F = U*D*V';
        %denormalize
        F = T.B'*F*T.A;
        clear U D V f Vt T A;
        
        %check how much inliers there are
        num_matches = size(matches,2);
        Points.A = [Feat.A(:,matches(1,:));ones(1,num_matches)];
        Points.B = [Feat.B(:,matches(2,:));ones(1,num_matches)];                
        %p1 = [Features{1,1}(1,matches(1,:)); Features{1,1}(2,matches(1,:)); ones(1,size(matches,2))];
        %p2 = [Features{i,1}(1,matches(1,:)); Features{i,1}(2,matches(1,:)); ones(1,size(matches,2))];
        Distance = [];
        for point = 1:num_matches
            d.top = (Points.B(:,point)'*F*Points.A(:,point)).^2;
            d.bt1 = F*Points.A(:,point);
            d.bt2 = F'*Points.B(:,point);
            d.bottom = (d.bt1(1)^2)+(d.bt1(2)^2)+(d.bt2(1)^2)+(d.bt2(2)^2);
            Distance(point) = d.top/d.bottom;
            clear d;
        end
        
        threshold = 10;
        Ransac_d_value(ri) = sum(Distance(:)<threshold);
        Ransac_F{ri} = F;
    end  
    %give some insight
    max(Ransac_d_value)
    sum(Ransac_d_value>100)
    clear matches;
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