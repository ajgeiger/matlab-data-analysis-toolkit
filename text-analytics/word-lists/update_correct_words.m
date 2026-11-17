% updates

new_words = {'terrorism','nutter','turd','explode',...  
'vesel','spicer','brietbart','doodoo','phony','poopie','foscam',...
'happer','neshek','comey','comeys','bossie','biden','bidens',...
'santer','physe','mayhew','merkel','deshowitz','dougie','barron',...
'moseby','maga','kimmel','miccichie','mosterf','peetous',...
'pootie','spicy','phoney','lifer'};

% add new words
s.words_top = unique([s.words_top;new_words']);

% add new flags
s = add_flag(s,'trumpers','trump supporters');
s = add_flag(s,'demexit','democrat exit');
s = add_flag(s,'tumpster','trump like');
s = add_flag(s,'wasnt','was not');
s = add_flag(s,'youve','you have');
s = add_flag(s,'dontcha','dont you');
s = add_flag(s,'trumpies','trump buddies');


% add flag
function s = add_flag(s,word,phrase)

s.flags(word,:) = {word,phrase};
s.database.flag = s.flags.id;

end