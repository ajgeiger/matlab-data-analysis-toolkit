% T = splitData(trainn,col);
% col = 'comment_text';

% Isp1 = '<div class="dictionary-word"><abbr class="dictonary-abbr" title="';
% Isp2 = '"><span class="dictonary-slang"><dt>';
% 



for j = 1:26
    Letter = char(96+j);
    
    html_txt = webread(['https://www.noslang.com/dictionary/',Letter,'/']);
    html_txt = strsplit(html_txt,{'<div class="dictonary-words">','<ul class="list-inline text-center">'});
    html_txt =strsplit(html_txt{3},'<div class=');
    
    words = cell(0,1);
    slangs = cell(0,1);
    k = 0;
    for i = 1:length(html_txt)
        if length(html_txt{i}) < 9, k = k + 1; continue, end
        word = strsplit(html_txt{i},'title="');
        word = strsplit(word{2},'"><span class=');
        slang = strsplit(html_txt{i},'<dt>');
        slang = strsplit(slang{2},':</dt></a>');
        
        words{i-k,1}  = word{1};
        slangs{i-k,1} = slang{1};
        
    end
    
    if j == 1
       slang_table = table(words,slangs);
       continue
    end
    
    slang_table = [slang_table;[words,slangs]];
    
end

% clean data new with slang

% for i = 1:size(slang_table.slangs)
%    slang_table.slangs{i}(slang_table.slangs{i} == ' ') = [];
%     
% end