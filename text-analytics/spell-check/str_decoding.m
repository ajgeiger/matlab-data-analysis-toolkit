function [Tbl,Found] = str_decoding(name,s,h,T_Cor,THOR)

switch nargin
    
    case 2
        h = actxserver('word.application');
        h.Document.Add;
        T_Cor = false;
        THOR = false;
        
    case 3
        T_Cor = false;
        THOR = false;
        
    case 4
        THOR = false;
        
end

Found = cell(0,2);
Cells = cell(numel(s.iso),4);
for i = 1:numel(s.(name))
    [D1,D2,D3] = decord_string(s.(name){i},h,s,T_Cor,THOR);
    Cells{i,1} = D3;
    Cells(i,2) = s.iso(i);
    Cells{i,3} = D1;
    Cells{i,4} = D2;
    
    
    if T_Cor || THOR
        if D3 == 0
            D1 = unique(D1);
            I = ismember(D1,s.iso);
            if any(I)
                D1 = D1(I);
                [F_I,FI] = ismember(D1,Found(:,1));
                if ~all(~F_I)
                    FI = FI(F_I);
                    Found(FI,2) = cellfun(@(x) x+1,Found(FI,2),'un',0);
                    fprintf('%s -> %s (found) \n',D2,strjoin(D1));
                end
                
                if ~all(F_I)
                    N = sum(~F_I);
                    Base = cell(N,1);
                    Base(:,1) = {1};
                    Found(end+(1:N),:) = [D1(~F_I)',Base];
                end
            end
        end
    end
end

if nargin == 2
   h.Quit; 
end


words     = Cells(:,2);
fixed_sol = Cells(:,3);
Score     = Cells(:,1);
full_word = Cells(:,4);
Tbl = table(words,fixed_sol,Score,full_word);


end

