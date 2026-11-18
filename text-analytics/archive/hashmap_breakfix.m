function tbl = hashmap_breakfix(hashmap,Thresh)


% process inputs:
if nargin == 1, Thresh = 25; end



% preprocesses data:
bad_words = obtain_badwords(); % obtain bad words
tbl_fzs = obtain_hashmap_fz_tbl(hashmap); % obtain hashmap fz table
tbl = tbl_fzs(tbl_fzs.freq < Thresh,:);
tbl_fzs = tbl_fzs(tbl_fzs.freq >= Thresh,:);
words = tbl_fzs.words;
iso = tbl{:,'words'};



% obtain feature words:
s.Bad_Vec = char_feature(bad_words);
s.BD_WDs = bad_words;



% slang table
load Slang_Table_clean.mat slang_table
s.SlangWords = slang_table.words;
s.SlangMeaning = slang_table.meaning;



% output cell:
OL = cell(0,2);



% first pass & compile:
OL = switch_bad_word(OL,iso,s,words);


try
    [~,idx_shift] = ismember(OL(:,1),tbl.words);
    tbl = tbl(idx_shift,:);
    tbl{ismember(tbl.words,OL(:,1)),'fixed_sol'} = OL(:,2);
catch
    tbl = OL;
end

end

% attempt one:
function [OL,KEY_WD,words] = switch_bad_word(OL,Pot_BW,s,words)


