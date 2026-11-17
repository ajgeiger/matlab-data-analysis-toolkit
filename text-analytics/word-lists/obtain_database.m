function s = obtain_database(hashmap,Thresh,Thresh_To)


% process inputs:
if nargin == 1, Thresh = 25; Thresh_To = 35; end
if nargin == 2, Thresh_To = 30; end


% General Words:
bad_words = obtain_badwords(); % obtain bad words
[flag,fix,Add_Words] = getStart_n_Fit(); % obtain key words
[slang,meaning] = obtain_slang();
Key_Words = [bad_words;Add_Words;flag'];
[bad_wd,LL] = SortByLength(Key_Words);
[Add_Words,LLV] = SortByLength(Add_Words);

% upload words:
s.skip      = getSkipWords(); %
s.key       = [bad_words;Add_Words;flag']; % bad words
s.flag      = flag; % flag 
s.fix       = fix; % fixed words
s.bad_words = bad_words;
s.slang     = slang;
s.meaning   = meaning;
s.add_words = Add_Words;


% Hash map break down:
% tbl - low freq words
% tbl_fzs - high freq words
tbl_fzs = obtain_hashmap_fz_tbl(hashmap); % obtain hashmap fz table
tbl = tbl_fzs(tbl_fzs.freq < Thresh,:);
tbl_mid = tbl_fzs(tbl_fzs.freq >= Thresh_To,:);
tbl_top = tbl_fzs(tbl_fzs.freq >= Thresh,:);


% sort by word length:
[words_mid,L] = SortByLength(tbl_mid.words);
words_mid = [words_mid(2 < L & 5 > L);bad_wd(2 < LL & 5 > LL)];


% sort by word length:
[words_top,L] = SortByLength(tbl_top.words);
words_top = [words_top(4 < L);bad_wd(4 < LL)];


% sort by length:
s.iso = SortByLength(tbl{:,'words'}); % key words to solve for
s.words_bot = [get_words_low();bad_wd(3 > LL)];
s.words_top = unique([words_top;words_mid;Add_Words(LLV > 2)]); % words length > 2


end


% get low words:
function words_low = get_words_low()

words_low = {'at','as','by','be','do','he','hi','it','in','to','go',...
             'or','on','up','an','uh','if','we','is','of','i','a','me','he','us'};
end


% key constant words:
function [Starter,The_Fix,Add_Words] = getStart_n_Fit()

% original arguments:
Starter = {'fuk','fck','bich','dck','fukin','pakistan','watch',...
    'fucka','computor','plz','anuser','muthafucker','arses',...
    'fuku','raccoon','fcked','bushit','fcker','mutha',...
    'auspicious','mustard','gluzing','muvva','mutha','kuban',...
    'fergit','fukperf','logar','maramure','endura',...
    'ashida','klements','bernstein','jovanovic','levantines',...
    'collingwood','lufthansas','cheetos','susquehanna','groningen',...
    'hashem','pulaskis','slavonic','maoist','hippocratic',...
    'badoglios','dacian','hellenes','slovenes','fuking','fcking',...
    'farbe'};


The_Fix = {'fuck','fuck','bitch','dick','fucking','pakistan','watch',...
    'fucker','computer','please','an user','motherfucker','asses',...
    'fuck you','raccoon','fucked','bullshit','fucker','mother',...
    'favorable','Condiment','gluzzing','mother','mother','cuban',...
    'forgit','fucking perfect','province','romania','company',...
    'prime minister','company','composer','serbian','levantine',...
    'location','lufthansa','cheeto','university','netherlands',...
    'judaism thank god','tool','language','ideology','hippocratic',...
    'badoglio','Country','hellene','ethnic group','fucking','fucking',...
    'color'};


Add_Words = {'spicy';'diaper';'bastard';'guzzling';...
    'henrietta';'roga';'sissy';'shitter';'spiced';'muffled';'mickeys';...
    'mickey';'wrist';'kennedey';'spoon';'gobbled';'scalia';'haynes';...
    'strauss';'jarrett';'lufthansa';'cheeto';'keynes';'medicine';...
    'badoglio';'hellene';'burnett';'rent';'peaches';'candidates';...
    'domination';'hotels';'hotel';'interesting';'httpwww';'www';...
    'http';'insulate';'vacuum';'useful';'zod';'source';'poppers';...
    'gmail';'kaiser';'investigations';'valve';'users';'uninformative';...
    'msnbc';'boxing';'farbe'};

end


% obtain sorted bad words list:
function bad_words = obtain_badwords()

% Load Databases:
load bad_words_table.mat bad_words_table

% fix up bad words:
bad_words = bad_words_table.words;
for i = 1:length(bad_words)
   bad_words{i} = regexprep(lower(bad_words{i}),'[^a-z]+','');
end

% bad word filter
IBW = cell2mat(cellfun(@(x) length(x),bad_words,'un',0));
bad_words = bad_words(3 < IBW);
[~,stringLength] = sort(cellfun(@length,bad_words),'descend');
bad_words = bad_words(stringLength);

clear bad_words_table

end


% obtain hashmap freqency:
function tbl_fzs = obtain_hashmap_fz_tbl(hashmap)

% obtain fz:
words = fieldnames(hashmap);   % hash map words
freq = zeros(size(words,1),1); % hashmap freqency
for i = 1:size(words,1),  freq(i) = size(hashmap.(words{i}),2); end
tbl_fzs = table(words,freq);

end


% get skip words:
function skip = getSkipWords()

skip = {'hoarse','marse','dickens','dickens','httpwww','dickerson',...
    'uranus','hancock','hyrcanus'};

end


% sort cell array by length:
function [words,L] = SortByLength(words)

[~,stringLength] = sort(cellfun(@length,words),'descend');
words = words(stringLength);

if nargout== 2
   L = cell2mat(cellfun(@(x) length(x),words,'un',0)); 
end

end


function [slang,meaning] = obtain_slang()


% slang table
load Slang_Table_clean.mat slang_table
slang = slang_table.words;
meaning = slang_table.meaning;


end