function [M, S] = SFM(Points)
Points = Points - repmat(mean(mean(Points)), size(Points));

%singular value decomposition
[U,W,V] = svd(Points);

U = U(:, 1:3);
W = W(1:3, 1:3);
V = V(:, 1:3);

M_hat = U * sqrtm(W);
S_hat = sqrtm(W) * V';

%solve for affine ambiguity
A = M_hat;
L0 = pinv(A' * A);

% Solve for L
options = optimoptions(@lsqnonlin,'Display','off');
L = lsqnonlin(@myfun,L0,[],[],options);
% Recover C
[C,p] = chol(L,'lower');

if p == 0
    % Update M and S
    M = M_hat*C;
    S = pinv(C)*S_hat;
else
    M = M_hat;
    S = S_hat;
end
end