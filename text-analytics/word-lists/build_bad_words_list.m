% build swear words list:


% html_txt =strsplit(badwords_List,'<a name="');
words = cell(1,1);
types = cell(1,1);
k = 0;
for i = 1:length(html_txt)
    if length(html_txt{i}) < 9, k = k + 1; continue, end
    word = strsplit(html_txt{i},'"></a>');
    type = strsplit(html_txt{i},' - ');
    type = strsplit(type{2},'<br>');
    words{i-k,1}  = word{1};
    types{i-k,1}  = type{1};
end

    
   
    
