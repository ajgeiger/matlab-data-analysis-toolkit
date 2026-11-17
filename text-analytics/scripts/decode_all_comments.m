% demo decoder
if exist('dd','var') == 0
    dd = DocumentDecoder();
end

dd.thesaurusProcess = false;
dd.tenseProcess = false;
dd.keepIncorrect = true;

%document = '.the man went to the mall in 1994 how can!!!';
%dd.decode(document)
documents = T.comment_text;
n = numel(documents);
dd.keepIncorrect = true;

x  = datetime('now');
for k = 1:n
    if rand < .1
        fprintf('%0.5f hours left \n',hours(((x -  datetime('now'))/k).*(k-n)))
    end
    
    documents{k} = dd.decode(documents{k});
end




