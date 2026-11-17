function [GD_WD,s] = debugWord(h,word,w,s)
% Debug word is the first stop on the exciting LDP logical progression.
% the following function attempts to prove or disprove the hypthosis that
% the word is either of the following
% 1. Exists
% 2. Has a Solution in True Words
% 3. is a name.

if ~isfield(w,'iso')
   w.iso = {}; 
end

% word statistics:
s.word   = double(word);   % word in double form
s.numel  = numel(word);    % numel of word
s.unique = unique(s.word); % get unique letters
GD_WD    = {word};         % return information


% check if word is a member of bad words
if ismember({word},[w.bad_words;w.flag'])
    if ismember({word},w.flag')
        GD_WD = repFlagWords({word},w);
        s.flag  = true;
        s.found = true;
        return
    else
        s.badword = true;
        s.found   = true;
        s.return  = {'bad word'};
        return
    end
end


% check if word is smaller than three characters
if s.numel <= 3
    if ismember({word},w.words_bot)
        s.small = true;
        s.found = true;
        return
    else
        [Maybe,I] = strWDRep(word,w.slang,w.meaning);
        if I
            s.found = true;
            s.return = {'slang'};
            GD_WD  =  Maybe;
            return
        else
            s.small = true;
            return
        end
    end
end



% obtain initial checks and tests:
[word,s] = stringBaseCase(h,word,[w.words_bot';w.words_top],s,w.iso);


% if word was a dual word return
if s.dual && s.found
    GD_WD = repFlagWords(s.spell,w);
    return
end


% if word was found
if s.found || s.name
    if ~iscell(word)
        word = cellstr(word);
    end
    
    GD_WD = cellstr(repFlagWords(word,w));
    return
end


if s.T % only able to occur on k == 2
    if s.correct
        s.found = true;
        GD_WD = cellstr(word);
        return
    else
        return
    end
end


% attempt to decode pattern in data
if numel(s.unique) == 2 && s.numel > 4
    s = decodePattern(s);
    if s.decode
        [s.deword,I] = strWDRep(s.deword,w.slang,w.meaning);
        if I
            s.letter = true;
            s.found = true;
            s.return = {'decoded'};
            GD_WD  =  s.deword;
            return
        else
            s.decode = false;
        end
    end
end


if s.Ret_Cor % if all tests have failed return word given you are looking
    if s.correct % to obtain only the correct words
        s.found = true;
        return
    end
end


if s.count
    s.S = 5; s.W = 2;
    s.M = [6,1;8,2;10,3];
    
    if s.dual
        s = checkDualWords(word,s);
        if s.found
            s.return = {'dual, Spell Check'};
            GD_WD = repFlagWords(s.spell,w);
            return
        end
    else
        s = checkSingleWord(word,s);
        if s.found
            s.return = {'single, Spell Check'};
            GD_WD = repFlagWords(s.spell,w);
            return
        end
    end
end

% attempt to build nodes
s = obtainNodes(h,word,s,w);





if s.nodes
    if s.numel > 8 && s.correct && s.k == 1
        del_idx = cell2mat(cellfun(@numel,s.node_tbl(:,2),'un',0)) == 1;
        if all(~del_idx)
            s.nodes = false;
            s.found = true;
            return
        else
            s.node_tbl = s.node_tbl(del_idx,:);
            s.return = {'build nodes'};
            return
        end
    else
        s.return = {'build nodes'};
        return
    end
end


% general check
if s.numel > 2
    [s.deword,I] = strWDRep({word},w.slang,w.meaning);
    
    if I
        s.decode = true;
        s.found  = true;
        s.return = {'decoded'};
        GD_WD    = s.deword;
        return
    end
end


if startsWith(word,w.words_bot)
    for i = 1:numel(w.words_bot)
        if startsWith(word,w.words_bot{i})
            [M,s] = basicCheck(word((numel(w.words_bot{i})+1):end),s,w,h);
            if s.found
                GD_WD = [w.words_bot(i),M];
                GD_WD = checkAndReplaceSlag(GD_WD,w,s);
                return
            end
        end
    end
end

if endsWith(word,w.words_bot)
    for i = 1:numel(w.words_bot)
        if endsWith(word,w.words_bot{i})
            [M,s] = basicCheck(word(1:(end-numel(w.words_bot{i}))),s,w,h);
            if s.found
                GD_WD = [M,w.words_bot(i)];
                GD_WD = checkAndReplaceSlag(GD_WD,w,s);
                return
            end
        end
    end
end



% advanced check:
s.stats = obtain_stats(word);


% decode multi word problems
L1 = ismember(s.word,s.stats.info(s.stats.info(:,3) > 10,1));
L1 = ~(logical([1 diff(s.word)])==0 & L1);
if all(L1), return, end
word = word(L1);
[M,s] = basicCheck(word,s,w,h);

if s.found
    GD_WD = M;
    return
end

if startsWith(word,w.slang)
    
    s.S = 3; s.W = 2;
    s.M = [6,1;8,2;10,3];
    
    for i = 1:numel(w.slang)
        if startsWith(word,w.slang{i})
            [M,s] = basicCheck(word(1:(end-numel(w.slang{i}))),s,w,h);
            if s.found
                [s.deword,I] = strWDRep(s.deword,w.slang,w.meaning);
                if I == 1
                    GD_WD = [s.deword,M];
                    s.letter = true;
                    return
                end
            end
        end
    end
end

if endsWith(word,w.slang)
    
    s.S = 3; s.W = 2;
    s.M = [6,1;8,2;10,3];
    
    for i = 1:numel(w.slang)
        if endsWith(word,w.slang{i})
            [M,s] = basicCheck(word(1:(end-numel(w.slang{i}))),s,w,h);
            if s.found
                [s.deword,I] = strWDRep(s.deword,w.slang,w.meaning);
                if I == 1
                    GD_WD = [M,s.deword];
                    s.letter = true;
                    return
                end
            end
        end
    end
end



end

% check and replace slang
function output = checkAndReplaceSlag(words,w,s)

output = {};

for k = 1:length(words)
    if numel(words{k}) > 3
        output = [output,words(k)]; %#ok
        continue;
    end
    
    if ismember(words(k),w.words_bot)
        s.small = true;
        s.found = true;
        output  = [output,words(k)]; %#ok
        continue;
    else
        [Maybe,I] = strWDRep(words{k},w.slang,w.meaning);
        if I
            output = [Maybe,output]; %#ok
        else
            output = [output,words(k)]; %#ok
        end
    end
end

end

% basic check
function [word,s] = basicCheck(word,s,w,h)

% check if word is a member of bad words
if ismember({word},[w.bad_words;w.flag'])
    if ismember({word},w.flag')
        word = repFlagWords({word},w);
        s.flag  = true;
        s.found = true;
        return
    else
        s.badword = true;
        s.found   = true;
        s.return  = {'bad word'};
        return
    end
    
elseif ismember({word},w.words_top)
    word = repFlagWords({word},w);
    s.found = true;
    return
else
    % check if bad word:
    if numel(word) > 3
        IDX = char_feature({word},w.bad_words,5,[6,2;10,3],[2,1]);
        if IDX ~= 0
            if Levenshtein(word,w.bad_words{IDX}) <= 2
                s.found   = true;
                s.badword = true;
                word = w.bad_words(IDX);
                return
            end
        end
    end
    % Stage I: check if the word is spelled correctly.
    if h.CheckSpelling(word) % word is correct
        s.correct = true;
        s.found   = true;
        return
    end
    
    % if the word does not exist as true word check for spelling
    if h.GetSpellingSuggestions(word).count == 0
        return
    end
    
    s.S = 4; s.W = 2;
    s.M = [6,1;8,2;10,3];
    s.spell = h.GetSpellingSuggestions(word).Item(1).get('name');
    s.spell = lower(s.spell); % lower spelled word
    s.spell(s.spell == '''') = []; % remove
    if ~(sum(s.spell == ' ') == 0) % if a dual words
        return
    else % if single word
        s.spell = regexprep(lower(s.spell),'[^a-z]+',''); % clean word
        s.spell = cellstr(s.spell); % turn spell to cell
        s = checkSingleWord(word,s);
        if s.found
            s.return = {'single, Spell Check'};
            word = repFlagWords(s.spell,w);
            return
        end
    end
    
end

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

% replace Flag for both single word and multi word:
function GD_WD = repFlagWords(GD_WD,s)

% if Starter word was located switch out for fix:
NUM = numel(GD_WD);

if NUM == 1
    [IXW,IXX] = ismember(GD_WD,s.flag);
    if IXW
        GD_WD = strsplit(s.fix{IXX});
        return
    end
else
    if sum(ismember(GD_WD,s.flag)) ~= 0
        for j = 1:NUM
            [IXW,IXX] = ismember(GD_WD{j},s.flag);
            if IXW
                NEW_WORD = strsplit(s.fix{IXX}); GD_WD(j) = [];
                GD_WD(end + (1:numel(NEW_WORD))) = NEW_WORD;
            end
        end
    end
end
end

% add to stack:
function s = obtainNodes(h,word,s,w)

wds = w.words_top; % pull top words
if ~contains(word,wds) % if contains words
    return
end

wds = regexp(word,wds,'match','once');
wds = wds(cell2mat(cellfun(@(x) ~isempty(x),wds,'un',0))~= 0);

L = false(1,numel(wds));
for i = 1:length(L)
    if all(wds{i}(1)==wds{i}) % check if word is not repeated letters
        if ~ismember(wds(i),[w.bad_words;w.flag';w.add_words])
            L(i) = true; % if so delete word
        end
        
    elseif ~h.CheckSpelling(wds{i}) % make sure word is correct
        if h.GetSpellingSuggestions(wds{i}).count == 0
            if ~ismember(wds(i),[w.bad_words;w.flag';w.add_words])
                L(i) = true;
                continue
            end
        elseif ~ismember(wds(i),[w.bad_words;w.flag';w.add_words])
            spl = h.GetSpellingSuggestions(wds{i}).Item(1).get('name');
            if ~(sum(spl == ' ') == 0)
                L(i) = true; % word can not be a dual word
                continue
            end
            
            spl = regexprep(lower(spl),'[^a-z]+',''); % clean word
            spl = cellstr(spl); % turn spell to cell  
            if ismember(spl,wds(i)) % check if word equals corrected word
                continue % if so continue
            else
                L(i) = true;
                continue
            end
        end
    end
end

% if all words have been flagged leave
if all(L) || (sum(~L) == 1 && numel(L) == 2)
    return
else
    s.nodes = true; % nodes have been identified
    s.nodes = true; % nodes are true
end



% pre-prep word spliting
wds = wds(~L); % obtain all correct words
wordcell = cell(numel(wds),1); % setup word cell
wordcell(:) = {word}; % save word in word cell


% split words and obtain pure word
other = regexp(wordcell,wds,'split','once'); % split words
other = cellfun(@(x) x(~ismember(x,{''})),other,'un',0);
wds = cellfun(@(x) x,wds,'un',0);


% A Star Search Next Node Expand Optimization:
NML_WD = numel(wds);
TnE = cell(NML_WD,1);     % flag replaced word
value = zeros(NML_WD,4); % value array
Idx_Vec = 1:NML_WD;

for i = 1:NML_WD
    TnE{i} = repFlagWords(wds(i),w);
    value(i,2) = ~any(contains(wds(Idx_Vec~=i),wds{i}));
    value(i,3) = numel(wds{i});
    
    if numel(other{i}) == 2
        wdlg = [h.CheckSpelling(other{i}{1}),h.CheckSpelling(other{i}{2})];
        if any(wdlg)
            if all(wdlg)
                % ---------------------------------------------------------
                LG_Vec = [numel(other{i}{1}) < 3,numel(other{i}{2}) < 3];
                if any(LG_Vec)
                    
                    % check if word is spelled wrong & less than three
                    LG_Vec = LG_Vec & ~ismember(other{i}(:),w.words_bot)';
                    
                    % if all set the value to -2 and continue
                    if all(LG_Vec)
                        value(i,1) = -2;
                        continue
                    else
                        % check if either one is spelled wrong
                        if xor(LG_Vec(1),LG_Vec(2))
                            if LG_Vec(2)
                                other{i} = other{i}([2,1]);
                                value(i,1) = -1;
                                continue
                            else
                                value(i,1) = -1;
                                continue
                            end
                        end
                    end
                end
                
                % if all tests have been passed sort by length
                if numel(other{i}{1}) > numel(other{i}{2})
                    value(i,1) = 1;
                    other{i} = other{i}([2,1]);
                    continue
                end
                % ---------------------------------------------------------
            else
                % ---------------------------------------------------------
                if numel(other{i}{wdlg}) > 2 % ensure numel > 2 correct
                    if numel(other{i}{~wdlg}) < 3 % check numel of other
                        value(i,1) = -0.5; % other word is not good
                        continue % continue
                    else
                        value(i,1) = 1.25; % other word is good
                        continue % continue
                    end
                else
                    % if numel of element one is less than 2
                    if ~ismember(other{i}{wdlg},w.words_bot)
                        if numel(other{i}{~wdlg}) < 3
                            % if second word is bad assign a high
                            % negative reward
                            value(i,1) = -2;
                            continue
                        else
                            % if second word is good assign a medium
                            % negative reward
                            value(i,1) = -1.5;
                            continue
                        end
                    else
                        % if word passes check if the second word is good
                        if numel(other{i}{~wdlg}) < 3
                            % if not assign a mild negative reward
                            value(i,1) = -1;
                            continue
                        else
                            % if first word is good assign a small positive
                            % reward
                            value(i,1) = 0.1;
                            continue
                        end
                    end
                    % -----------------------------------------------------
                end
            end
        else
            % -------------------------------------------------------------
            % if none of the words have been recorded as true
            % sort words based on the number of elements
            if numel(other{i}{1}) > numel(other{i}{2})
                other{i} = other{i}([2,1]);
            end
            
            if numel(other{i}{2}) < 3 % if larger element is less than 3
                value(i,1) = -2;   % a negative 2 will be rewarded
                continue
            elseif numel(other{i}{1}) < 3 % if only element one is less
                value(i,1) = -1.2; % than three set a medium neg. reward
                continue
            elseif numel(other{i}{2}) > 4
                value(i,1) = .25; 
                continue
            else
                value(i,1) = 0; % both words are decent set as -1
                continue
            end
        end
        % -----------------------------------------------------------------
    else
        % -----------------------------------------------------------------
        % if only one word was obtained in node expansion
        if h.CheckSpelling(other{i}{1}) % check for spelling
            if numel(other{i}{1}) < 3 % if word is less than three
                if ~ismember(other{i}{1},w.words_bot) % check spelling
                    value(i,1) = -1; % if spelling is no good
                    continue         % continue
                end
            else
                value(i,1) = 1; % set a positive reward
                continue        % continue
            end
        else
            if numel(other{i}{1}) < 3 % if spelling is wrong and less than
                value(i,1) = -1;      % three set a negative reward
                continue
            end
        end
        %------------------------------------------------------------------
    end
end


s.node_tbl = [wds,other,TnE];

value(:,4) = and(value(:,3) > 5,value(:,1) >= 0);

[~,idx] = sortrows(value,[2 4 1 3],'descend');
s.node_tbl = s.node_tbl(idx,:);

end

% obtain statistics on word:
function s = obtain_stats(word)

Stats = tabulate(double(word));
s.info   = Stats(Stats(:,2) ~=0,:);

end

% decode pattern
function s = decodePattern(s)



LET_2 = s.unique(~ismember(s.unique,s.word(1)));


I = ismember([101,97,104],s.unique);
if xor(I(1),I(2)) && I(3)
    if ismember(101,s.unique)
        s.deword = 'hehe';
        s.decode = true;
        return
    else
        s.deword = 'haha';
        s.decode = true;
        return
    end
else
    if s.word(1) == s.word(end)
        s.deword = char([s.word(1),LET_2,s.word(1)]);
        s.decode = true;
        return
    else
        s.deword = char([s.word(1),LET_2]);
        s.decode = true;
        return
    end
end


end

% basic spell check
function [word,s] = stringBaseCase(h,word,True_Words,s,ISO_Words)



% Stage I: check if the word is spelled correctly.
s.correct = h.CheckSpelling(word); % word is correct
if ismember({word},{'wtf'})
   s.correct = false; 
end

if ~s.correct % if the word does not exist as true word check for spelling
    s.count = h.GetSpellingSuggestions(word).count ~= 0;
end


% Stage II: Check if word is indeed correct or is name
% if spelling is incorrect then count can be true if correct word exists
if s.count % attempt to obtain correct spelling of word
    s.spell = h.GetSpellingSuggestions(word).Item(1).get('name');
    s.spell = lower(s.spell); % lower spelled word
    
    if ~(sum(s.spell == ' ') == 0) % if a dual words
        
        % setup word:
        s.spell = strsplit(s.spell); % split words
        s.spell = cellfun(@(x) regexprep(x,'[^a-z]+',''),s.spell,'un',0);
        s.dual  = true;
        
        % word spell check:
        s.S = 3; s.W = 2; s.M = [6,1;8,2;10,3];
        s = checkDualWords(word,s);
        
        if s.found
            s.return = {'Dual, Spell Check'};
            return
        end
        
    else % else if a single word
        s.spell = regexprep(s.spell,'[^a-z]+',''); % clean word
        s.spell = cellstr(s.spell); % turn spell to cell
        
        % check if the original word is equal to bad word
        if ismember(s.spell,{word})
            if isstrprop(s.spell{1}(1),'upper')
                s.name  = true;
            else
                s.correct = true;
            end
        end
    end
end


% check if word exists as a true word.
if ismember({word},True_Words) % if it does return
    % obtain return type of three cases
    if s.name, s.return = {'Name, Member'};
    elseif s.correct, s.return = {'Correct, Member'};
    else, s.return = {'Member'};
    end,  s.found  = true; s.member = true;
    return
end


if s.correct
    if s.Ret_Cor
        return % if word found
    end
end



% Stage III: Correct Word
if s.numel < 5
    return
end


% begin testing:
s.tested = true;


% s and es check:
if endsWith(word,'s')
    if ismember({word(1:end-1)},True_Words)
        word = word(1:end-1);
        s.found = true; % found as s
        s.return = {'Tested, s'};
        return
        
    elseif endsWith(word,'es')
        if ismember({word(1:end-2)},True_Words)
            word = word(1:end-2);
            s.found = true; % found as es
            s.return = {'Tested, es'};
            return
            
        end
    elseif endsWith(word,'ies')
        if ismember({[word(1:end-3),'y']},True_Words)
            word = [word(1:end-3),'y'];
            s.found = true; % found as es
            s.return = {'Tested, es'};
            return
            
        end
    end
    
elseif endsWith(word,'ed')
    if ismember({word(1:end-2)},True_Words)
        word = word(1:end-2);
        s.found = true;
        s.return = {'Tested, ed'};
        return
        
    else % check if ends in d
        if ismember({word(1:end-1)},True_Words)
            word = word(1:end-1);
            s.found = true; % found as d
            s.return = {'Tested, d'};
            return
        end
    end
    
elseif endsWith(word,'ish')
    if ismember({word(1:end-3)},True_Words)
        word = word(1:end-3);
        s.found = true; % found as ing
        s.return = {'Tested, ish'};
        return
    end
    
elseif endsWith(word,'ing')
    if ismember({word(1:end-3)},True_Words)
        word = word(1:end-3);
        s.found = true; % found as ing
        s.return = {'Tested, ing'};
        return
    end

elseif endsWith(word,'ness')
    if endsWith(word,'edness')
        if ismember({word(1:end-6)},True_Words)
            word = word(1:end-6);
            s.found = true; % with ility
            s.return = {'Tested, edness'};
            return
            
        elseif ismember({word(1:end-5)},True_Words)
            word = word(1:end-5);
            s.found = true; % with ility
            s.return = {'Tested, dness'};
            return
        end
    else
        if ismember({word(1:end-4)},True_Words)
            word = word(1:end-4);
            s.found = true; % with ility
            s.return = {'Tested, ness'};
            return
        end
    end
    
elseif endsWith(word,'y')
    if endsWith(word,'ility')
        if ismember({[word(1:end-5),'le']},True_Words)
            word = [word(1:end-5),'le'];
            s.found = true; % with ility
            s.return = {'Tested, ility'};
            return
        end
        
    elseif endsWith(word,'ically')
        if ismember({word(1:end-4)},True_Words)
            word = word(1:end-4);
            s.found = true; % with ility
            s.return = {'Tested, ally'};
            return
        end
        
    elseif endsWith(word,'ely')
        if ismember({word(1:end-2)},True_Words)
            word = word(1:end-2);
            s.found = true; % found as ing
            s.return = {'Tested, ly'};
            return
        end

    elseif endsWith(word,'ly')
        if ismember({word(1:end-2)},True_Words)
            word = word(1:end-2);
            s.found = true; % with ility
            s.return = {'Tested, ally'};
            return
        end
        
    elseif endsWith(word,'ingly')
        if ismember({word(1:end-5)},True_Words)
            word = word(1:end-5);
            s.found = true; % with ility
            s.return = {'Tested, ally'};
            return
        end
    end
end


[wd_mby,Exists] = thesaurus_sym(word);
if Exists
    if s.theor
        I = ismember(wd_mby,[True_Words;ISO_Words]);
    else
        I = ismember(wd_mby,True_Words);
    end
    
    if any(I)
        wd_mby = wd_mby(I);
        fprintf('%s -> %s \n',word,wd_mby{1});
        word = wd_mby{1};
        s.found = true; % with ility
        s.return = {'obtained, thesaurus'};
    else
        
        wd_mby = cellfun(@(x) CleanWordEndings(x),wd_mby,'un',0);
        if s.theor
            I = ismember(wd_mby,[True_Words;ISO_Words]);
        else
            I = ismember(wd_mby,True_Words);
        end
        
        if any(I)
            wd_mby = wd_mby(I);
            fprintf('%s -> %s \n',word,wd_mby{1});
            word = wd_mby{1};
            s.found = true; % with ility
            s.return = {'obtained, thesaurus'};
        end
        
    end
end
end

% clean word ending
function word = CleanWordEndings(word)

% s and es check:
if endsWith(word,'ies')
    word = [word(1:end-3),'y'];
elseif endsWith(word,'ness')
    word = word(1:end-4);
elseif  endsWith(word,'es')
    word = word(1:end-2);
elseif endsWith(word,'s')
    word = word(1:end-2);
elseif endsWith(word,'ish')
    word = word(1:end-3);
elseif endsWith(word,'ed')
    word = word(1:end-2);
elseif endsWith(word,'ing')
    word = word(1:end-3);
elseif endsWith(word,'ility')
    word = [word(1:end-5),'le'];
elseif endsWith(word,'ist')
    word = [word(1:end-3),'ary'];
elseif endsWith(word,'ary')
    word = [word(1:end-3),'ist'];
end


end

% check if word is a dual word:
function s = checkSingleWord(word,s)
% compare word with additional word


% set up inital information
str = char(s.spell); % obtain found spell check word
dual_length = numel(str); % length of spell check word
Lev = 4.25; % Levenshtein Theshold
Lev_special = 6.5; % Levenshtein Theshold

% word comparing logic:
L1 = char_feature({word},{str},s.S,s.M,s.W);
LVL_1 = Levenshtein(word,str);



% Word Logic:
if L1 == 1 && (LVL_1 <= ceil(dual_length/Lev))
    s.found = true;
    if str(1) ~= word(1)
        s.letter = true;
    end
elseif LVL_1 <= ceil(dual_length/Lev_special)
    s.found = true;
    if str(1) ~= word(1)
        s.letter = true;
    end
end


end

% check if word is a dual word:
function s = checkDualWords(word,s)

% compare word with additional word
if numel(s.spell) == 2
    str_1 = strjoin(s.spell([1,2]),'');
    str_2 = strjoin(s.spell([2,1]),'');
else
    return
end


dual_len = numel(str_1);

% word comparing logic:
L1 = char_feature({word},{str_1},s.S,s.M,s.W);
L2 = char_feature({word},{str_2},s.S,s.M,s.W);
LVL_1 = Levenshtein(word,str_1);
LVL_2 = Levenshtein(word,str_2);
LV_1 = LVL_1 <= ceil(dual_len/6);
LV_2 = LVL_2 <= ceil(dual_len/6);



% Word Logic:
if (L1 == 1 && LV_1) || (LV_2 && L2 == 1)
    s.found = true;
    
elseif L1 == 1 && L2 == 0 && LV_1
    s.found = true;
    
elseif L1 == 0 && L2 == 1 && LV_2
    s.found = true;
    
elseif LVL_1 < ceil(dual_len/7) || LVL_2 < ceil(dual_len/12)
    s.found = true;
    
end


end

% compare to levensthtein:
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

