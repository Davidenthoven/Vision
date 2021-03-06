function [M, S] = SFM(Points)
Points = Points - repmat(sum(Points,2)/size(Points,2),1, size(Points,2));
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
L = lsqnonlin(@(x)myfun(x,M_hat),L0,[],[],options);
% Recover C
[C,p] = chol(L,'lower');
    % Update M and S

if p == 0
    display('afine');
    M = M_hat*C;
    S = pinv(C)*S_hat;
else
    display('not afine');
    M = M_hat;
    S = S_hat;
end
end