function T = replaceSlang(T,col,newCol)
if 1 == 1,error('function has been replaced'), end
if nargin == 2, newCol = col; end
load Slang_Table_clean.mat slang_table

del  = {':',';','(',')','''',',','.','?','!'};
RepList   = {'fuk','fck'};
Repit     = {'fuck','fuck'};
skip_list = {'dont';'youre';'nonfree';'nonnotable';'pokemon';'beatles';...
    'wwii';'jeezz';'barnstar';'infobox';'userpage';'talkpage';'imdb';...
    'theyre';'aint';'hitler';'thor';'ieee';'nist';'itll';'readd';...
    'slavs';'brian';'mani';'daw';'outta';'jimbo';'hehe';'bahaha',...
    'haha','rico'};


D = T.(col);
TotalWords_Replaced = 0;
ReplaceMents        = 0;

for i = 1:size(T,1)
    sen = strsplit(erase(lower(D{i}),del),' ');
    [I,idx] = ismember(sen,slang_table.slangs);
    
    if any(I) % convert slang into words:
        slangs = slang_table.words(idx(I));
        Ix = 1:length(I);
        Ix = fliplr(Ix(I));
        TotalWords_Replaced = TotalWords_Replaced + length(Ix);
        ReplaceMents = ReplaceMents + 1;
        if rem(i,10000) == 0
            fprintf('\nTotal Words Replaced: %0.0f',TotalWords_Replaced)
            fprintf(' Percent Replacements: %0.2f',100*ReplaceMents/i)
        end
        
        for j = 1:length(Ix)
            new_word = strsplit(erase(lower(slangs{j}),del),' ');
            sen = [sen(1:Ix(j)-1),new_word,sen(Ix(j)+1:end)];
        end
    end
    
    
    % correct words:
    D{i} = unique(regexprep(sen,'[^a-z]+',''));
    D{i} = D{i}(~ismember(D{i},{''}) & strlength(D{i}) < 15);
    
end

for i = 1:size(T,1), j = 0;
    while 1, j = j + 1;

        if j > length(D{i}), break
        elseif h.CheckSpelling(D{i}{j}), continue
        elseif length(D{i}{j}) <= 3, continue
        elseif startsWith(D{i}{j},'wp'),wpstr(D{i},j),j = j+1; continue
        elseif contains(D{i}{j},RepList)
            D{i}{j} = replace(D{i}{j},RepList,Repit);
        end
        
        
        % Block Two:
        if ismember(D{i}{j},skip_list), continue, end
        
        
        WN = double(D{i}{j});
        if ismember(D{i}{j},skip_list), continue, end
        
        I = sum(cumprod(WN == WN(1)));
        if I >= 2, D{i}{j} = D{i}{j}(I:end); continue, end
        
        I = sum(cumprod(flip(WN == WN(end))));
        if I >= 2, D{i}{j} = Bktrm(D{i}{j},I); continue, end
        
        I = WN == 97 | WN == 104 | [WN(1) == 98,false(1,length(WN)-1)];
        if all(I), D{i}{j} = strha(WN); continue, end
        
        I = WN == 101 | WN == 104;
        if all(I), D{i}{j}='hehe'; continue, end
        
    end
    
end


T{:,newCol} = D;

end

function W = wpstr(W,j)

N = {'wrong','person',W{j}(3:end)};
W = [W(1:j-1),N,W(j+1:end)];

end

function W = Bktrm(W,I)

if double(W(end)) == 115, I = I + 1;  end
W = W(1:end-I+1);

end

function W = strha(WN)

if WN(1)==98, W = 'bahaha'; else, W = 'haha'; end

end







