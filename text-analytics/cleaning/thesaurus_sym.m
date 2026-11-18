function [Cells,Found] = thesaurus_sym(word)

[Cells,Found] = betterSearch(word);

if numel(Cells) < 4
    [word,T] = CleanWordEndings(word);
    if T
        [Cells,Found] = betterSearch(word);
    end
end


Cells = unique(Cells,'stable');

end


function [word,T] = CleanWordEndings(word)
T = false;
% s and es check:
if endsWith(word,'ies')
    word = [word(1:end-3),'y'];
    T = true;
elseif endsWith(word,'ely')
    word = word(1:end-2);
    T = true;
elseif endsWith(word,'edness')
    word = word(1:end-6);
    T = true;
elseif endsWith(word,'ness')
    word = word(1:end-4);
    T = true;
elseif  endsWith(word,'es')
    word = word(1:end-2);
    T = true;
elseif endsWith(word,'s')
    word = word(1:end-2);
    T = true;
elseif endsWith(word,'ish')
    word = word(1:end-3);
    T = true;
elseif endsWith(word,'ed')
    word = word(1:end-2);
    T = true;
elseif endsWith(word,'ing')
    word = word(1:end-3);
    T = true;
elseif endsWith(word,'ility')
    word = [word(1:end-5),'le'];
    T = true;
    
elseif endsWith(word,'ically')
    word = word(1:end-4);
    T = true;
end


end


function [Cells,Found] = betterSearch(word)


try
    Found = true;
    url = ['https://www.freethesaurus.com/',word];
    html_txt = webread(url);
    C = ['synonyms for ',word,': '];
    html_txt = strsplit(html_txt,C);
    
    if numel(html_txt) == 1
        html_txt = strsplit(html_txt{1},'synonyms for ');
        if numel(html_txt) ~= 1
            html_txt = strsplit(html_txt{2},': ');
        else
            C = ['synonym for ',word,': '];
            html_txt = strsplit(html_txt,C);
        end
    end
       
    html_txt = html_txt{2};
    html_txt = strsplit(html_txt,'.');
   
    html_txt = html_txt{1};
    html_txt = strsplit(html_txt,', ');
    
    Cells = cell(numel(html_txt),1);
    for i = 1:numel(html_txt)
        tmp = strsplit(html_txt{i},'"');
        Cells{i} = tmp{1};
    end
    
    Cells = unique(Cells,'stable');
    
catch
    Cells = {};
    Found = false;
end



end


function [Cells,Found] = search_website(word) %#ok


try
    Found = true;
    url = ['http://www.thesaurus.com/browse/',word];
    html_txt = webread(url);
    C = '<div id="words-gallery" class="words-gallery" style="display: none">';
    html_txt = strsplit(html_txt,C); html_txt = html_txt{2};
    html_txt = strsplit(html_txt,'data-explore="');
    html_txt = html_txt(2:2:end);
    
    Cells = cell(numel(html_txt),1);
    for i = 1:numel(html_txt)
        tmp = strsplit(html_txt{i},'"');
        Cells{i} = tmp{1};
    end
    
    Cells = unique(Cells,'stable');
    
catch
    Cells = {};
    Found = false;
end


end

% 
% if ~isempty(Other) && numel(Cells) < 4
%     [Cells2,Found2] = betterSearch(Other);
%     if Found2 && ~isempty(Cells)
%         Cells = [Cells;Cells2];
%     else
%         Cells = Cells2;
%     end
% end
% 
% if numel(html_txt) == 1
%     html_txt = strsplit(html_txt{1},' What are synonyms for ');
%     Other =  strsplit(html_txt{2},'?');
%     Other = Other{1};
% %     Found = false;
% %     Cells = {};
% %     return
% % end
% if startsWith(html_txt{2},' What are synonyms for ')
%     Other =  strsplit(html_txt{2},'?');
%     Other = Other{1}(24:end);
% end
 