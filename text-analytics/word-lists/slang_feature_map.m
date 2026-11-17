% build slang feature map:

types =bad_words_table.types;
cat = unique(strsplit(strjoin(types')));

sz = size(types,1);
Data = zeros(sz,length(cat));

for i = 1:sz
    Data(i,:) = ismember(cat,strsplit(types{i}));
end


Data = array2table(Data,'VariableNames',cat);
bad_words_table = [bad_words_table,Data];