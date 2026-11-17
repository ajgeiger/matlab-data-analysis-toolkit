% build wiki words list:

wiki_words = fileread('Wiki_Words.txt');
html_txt =strsplit(wiki_words,'</a></li>');
words = cell(1,1);
meaning = cell(1,1);
k = 0;
for i = 1:length(html_txt)
    if length(html_txt{i}) < 9, k = k + 1; continue, end
    try
        word = strsplit(html_txt{i},'<li>');
        word = strsplit(word{2},' ');
        type = strsplit(html_txt{i},'>');
        words{i-k,1}  = ['WP:',word{1}];
        meaning{i-k,1}  = type{end};
    catch
        
    end
end

WikiLoopUp = table(words,meaning);