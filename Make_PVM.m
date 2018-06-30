function [PVM] = Make_PVM(inliers)
    PVM = inliers{1}; %first two rows
    
    for i = 2:18
        A = PVM(i,:);
        B = inliers{i};
        %add dupes below the already availible ones
        [~,ia,ib]   = intersect(A, B(1,:), 'stable');
        PVM         = [PVM; zeros(1,size(PVM,2))]; %add zero row
        PVM(i+1,ia) = B(2,ib);
        
        %add new ones to the tail end        
        [~,idiff]   = setdiff(B(1,:),A,'stable');        
        PVM = [PVM [zeros(i-1,size(idiff,1)); B(:,idiff)]]; %
    end
    clear ia ib idiff;
    
    %last rule should fold back
    A = PVM(19,:);
    B = inliers{19};
    C = PVM(1,:);
    
    [~,ia,ib] = intersect(C, B(2,:), 'stable'); %add to first row
    PVM(19,ia) = B(1,ib);
    %remove from set
    [~,idiff]   = setdiff(B(2,:),PVM(19,ia),'stable');
    B = B(1:2,idiff);
    clear ia ib idiff;

    [~,ia,ib] = intersect(A, B(1,:), 'stable'); %add to last row
    PVM(1,ia)   = B(2,ib);    
    [~,idiff]   = setdiff(B(1,:),A,'stable');
    PVM         = [PVM [B(2,idiff); zeros(17,size(idiff,1)); B(1,idiff)]];
          
end