function tbl = hashmap_pre_fix(hashmap,Thresh)


% process inputs:
if nargin == 1, Thresh = 25; end
Starts = {'fuk','fck','bich','dck'};
Fix = {'fuck','fuck','bitch','dick'};
OkayList = cell(0,2);


% preprocesses data:
tbl_fzs = obtain_hashmap_fz_tbl(hashmap); % obtain hashmap fz table
tbl = tbl_fzs(tbl_fzs.freq < Thresh,:);
words = tbl{:,'words'};



for i = 1:length(Fix)
    I = startsWith(words,Starts{i});
    L = length(Starts{i});
    
    if any(I)
        OldWords = words(I);
        NewWords = cellfun(@(x) switchOut(x,Fix{i}),words(I),'un',0);
        for j = 1:numel(OldWords)
            OkayList(end+1,:) = [OldWords(j),{NewWords(j)}]; %#ok
        end
    end
end

[~,idx_shift] = ismember(OkayList(:,1),tbl.words);
tbl = tbl(idx_shift,:);
tbl{ismember(tbl.words,OkayList(:,1)),'fixed_sol'} = OkayList(:,2);



end

function x = switchOut(x,n)

L = length(n);
if length(x) == L
    x = [n,x(L+1:end)];
else
    x = n;
end

end


% obtain hashmap freqency:
function tbl_fzs = obtain_hashmap_fz_tbl(hashmap)

% obtain fz:
words = fieldnames(hashmap);   % hash map words
freq = zeros(size(words,1),1); % hashmap freqency
for i = 1:size(words,1),  freq(i) = size(hashmap.(words{i}),2); end
tbl_fzs = table(words,freq);

end
