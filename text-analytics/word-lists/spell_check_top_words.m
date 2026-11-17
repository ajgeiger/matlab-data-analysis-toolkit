% 1. This script performs spell check on words and prints out what the word
% should be.
%
% 2. then their is a second method which identifies when a word starts with
% a particular string. 

clc
names = s.words_top;


names = regexprep(names,'[^a-z]+','');
demo_tbl = table(names);
demo_tbl.elements = cell2mat(cellfun(@(x)numel(x),names,'un',false));
demo_tbl = demo_tbl(demo_tbl.elements > 2,:);

for k = 1:numel(names)
   p = dd.spellCheck(names{k});
   p.found = false;
   if ~p.correct
       p = dd.spellCorrect(names{k},p);
       if ~p.correct
           if isfield(p,'spell')
                disp([names{k},' -> ',p.spell])
           else
               disp(['Big miss **** ',names{k}])
           end
          1; 
       end
   end
end

bad_words  = {'realise','mrs','waward','wikepedia'};
good_words = {'realize'};
         
% for k = 1:numel(names)
%    
%     word = names{k};
%     if startsWith(word,'background')
%         if numel(word) > 10
%             word = word(11:end);
%             
%             if numel(word)>3 && 1 == 1
%                 disp(word)
%                 bad_words{end+1} = names{k};
%             end
%         end
%     end
% end

% 
% good_words = good_words(~ismember(good_words,bad_words));
% names = names(~ismember(names,bad_words));
% names = unique([good_words';names]);
% s.words_top = names;

