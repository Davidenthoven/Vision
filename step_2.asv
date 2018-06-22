%Apply normalized 8-point RANSAC algorithm to find best matches.

clear all;
load featureset.mat; %creates Features cell array.
N = 10; %RANSAC attempts

for i = 2 % 2:(sizeFeaures,1)
    %index number fom matches
    [matches] = vl_ubcmatch(Features{1,2},Features{i,2});
    
    % N RANSAC ATTEMPTS
    for ri = 1:N
        P = 8;
        %random index number of matches
        seed = randperm(size(matches,2),P);
        %start with empty A array
        A = [];
        
        %8 randomly chosen matches
        for s = seed(1:P)
            u1 = Features{1,1}(1,matches(1,s));
            v1 = Features{1,1}(2,matches(1,s));
            u2 = Features{i,1}(1,matches(2,s));
            v2 = Features{i,1}(2,matches(2,s));
           
            newA = [u1*u2 u2*v1 u2 v2*u1 v2*v1 v2 u1 v1 1];
            A = [A; newA]; %add to array A             
        end
        % calculate the F matrix
        Fv = null(A); % calculate nullsapce->vector of F
        F = [Fv(1) Fv(2) Fv(3);
             Fv(4) Fv(5) Fv(6);
             Fv(7) Fv(8) Fv(9)];

        clear seed;
    end
    
    clear matches;
end    
    
% (normalizeren)
% ransaccen we op alle features in de twee plaatjes
% redo until max inliers

%https://fr.mathworks.com/help/vision/ref/estimatefundamentalmatrix.html
