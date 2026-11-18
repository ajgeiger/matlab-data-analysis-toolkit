
if exist('ddtemp','var') == 0
    ddtemp = DocumentDecoder();
end


word = 'stupodfuckingkids';

ddtemp = ddtemp.sortDataBaseWords();
word   = ddtemp.decode(word);

disp(word)