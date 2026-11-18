function [GD_WD,CORRECT] = strdecoder(word,h)
if 1==1, error('function is unfit'), end

CORRECT = false(1,2);
UNC = unique(double(word));
GD_WD = cell(1,1);

% check special case:
if ~h.CheckSpelling(word) && numel(UNC) == 2
    GD_WD  = word;
    CORRECT(1) = true;
    return
end


% decode multi word problems
Stats = tabulate(double(word));
L1 = ismember(double(word),Stats(Stats(:,3) > 32,1));
L1 = ~(logical([1 diff(double(word))])==0 & L1);


if h.CheckSpelling(word(L1))
    
    % if word is correct leave
    GD_WD = cellstr(word(L1));
    CORRECT(2) = true;
    return
    
elseif numel(word(L1)) > 4

    WORD  = double(word(L1));
    LET_2 = UNC(~ismember(UNC,WORD(1)));
    
    if xor(ismember(101,UNC),ismember(97,UNC)) && ismember(104,UNC)
        
        if ismember(101,UNC)
            GD_WD = {'hehe'};
            CORRECT(2) = true;
            return
        else
            GD_WD = {'haha'};
            CORRECT(2) = true;
            return
        end
    else
        if WORD(1) == WORD(end)
            GD_WD = cellstr(char([WORD(1),LET_2,WORD(1)]));
            return
        else
            GD_WD = cellstr(char([WORD(1),LET_2]));
            return
        end
    end
end



end