% manage and filter original arguments:
s.True_Words = words;
[s.Starter,s.The_Fix,Add_Words] = getStart_n_Fit();
s.KEY_WD = [s.BD_WDs;s.Starter'];


% bad word filter
[words,LBW] = SortByLength(words);
s.KEY_WD = SortByLength([s.KEY_WD;words(4 < LBW)]);
s.KEY_WD = [Add_Words;s.KEY_WD];
words = SortByLength(words(2 < LBW & 4 >= LBW));


% Launch MS Word and create document:
h = actxserver( 'word.application' );
h.Document.Add;
s.skip = {'hoarse','marse','dickens','dickens','httpwww','dickerson',...
    'uranus','hancock','hyrcanus'};




for i = 1:numel(Pot_BW)
    
    % initial constants
    WD_LN = numel(Pot_BW{i});
    REDO = false;
    ERROR = [];
    
    % skip words of length less than three:
    if WD_LN < 3, continue, end
    
    
    % check if is potential name:
    if contains(Pot_BW{i},s.skip), continue, end
    
    
    
    % break down word:
    [GD_WD,LOC,CORRECT,Trash] = ObtainWords(Pot_BW(i),s,h,words,ERROR);
    
    
    % make sure good words exist
    if isempty(GD_WD), continue, end
    
    
    
    % check logic to ensure word has beenfound correctly:
    LN_SUM = getWordPerformance(Trash,WD_LN);
    
    
    
    
    % check bad word cases:
    [REDO,QUIT] = checkCases(Pot_BW{i},GD_WD,LN_SUM,REDO,CORRECT);
    if QUIT, continue, end
    
    
    
    
    % check if word passes:
    if CheckWord(GD_WD,Trash,CORRECT) && ~REDO
        OL(end+1,:) = [Pot_BW(i),{GD_WD}]; %#ok
        fprintf('\nWord Partly Correct:  ')
        PrintFUNCTION(Pot_BW{i},GD_WD,Trash)
        continue
    end
    
    
    
    
    % bad word found error.
    if REDO
        ERROR = [2,1];
        [GD_NW,~,~,TrasN] = ObtainWords(Pot_BW(i),s,h,words,ERROR);
        if ~Checkifequals(GD_NW,GD_WD) && ~CORRECT
            fprintf('\nImproper Word:  ')
            PrintFUNCTION(Pot_BW{i},GD_WD,Trash)
            PrintFUNCTION(GD_NW,TrasN)
            OL(end+1,:) = [Pot_BW(i),{GD_WD}]; %#ok
        end,continue
    end
    
    
    
    
    % low hit rate.
    if LN_SUM > .32
        ERROR = [2,1];
        [GD_NW,~,~,TrasN] = ObtainWords(Pot_BW(i),s,h,words,ERROR);
        if LN_SUM <= getWordPerformance(TrasN,WD_LN), continue, end
        if ~Checkifequals(GD_NW,GD_WD) && ~CORRECT
            fprintf('\nAlternate Word:  ')
            PrintFUNCTION(Pot_BW{i},GD_WD,Trash)
            PrintFUNCTION(GD_NW,TrasN)
            OL(end+1,:) = [Pot_BW(i),{GD_WD}]; %#ok
        end,continue
    end
    
    
    if LOC == 0 || LOC == 4
        fprintf('\nReplaced Word:  ')
        PrintFUNCTION(Pot_BW{i},GD_WD,Trash)
        OL(end+1,:) = [Pot_BW(i),{GD_WD}]; %#ok
        continue
    end
    

    OL(end+1,:) = [Pot_BW(i),{GD_WD}]; %#ok
    
end

KEY_WD = s.KEY_WD;
h.Quit % - Quit MS Word.

end


% check if equals:
function EQUALS = Checkifequals(GD_NW,GD_WD)

EQUALS = all(ismember(GD_NW,GD_WD));
EQUALS = EQUALS & all(ismember(GD_WD,GD_NW));
EQUALS = EQUALS & numel(GD_NW) == numel(GD_WD);

end


% check cases
function [REDO,QUIT] = checkCases(WORD,GD_WD,LN_SUM,REDO,CORRECT)
QUIT = false; % quit logic
HOT_WORDS = {'anus','arse','mick','cock','ass','muff'};

if ~any(ismember(GD_WD,HOT_WORDS)), return, end
if CORRECT, QUIT = true; return,  end % if word is correct throw out.

% arse: word case.
if any(startsWith(GD_WD,{'arse'})) && WORD(5) == 'n' || LN_SUM >= .2
    QUIT = true; return
end

% mick: word case.
if any(startsWith(GD_WD,{'mick'})) && LN_SUM >= .2
    QUIT = true; return
end

% ass: word case.
if any(startsWith(GD_WD,{'ass'})) && LN_SUM >= .2
    QUIT = true; return
end

% muff: word case.
if any(startsWith(GD_WD,{'muff'})) && LN_SUM >= .05
    QUIT = true; return
end

% cock: word case.
if any(startsWith(GD_WD,{'cock'})) && LN_SUM >= .2
    REDO = true;
end


end



% -------------------------------------------------------------------------
%                       Main Break Down Word Functions
% -------------------------------------------------------------------------


% get word performance:
function Perf = getWordPerformance(Trash,WD_LN)

    Perf = sum(cell2mat(cellfun(@(x) length(x),Trash,'un',0)))/WD_LN;

end


% attempt to replace word:
function [D,I] = strWDRep(D,Words,Meaning)

[I,II] = ismember(D,Words); % try to find word
if ~I,return, end % join words go to next
D = Meaning(II(I)); % replace word with meaning
D = strsplit(char(D),' '); % join str
D = cellfun(@(x) regexprep(lower(x),'[^a-z]+',''),D,'un',0);
D = D(~ismember(D,{''}));

end


% obtain good words
function [GD_WD,Loc,CORRECT,Trash] = ObtainWords(New_WD,s,h,words,ERROR)


% initial settings:
CORRECT = false;
ERROR   = round(ERROR);
MB_WD   = cell(0,0);
GD_WD   = cell(0,0);
Trash   = cell(0,0);

K   = 0;
Loc = 8;


if sum(ismember(GD_WD,s.Starter)) ~= 0
    GD_WD = replaceFlaggedWords(GD_WD,s);
    return
end

% check if name:
[PS_Word,passed] = debugWord(New_WD{1},h,s.True_Words);
if ~passed, return, end
if ~isempty(PS_Word), GD_WD = PS_Word;  return, end
[PS_Word,DeCorrect] = strdecoder(New_WD{1},h);
if DeCorrect(2), GD_WD = PS_Word; return, end

Loc = 1;

while 1, K = K + 1; % Break Condition
    
    
    % While loop break condition
    if isempty(New_WD), break, end % check if new word is empty
    
    
    % if we know K == 1 we know the words has not passed the name test.
    % However, if K ~= 1 we have not determined if the word is or is not a
    % name. therefore it must be checked.
    
    if K ~= 1, [PS_Word,passed] = debugWord(New_WD{1},h,s.True_Words);
        
        if ~isempty(PS_Word) || ~passed
            [GD_WD,New_WD] = pop_WD(GD_WD,New_WD,PS_Word);
            continue
        end
    end

    % Obtain Word Information:
    WD_LN = numel(New_WD{1}); % Word Length
    
    
    % Initial conditions
    if WD_LN < 2, Trash(end+1) = New_WD(1); %#ok
        New_WD(1) = []; continue
    end
    
    
    % simulated annealing cooling function
    if K == 1
        S = 5; TC = 2; MS = [6,1;8,2;10,3];
        
    elseif K == 2
        S = 4; TC = 1; MS = [6,1;8,2;10,3];
        
    else
        S = 2; TC = 1; MS = [6,1;8,2;10,3];
        
    end
    
    
    % Spell Check:
    if h.CheckSpelling(New_WD{1}) % check if spelling is correct
        if K ~= 1 % check if loop is not on first itteration
            [GD_WD,New_WD] = pop_WD(GD_WD,New_WD); % add good word
            continue % continue loop
        else % if spelling is correct
            CORRECT = true; % set correct spelling to true
        end
    end
    
    % Attempt To Correct Spelling:
    if h.GetSpellingSuggestions(New_WD{1}).count ~= 0 && WD_LN > 4
        
        % spell suggestion and logical output:
        [T_WD,LOGIC] = spellSuggest(h,New_WD{1},S,MS,[2,1],TC);
        
        % if all test past switch out word:
        if LOGIC ~= 0
            [GD_WD,New_WD] = pop_WD(GD_WD,New_WD,T_WD);% add good word
            continue
        end
    end
    
    
    % check to see if word is a bad word
    IDX = char_feature(New_WD(1),s.Bad_Vec,4,[6,2;8,3;10,4],[2,1]);
    
    
    
    
    
    % START IF STATEMENT:
    if IDX ~= 0 %check if index exists
        [E,ERROR] = getErrorData(ERROR); % obtain error
        if E ~= 1
            [GD_WD,New_WD] = pop_WD(GD_WD,New_WD,s.BD_WDs(IDX));
            continue
        end
    end
    
        
        
    % check if new word exists as a key word.
    if contains(New_WD{1},s.KEY_WD)
        [E,ERROR] = getErrorData(ERROR); % obtain error
        IDX = FindKeyWordIdx(New_WD{1},s.KEY_WD,E); % find idx
        New_WD = addToNewWord(New_WD{1},s.KEY_WD{IDX},New_WD); % add new word
        [GD_WD,New_WD] = pop_WD(GD_WD,New_WD,s.KEY_WD(IDX)); % pop old word

        
        
        
    % check if new word exists as a key word.
    elseif contains(New_WD{1},words)
        [E,ERROR] = getErrorData(ERROR); % obtain error
        IDX = FindKeyWordIdx(New_WD{1},words,E);  % find idx
        New_WD = addToNewWord(New_WD{1},words{IDX},New_WD); % add new word
        [GD_WD,New_WD] = pop_WD(GD_WD,New_WD,words(IDX)); % pop old word
        
        
        
    % make sure the length meets a minimum length requirement
    elseif WD_LN > 2
        [MB_WD,New_WD] = pop_WD(MB_WD,New_WD);
 
        
        
    else% if word is small and failed all test throw word out.
        [Trash,New_WD] = pop_WD(Trash,New_WD);

        
    end % END OF IF STATEMENT:
    
end

GD_WD = replaceFlaggedWords(GD_WD,s);

% check if maybe words exist
if isempty(MB_WD) && ~isempty(GD_WD)
    return
end

Loc = 2;





% attempt to decode hidden patterns:
for j = 1:numel(MB_WD)
    
    
    % check if probabily slang
    if numel(MB_WD{j}) < 4 && ~h.CheckSpelling(MB_WD{j})
        Trash(end+1) = MB_WD(j); %#ok
        continue
    end
    
    % decode multi word problems
    Stats = tabulate(double(MB_WD{j}));
    L1 = ismember(double(MB_WD{j}),Stats(Stats(:,3) > 32,1));
    L1 = ~(logical([1 diff(double(MB_WD{j}))])==0 & L1);
    
    if sum(~L1) ~= 0
        ISWORD = h.CheckSpelling(MB_WD{j});
        MB_WD{j} = MB_WD{j}(L1);
        if numel(MB_WD{j}) < 4 && ~ISWORD
            Trash(end+1) = MB_WD(j); %#ok
            continue
        elseif ISWORD && ismember(MB_WD{j},s.True_Words)
            GD_WD(end+1) = MB_WD(j); %#ok
            continue
        end
    end

    
    % check if bad word:
    IDX = char_feature(MB_WD(j),s.Bad_Vec,5,[6,2;10,3],[2,1]);
    if IDX ~= 0
        GD_WD(end+1) = s.BD_WDs(IDX); %#ok
        continue
    end
    
    
    % spell check:
    [T_WD,LOGIC] = spellSuggest(h,MB_WD{j},6,[8,3;10,4],[2,1]);
    
    
    % Word IDX
    if LOGIC && all(ismember(T_WD,s.True_Words))
        L = numel(T_WD);
        GD_WD(end+(1:L)) = T_WD;
    else
        Trash(end+1) = MB_WD(j); %#ok
    end
    
end


if isempty(Trash) || CORRECT,  return, end
Loc = 3;

Slang = Trash;
Trash = cell(0,0);

for j = 1:numel(Slang)
    if numel(unique(double(Slang{j}))) == 2
        if numel(Slang{j}) > 3
            UNC = unique(double(Slang{j}));
            WORD = double(Slang{j});
            LET_2 = UNC(~ismember(UNC,WORD(1)));
            if ~ismember(104,UNC)
                if WORD(1) == WORD(end)
                    Slang{j} = char([WORD(1),LET_2,WORD(1)]);
                else
                    Slang{j} = char([WORD(1),LET_2]);
                end
            elseif xor(ismember(101,UNC),ismember(97,UNC))
                if ismember(101,UNC)
                    Slang(j) =  {'hehe'};
                    GD_WD(end+1) = {'hehe'}; %#ok
                    Loc = 4;
                    continue
                else
                    Slang(j) =  {'haha'};
                    GD_WD(end+1) = {'haha'}; %#ok
                    Loc = 4;
                    continue
                end
            end
        end
    end
    
    [T_WD,I] = strWDRep(Slang(j),s.SlangWords,s.SlangMeaning);
    
    % last possible options:
    if I,Loc = 4;
        GD_WD(end+(1:numel(T_WD))) = T_WD;
        
        
    elseif ismember(Slang(j),{'a','i'})
        GD_WD(end+1) = Slang(j); %#ok
        
        
    elseif ismember(Slang(j),{'ofa'})
        GD_WD(end+(1:2)) = {'of','a'};
        
        
    else
        Trash(end+1) =Slang(j); %#ok
        
    end
end






end


% replace Flag:
function GD_WD = replaceFlaggedWords(GD_WD,s)

% if Starter word was located switch out for fix:
if sum(ismember(GD_WD,s.Starter)) ~= 0
    for j = 1:numel(GD_WD)
        [IXW,IXX] = ismember(GD_WD{j},s.Starter);
        if IXW
            NEW_WORD = strsplit(s.The_Fix{IXX});
            GD_WD(j) = [];
            GD_WD(end + (1:numel(NEW_WORD))) = NEW_WORD;
        end
    end
end

end


function Pass = CheckWord(Good,Trash,Correct)

Pass = false;
if numel(Trash) ~= 1 || ~Correct || numel(Good) == 1
   return 
end

if ismember(Trash,{'ly','ing','ed','er','ie'})
    Pass = true;
end


end


% -------------------------------------------------------------------------
%                         Indexing Sub-Functions
% -------------------------------------------------------------------------

% add to stack:
function New_Word = addToNewWord(Word,Bad_Word,New_Word)


[Start,End] = regexp(Word,Bad_Word);

if End ~= numel(Word)
    New_Word(end+1) = cellstr(Word(End+1:end));
end

if Start ~= 1
    New_Word(end+1) = cellstr(Word(1:Start-1));
end

end



% find key words:
function IDX = FindKeyWordIdx(New_WD,KEY_WD,ERROR)

if ERROR == 1
    for j = 1:numel(KEY_WD)
        if contains(New_WD,KEY_WD{j}), IDX = j;
            break
        end
    end
else
    for j = 1:numel(KEY_WD)
        if contains(New_WD,KEY_WD{j}), IDX = j;
            if ERROR == 1, break, end
            ERROR = ERROR - 1;
        end
    end
end

if IDX == 0
    error('Word Should Have Existed')
end

end


% add good word:
function [GD_WD,New_WD] = pop_WD(GD_WD,New_WD,CELL_WORD)

if nargin == 2
    GD_WD(end+1) = New_WD(1); % add new word to good words
    New_WD(1) = []; % pop element
    
elseif nargin == 3
    L = numel(CELL_WORD);
    GD_WD(end+(1:L)) = CELL_WORD;
    New_WD(1) = [];
end

end


% -------------------------------------------------------------------------
%                        Word Break Down Sub-Functions
% -------------------------------------------------------------------------


% suggest spelling:
function [Cell_Word,LOGIC] = spellSuggest(h,word,S,M,W,TC)

if nargin < 6, TC = 1; end
if ~h.GetSpellingSuggestions(word).count > 0
    LOGIC = false;
    Cell_Word = false;
    return
end



% attempt to obtain correct spelling of word
New_Word = h.GetSpellingSuggestions(word).Item(1).get('name');

% clean result of word
New_Word = regexprep(lower(New_Word),'[^a-z]+','');
New_Word(New_Word == '''') = [];
Cell_Word  = strsplit(New_Word);
New_Word = New_Word(New_Word ~= ' ');

% compare word with additional word
LOGIC = char_feature({word},{New_Word},S,M,W) ~= 0;

% if LOGIC is false return word
if ~LOGIC
    if numel(word) > 5
        if Levenshtein(word,New_Word) <= numel(word)*TC/4.5
            return
        end
    end
end

% Check if new word is a subword of word
if numel(Cell_Word) == 1
    LOGIC = ~contains(word,Cell_Word); 
else
    LOGIC = true;
end

end


% obtain error in data:
function [E,ERROR] = getErrorData(ERROR)

if ~isempty(ERROR)
    E = ERROR(1);
    ERROR(1) = [];
else
    E = 1;
end

end




% -------------------------------------------------------------------------
%                        Alg. Start Up Functions
% -------------------------------------------------------------------------



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


% -------------------------------------------------------------------------
%                          General Functions
% -------------------------------------------------------------------------


function [O1,O2] = Levenshtein(str1,str2)

m=length(str1);
n=length(str2);
O2=zeros(m+1,n+1);
for i=1:1:m
    O2(i+1,1)=i;
end
for j=1:1:n
    O2(1,j+1)=j;
end
for i=1:m
    for j=1:n
        if (str1(i) == str2(j))
            O2(i+1,j+1)=O2(i,j);
        else
            O2(i+1,j+1)=1+min(min(O2(i+1,j),O2(i,j+1)),O2(i,j));
        end
    end
end

O1=O2(m+1,n+1);

end


% sort cell array by length:
function [words,L] = SortByLength(words)

[~,stringLength] = sort(cellfun(@length,words),'descend');
words = words(stringLength);

if nargout== 2
   L = cell2mat(cellfun(@(x) length(x),words,'un',0)); 
end

end


% Print Function
function PrintFUNCTION(word,GD_WD,Trash)
if nargin == 2
    if isempty(GD_WD)
        fprintf(' -> %s',strjoin(word))
    else
        fprintf(' -> %s : %s',strjoin(word),strjoin(GD_WD))
    end
else
    
    if isempty(Trash)
        fprintf('%s -> %s',word,strjoin(GD_WD))
    else
        fprintf('%s -> %s : %s',word,strjoin(GD_WD),strjoin(Trash))
    end
end

end





