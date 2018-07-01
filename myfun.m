function Dif = myfun(L,M)

%pre-alocate the Dif matrix
Dif = zeros(size(M,1)/2,4);

%compute the residuals
for i = 1:size(M,1)/2
    Ai = M(i*2-1:i*2,:);
    D = Ai*L*Ai' - eye(2);
    Dif(i,:) = D(:);
end