function [inliers,F] = EightpointRansac(FeatA,FeatB,matches,threshold)

num_matches = size(matches,2);

Feat.Am = FeatA(:,matches(1,:));
Feat.Bm = FeatB(:,matches(2,:));

%normalize coordinates
[T.A,Feat.An] = normalizecoords(Feat.Am);
[T.B,Feat.Bn] = normalizecoords(Feat.Bm);

% N RANSAC ATTEMPTS
N = 1000;               %RANSAC attempts
best_num_inliers = 0;   %reset best number of inliers
Best_F = [];
Best_inliers = [];
for ri = 1:N
    threshold = 10;
    
    P = 8;
    %random index number of matches
    seed = randperm(num_matches,P);
    
    %get all coords for the 8randomly chosen matches
    xy.A = Feat.An(:,seed)';
    xy.B = Feat.Bn(:,seed)';
    clear seed;
    
    %start with empty A array
    A = horzcat(xy.A(:,1).*xy.B(:,1), xy.A(:,1).*xy.B(:,2), xy.A(:,1), xy.A(:,2).*xy.B(:,1),  xy.A(:,2).*xy.B(:,2), xy.A(:,2),xy.B(:,1), xy.B(:,2), ones(size(xy.A,1),1));
    clear xy;
    
    %calculate F matrix
    [~,~,Vt] = svd(A);
    F_hat = reshape(Vt(:,end),3,3);
    %singularity forcing??
    
    [U,D,V]     = svd(F_hat);
    D(end,end)  = 0;
    F_hat       = U*D*V';
    
    %denormalize
    F = T.B'*F_hat*T.A;
    clear U D V F_hat Vt A;
    
    %check how much inliers there are
    Points.A = [Feat.Am; ones(1,num_matches)]; %xy image a
    Points.B = [Feat.Bm; ones(1,num_matches)]; %xy image b
    Distance = [];
    
    for point = 1:num_matches
        d.bt1 = F*Points.A(:,point);
        d.bt2 = F'*Points.B(:,point);
        d.top = (Points.B(:,point)'*d.bt1)^2;
        d.bottom = (d.bt1(1)^2)+(d.bt1(2)^2)+(d.bt2(1)^2)+(d.bt2(2)^2);
        Distance(point) = d.top/d.bottom;
        clear d;
    end
    
    num_inliers = sum(Distance(:)<threshold);
    
    if num_inliers > best_num_inliers
        best_num_inliers = num_inliers;
        Best_inliers = matches(:,find(Distance<threshold));
        Best_F = F;
    end
    
    clear F Distance num_inliers
end

fprintf("matches left after Ransac: %d\n", size(Best_inliers,2))

inliers = Best_inliers;
F = Best_F;

end


function [T,coord_out] = normalizecoords(coordsin)
n = size(coordsin,2);
x = coordsin(:,1);
y = coordsin(:,2);

%get normalized coords
mx = mean(x);
my = mean(y);
d = mean(sqrt(((x-mx).^2)+((y-my).^2)));
T = [sqrt(2)/d 0 -mx*sqrt(2)/d;
    0 sqrt(2)/d -my*sqrt(2)/d;
    0 0 1];
p = T*[coordsin; ones(1,n)];
coord_out = p(1:2,:);
end