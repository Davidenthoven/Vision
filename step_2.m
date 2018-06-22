%Apply normalized 8-point RANSAC algorithm to find best matches.
%'modelCastlePNG/modelCastlePNG/8ADT8586.png'

clear all;
load featureset.mat; %creates Features cell array.
load matchedfeatures.mat
N = 200; %RANSAC attempts

for i = 2 % 2:(sizeFeaures,1)
    %index number fom matches
    %[matches] = vl_ubcmatch(Features{1,2},Features{i,2});
    
    % N RANSAC ATTEMPTS
    for ri = 1:N
        P = 8;
        %random index number of matches
        seed = randperm(size(matches,2),P);
        
        %get all coords for the 8randomly chosen matches
        coords1 = [];
        coords2 = [];
        for s = seed(1:P)
            coords1 = [coords1; Features{1,1}(1,matches(1,s)) Features{1,1}(2,matches(1,s))];
            coords2 = [coords2; Features{i,1}(1,matches(2,s)) Features{i,1}(2,matches(2,s))];
        end
        
        %normalize coordinates
        [T1,coords1n] = normalizecoords(coords1);
        [T2,coords2n] = normalizecoords(coords2);
        clear coords1;
        clear coords2;
        clear seed;
        
        %start with empty A array
        A = [];
        %todo remove s
        for ai = 1:P
            x1 = coords1n(ai,1);
            y1 = coords1n(ai,2);
            x2 = coords2n(ai,1);
            y2 = coords2n(ai,2);
            newA = [x1*x2 x1*y2 x1 y1*x2 y1*y2 y1 x2 y2 1];
            A = [A; newA]; %add to array A
        end
        clear coords1n coords2n
        
        %calculate F matrix
        [~,~,Vt] = svd(A);
        f = reshape(Vt(:,end),3,3);
        [U,D,V] = svd(f);
        D(end,end) = 0;
        F = U*D*V';
        %denormalize
        F = T2'*F*T1;
        clear U D V f Vt x1 x2 y1 y2 A newA T1 T2 seed;
        
        %check how much inliers there are
        p1 = [Features{1,1}(1,matches(1,:)); Features{1,1}(2,matches(1,:)); ones(1,size(matches,2))];
        p2 = [Features{i,1}(1,matches(1,:)); Features{i,1}(2,matches(1,:)); ones(1,size(matches,2))];
        d = [];
        for point = 1: size(matches,2)
            dtop = (p2(:,point)'*F*p1(:,point)).^2;
            bt1 = F*p1(:,point);
            bt2 = F'*p2(:,point);
            dbottom = (bt1(1)^2)+(bt1(2)^2)+(bt2(1)^2)+(bt2(2)^2);
            d(point) = dtop/dbottom;
            clear dtop dbottom bt1 bt2;
        end
        threshold = 15;
        Ransac_d_value(ri) = sum(d(:)<threshold);
        Ransac_F{ri} = F;        
    end  
    %give some insight
    max(Ransac_d_value)
    sum(Ransac_d_value>5)
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