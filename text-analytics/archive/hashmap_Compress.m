function tbl = hashmap_Compress(hashmap,Thresh)


% process inputs:
if nargin == 1, Thresh = 25; end

% preprocesses data:
bd_wd = obtain_badwords(); % obtain bad words
tbl_fzs = obtain_hashmap_fz_tbl(hashmap); % obtain hashmap fz table
tbl = tbl_fzs(tbl_fzs.freq < Thresh,:);
PBW = tbl{:,'words'};
FrQ = tbl{:,'freq'};
PBW = PBW(~ismember(PBW,bd_wd));

% - Launch MS Word and create document.
h = actxserver( 'word.application' );
h.Document.Add;


% obtain initial condition data:
V = char_feature(bd_wd,[2,1]);
V_logic = V ~= 0;
Double_Check = {'homo','ass'};
OL = cell(0,2);




% first pass
for i = 1:length(PBW)
    
    if h.CheckSpelling(PBW{i}) && FrQ(i) > 9
        continue
    end
    
    % check if may be miss-classified
    if startsWith(PBW{i},Double_Check)
        [WD,L] = checkWordFun(PBW{i},h);
        if L == 1, continue, elseif L == 2, OL(end+1,:) = WD; end %#ok
    end
    
    % obtain number vector:
    num_vec = char_feature(PBW(i),[2,1]);
    Word_Correct_Logic = abs(sum(abs((num_vec ~= 0) - V_logic),2));
    Word_Correct = abs(sum(abs(V - num_vec),2));
    
    [MLV,ML_I] = min(Word_Correct);
    [WCV,MC_I] = min(Word_Correct_Logic);
    
    Words_Per_Letter = sum(num_vec)/sum(Word_Correct_Logic); %#ok
    if MLV + WCV < 7 && isequal(bd_wd{ML_I},bd_wd{MC_I})
        OL(end+1,:) = [PBW(i),{bd_wd(ML_I)}]; %#ok
        continue
    end
    
    if startsWith(PBW{i},'ass'), M = 5; else, M = 3; end
    for j= 1:length(bd_wd)
        if ~startsWith(PBW{i},bd_wd{j}), continue, end
        if length(bd_wd{j}) < M && ~strcmpi(bd_wd{j},'cunt'), break, end
        M = 1;
        word_2 = cellstr(PBW{i}(length(bd_wd{j})+1:end));
        
        if h.CheckSpelling(char(word_2)) && length(word_2) > 1
            OL(end+1,:) = [PBW(i),{[bd_wd(j),word_2]}]; %#ok
            fprintf('Trim: %s -> %s & %s \n',PBW{i},bd_wd{j})
            break
        else
            OL(end+1,:) = [PBW(i),{bd_wd(j)}]; %#ok
            fprintf('Trim: %s -> %s \n',PBW{i},bd_wd{j})
            break
        end
    end
    
    if M ~= 1
        fprintf('Unable To Find: %s \n',PBW{i})
    end
end


h.Quit % - Quit MS Word.
[~,idx_shift] = ismember(OL(:,1),tbl.words);
tbl = tbl(idx_shift,:);
tbl{ismember(tbl.words,OL(:,1)),'fixed_sol'} = OL(:,2);


end


% check word logic:
function [WD,L] = checkWordFun(WD,h)
% L = 0: no results found
% L = 1: spelling was correct
% L = 2: word was replaced

L = 0;
if h.CheckSpelling(WD),L = 1; return, end
if ~h.GetSpellingSuggestions(WD).count > 0, return, end
newWord = strsplit(h.GetSpellingSuggestions(WD).Item(1).get('name'));
newWord = regexprep(lower(newWord),'[^a-z]+','');
newWord = newWord(~ismember(newWord,{''}));
TWD = strjoin(newWord);
try
    new_vec = char_feature({TWD},[3,2]);
    old_vec = char_feature({WD},[3,2]);
catch
    return
end

MLV = abs(sum(abs((old_vec ~= 0) - (new_vec ~= 0)),2));
WCV = abs(sum(abs(new_vec - old_vec),2));

if isequal(WD,TWD)
    L = 1;
elseif MLV + WCV < 5
    fprintf('\nFound Word: %s -> %s ',WD,strjoin(newWord))
    WD = [cellstr(WD),{newWord}];
    L = 2;
end


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

