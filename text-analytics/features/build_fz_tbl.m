function tbl_fz = build_fz_tbl(hashmap,T,name)
% the function builds a freqency table of the number of times a word has
% been found in table T's elements. If the name variable is passed, the
% freqency is recorded given any arbitrary binary signal corresponding
% to table T's column of the cellstr variable vector name.


words = fieldnames(hashmap);   % obtain words from hashmap
freq = zeros(size(words,1),1); % set initial freqency
tbl_fz = table(words,freq);    % obtain tbl_ freqency

if nargin == 3 
    
    tbl_fz{:,name} = zeros(size(words,1),numel(name));
    TN = T{:,name};
    T_idx = T.idx;
    
    for i = 1:numel(words)
        tbl_fz.freq(i) = length(hashmap.(words{i}));
        Data = TN(ismember(T_idx,hashmap.(words{i})),:);
        tbl_fz.freq(i) = size(Data,1);
        tbl_fz{i,name} = 100.*sum(Data,1)./size(Data,1);
    end
else
    
    % basic hashmap freqency.
    for i = 1:size(words,1)
        tbl_fz.freq(i) = length(hashmap.(words{i}));
    end
end


end

