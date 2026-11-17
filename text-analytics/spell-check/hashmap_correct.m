function [T,hashmap] = hashmap_correct(s,T,hashmap,tbl,MW)
% T - the original table with info data
% hashmap - map of words corresponding value of idx in T
% tbl - list of replacement words


% build words to sitchout
iso_words = s.iso;
OW = MW(:,1);
Words_List = [s.bad_words;OW;s.slang;s.skip';s.words_top;s.add_words];
iso_words = iso_words(~ismember(iso_words,Words_List));


% process inputs:
merge_wds = tbl.words; % get merge wrds
add_wds = tbl.fixed_sol; % spelled 
Score = tbl.Score;


I = ismember(merge_wds,iso_words);
merge_wds = merge_wds(I);
add_wds = add_wds(I);
Score = cell2mat(Score(I));

% make sure add word is part of words



D = T.('comment_text_clean');
D_idx = T.('idx');

for i = 1:length(merge_wds)
    
    if Score(i) ~= 0
        continue
    end
    
    % obtain list of merge words:
    idx = hashmap.(merge_wds{i});
    new_wd = add_wds{i};
    
    
    for j = 1:length(idx)
        L_vec = D_idx == idx(j);
        [~,ix] = ismember(merge_wds(i),D{L_vec});
        if ix == 0
            fprintf('wrong %s location: %0.0f \n',merge_wds{i},L_vec)
            continue
        elseif ix == 1
            D{L_vec} = [new_wd,D{L_vec}(ix+1:end)];
        elseif ix ~= length(D{L_vec})
            D{L_vec} = [D{L_vec}(1:ix-1),new_wd,D{L_vec}(ix+1:end)];
        else
            D{L_vec} = [D{L_vec}(1:ix-1),new_wd];
        end
    end
    for j = 1:length(new_wd)
        if isfield(hashmap,new_wd{j})
            hashmap.(new_wd{j}) = [hashmap.(new_wd{j}),idx];
        end
    end
end



hashmap = rmfield(hashmap,merge_wds); % remove merge words

T.('idx') = D;


end

