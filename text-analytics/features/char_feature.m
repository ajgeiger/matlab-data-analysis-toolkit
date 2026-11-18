function [Out_1,Out_2] = char_feature(D,C,S,M,W)
% multi input
% D - single cell word to compare
% C - Compare cell vector double of cellstr
% S - Score Value
% M - Error
% W - Weight Vector

if nargin == 1
    Out_1 = get_char_feature(D);
    Out_2 = Out_1 ~= 0;
else
    if iscell(D), VD = get_char_feature(D); else, VD = D; end
    if iscell(C), VC = get_char_feature(C); else, VC = C; end
    
    if nargin < 5
        W = [1,1,1];
    elseif numel(W) ~= 3
        W = [W,zeros(1,3-numel(W))+1];
    end
         
    VD(1:26)  = VD(1:26).*W(1);
    VD(27:52) = VD(27:52).*W(2);
    VD(53:78) = VD(53:78).*W(3);
    
    VC(1:26)  = VC(1:26).*W(1);
    VC(27:52) = VC(27:52).*W(2);
    VC(53:78) = VC(53:78).*W(3);
    
    
    [WCV,MC_I] = min(abs(sum(abs((VD ~= 0) - (VC ~= 0)),2)));
    [MLV,ML_I] = min(abs(sum(abs(VD - VC),2)));
    
    off_set = 0;
    if nargin > 3
        if numel(D{1}) >= M(end,1)
            off_set = M(end,2);
        elseif numel(D{1}) >= M(1,1)
            for i = 1:size(M,1)
                if numel(D{1}) > M(i,1)
                    off_set = M(i,2);
                    break
                end
            end
        end
    end
    
    if MLV + WCV < S + off_set && ML_I == MC_I
        Out_1 = ML_I;
    else
        Out_1 = 0;
    end
    
end
   
end


function V = get_char_feature(D)


V = zeros(length(D),78);

for i = 1:length(D)
    
    V(i,double(D{i}(1))-96) = 1;
    if length(D{i}) < 2, continue, end
    V(i,double(D{i}(2))-70) = 1;
    
    if length(D{i}) > 3
        D(i) = unique(regexprep(lower(D(i)),'[^a-z]+',''));
        a = tabulate(double(D{i}(3:end))-96);
        V(i,52+a(a(:,2)~=0,1)) = a(a(:,2)~=0,2);
    end
    
end



end

