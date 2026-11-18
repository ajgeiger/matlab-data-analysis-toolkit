classdef WordDecoder
    % Decode Documents
    % strWDRep -> wordReplace
    %
    % Data Structures In S should be tables...
    % flag goes with fix
    % slang goes with meaning
    
    % Properties list
    properties
        s;
        h;
        d; % dual word logic info
        returnCorrect     = true;
        tenseProcess      = true;
        thesaurusProcess  = true;
        patternProcess    = true;
        startsWithProcess = true;
        endsWithProcess   = true;
        smallWordLock     = true;
        verbose           = true;
    end
     
    % General Methods
    methods
        
        % Constructor
        function obj = WordDecoder()
            
            % setup table info
            x = load('text_structure.mat','-mat','s');
            obj.s = x.s;
            obj.h = actxserver('word.application');
            obj.h.Document.Add;
            obj = setupDualDecoder(obj);
            
        end
        
        % Turn off document:
        function obj = turnOffDocument(obj)
            obj.h.Document.Quit;
        end
        
        % Turn on document
        function obj = turnOnDocument(obj)
            obj.h = actxserver('word.application');
            obj.h.Document.Add;
        end
        
        % word decoder in house...
        function p = wordDecoder(obj,word,p,k)
            
            if nargin < 3, p = getDefaults(); end
            if nargin > 3, p.k = k;           end
            
            % word statistics:
            p.word   = double(word);   % word in double form
            p.numel  = numel(word);    % numel of word
            p.unique = unique(p.word); % get unique letters
            p.target = {word};         % return information
            
            
            if p.numel < 3
                if p.numel == 1, p.letter = true; end
                if ismember({word},[obj.s.words_bot])
                    p.found   = true;
                    p.small   = true;
                    p.correct = true;
                    return 
                elseif p.numel == 1
                    p.letter  = true;
                    p.found   = true;
                    p.small   = true;
                    p.correct = false;
                end
            end
            
            
            % verify if word is a bad word
            p = obj.verifyBadWord(word,p);
            if p.found, return, end
            
            p = obj.slangReplace(word,3,p);
            if p.found,  return, end
            
            % obtain initial checks and tests:
            p.target = obj.flagReplace(word);
            if p.found,  return, end
            
            % String Base Case
            p = obj.stringBaseCase(word,p);
            
            % if word was a dual word return
            if p.dual && p.found
                p.target = obj.flagReplace(p.spell);
                return
                
            % else if word is a name or found  
            elseif p.found || p.name
                p.target = cellstr(obj.flagReplace(cellstr(word)));
                return
                
            % if word is small... only able to occur on k == 2
            elseif p.T 
                if p.correct, p.found  = true; end
                p.target = cellstr(word);
                return
            end
            
            
            % attempt to decode pattern in data
            if numel(p.unique) == 2 && p.numel > 4
                
                % decode pattern
                p = obj.decodePattern(p);
                
                if p.found && p.correct
                   return 
                end
                
                % if word has been decoded
                if p.decode
                    
                    % verify if word is slang
                    p = obj.slangReplace(p.target,3,p);
                    if p.slang, return, end
                    if ismember(p.target,obj.s.words_bot) || p.numel > 5
                       p.found = true;
                       p.small = true;
                       return
                    end
                end
            end
            
            % in the off change correct word exists return
            if p.correct, p.found = true; return, end
            
            % Correct spelling if present
            if p.count > 0
                
                % check for dual word
                if numel(p.spell) == 2
                    p = obj.checkDualWords(word,p);
                    
                    % found double word
                    if p.found
                        p.return = {'dual, Spell Check'};
                        p.target = obj.flagReplace(p.spell);
                        return
                    end
                    
                % check single spelling
                elseif numel(p.spell) == 1
                    p = obj.checkSingleWord(word,p);
                     
                    % Found in single word
                    if p.found
                        p.return = {'single, Spell Check'};
                        p.target = obj.flagReplace(p.spell);
                        return
                    end
                end
            end
            
            % build nodes
            p = obj.buildNodes(word,p);
            
            if p.found, return, end
            
            % general check
            if p.numel > 2
                
                % check for slang
                p = obj.slangReplace(word,[],p);
                if p.found, return, end
                
            end

            % replace if starts with
            p = obj.startReplace(word,p,obj.s.words_bot);
            if p.found, return, end
            
            
            % end of word replaced
            p = obj.endReplace(word,p,obj.s.words_bot);
            if p.found, return, end
        
            % advanced check:
            p.stats = obtain_stats(word);
            
            % decode multi word problems
            L1 = ismember(p.word,p.stats.info(p.stats.info(:,3) > 10,1));
            L1 = ~(logical([1 diff(p.word)])==0 & L1);
            if all(L1), return, end
            
            % clean word of repeated 3+ characters
            word = word(L1);
            p = obj.basicCheck(word,p);
            if p.found
                p = obj.slangReplace(p.target,[],p);
                return
            end

            % Check for slang the last ditch effor...
            p = startReplace(obj,word,p,obj.s.database.slang,true);
            if p.found, return, end
            
            p = endReplace(obj,word,p,obj.s.database.slang,true);
            
        end
        
        % decode word
        function [Word,Cells,Score] = enhance(obj,Word,package)
            
            B = getDefaults();
            
            % Word Base
            B.packageBA = package;
            base.info = cell(0,2);
            base.s  = [];
            base.p  = [];
            base.id = 0;
            base.k  = 0;
            
            % Meta Data Info
            Cells = {}; % unknown ***
            Score = 0; % current highest score
            nodes = {{},{Word},{},{},{},{},{},{}}; % nodes for expansion
            past  = cell(0,0); % unknown ***
            
            if obj.smallWordLock
                if numel(Word) < 5
                    base.k = 1;
                    p = obj.wordDecoder(Word,B,base.k);
                    new_word = strjoin(p.target);
                    if ~isempty(p.spell)
                       if strcmpi(strjoin(p.spell),new_word)
                           return
                       else
                           Word = new_word;
                           return
                       end
                    else
                        Word = new_word;
                        return
                    end
                end
            end
            
            while 1, base.k = base.k + 1;
                
                % annealing coefficent
                anneal = .05.*(1 - (1/base.k));
                
                % basic logical arguments to continue or quit
                NUM_V = numel(nodes{1,2});
                if base.k > 400, Score = numel(Word); return, end
                if NUM_V == 0, node = nodes(1,:); break, end
                
                % pop the item of the first expandable node
                [nodes,word] = get_word_update_nodes(obj,nodes,NUM_V);
                
                % processes word.
                if isfield(base.p,word)
                    p = base.p.(word);
                else
                    p = obj.wordDecoder(word,B,base.k);
                    base.p.(word) = p;
                end
                
                
                % Check if word was correct
                if base.k == 1, if p.correct,  B.T = true; end, end
                
                % if word is found with nodes.
                if p.nodes
                    [nodes,past,base] = pushNodes(nodes,base,p.node_tbl,past);
                    continue
                    
                % if word has been decoded
                elseif p.decode
                    
                    % if word is found then return findings
                    if base.k == 1, Word = strjoin(p.target); return,  end
                    
                    % else we are in for the long hall
                    base = addToBase(base,{word,[],p.target},1);
                    Data = getBase(base,{word});
                    nodes{1,1}(end+1) = Data{1,1};
                    nodes{1,3}(end+1) = Data{1,1};
                    nodes{1,5}(end+1) = Data{1,1};
                    continue 
                
                elseif p.letter
                    
                    % if word has been decoded
                    if base.k == 1, Word = strjoin(p.target); return,  end

                    base = addToBase(base,{word,[],p.target},4);
                    Data = getBase(base,{word});
                    nodes{1,1}(end+1) = Data{1,1};
                    nodes{1,3}(end+1) = Data{1,1};
                    nodes{1,4}(end+1) = Data{1,1};
                    nodes{1,8} = nodes{1,8} + .05 + anneal;
                    nodes = sortCells(nodes,8);
                    
                    if ~p.correct, nodes{1,8} = nodes{1,8} + .2; end

                % if word was found this could be a lot of things
                elseif p.found
                    
                    % if word has been decoded
                    if base.k == 1, Word = strjoin(p.target); return,  end

                    base = addToBase(base,{word,[],p.target},2);
                    Data = getBase(base,{word});
                    nodes{1,1}(end+1) = Data{1,1};
                    nodes{1,3}(end+1) = Data{1,1};
                    nodes{1,4}(end+1) = Data{1,1};
                    if ~p.correct
                        nodes{1,8} = nodes{1,8} + .3 + anneal;
                        nodes = sortCells(nodes,8);
                    end
                    continue
                else % if word is trash
                    if base.k == 1, Score = numel(Word); return, end
                    base = addToBase(base,{word,[],p.target},3);
                    Data = getBase(base,{word});
                    nodes{1,3}(end+1) = Data{1,1};
                    nodes{1,7}(end+1) = Data{1,1};
                    nodes{1,8} = nodes{1,8} + numel(word);
                    nodes = sortCells(nodes,8);
                    continue
                end
                
            end
            
            
            % The following Code rebuilds the word
            % ------------------------------------
            
            
            % Score Returned object
            [Original,idx] = SortByLength(base.info(node{1},2));

            Score = numel(Word);
            for i = 1:numel(Original)
                Score = Score - numel(Original{i});
            end
            
            NUM = numel(idx);
            node{1} = node{1}(idx);
            IDEVC = zeros(1,NUM);
            IDL = 1:numel(Word);

            for i = 1:NUM
                [Start,End] = regexp(Word,Original{i},'once');
                try
                    if numel(Word) == End && Start == 1
                        IDEVC(i) = IDL(1);
                        break

                    elseif numel(Word) == End
                        Word = Word(1:Start-1);
                        IDEVC(i) = IDL(Start);
                        IDL = IDL(1:Start-1);


                    elseif Start == 1
                        Word = Word(End+1:end);
                        IDEVC(i) = IDL(1);
                        IDL = IDL(End+1:end);
                    else
                        Word = Word([1:Start-1,End+1:end]);
                        IDEVC(i) = IDL(Start);
                        IDL = IDL([1:Start-1,End+1:end]);
                    end
                catch
                    Word  = {};
                end
            end

            [~,idx] = sort(IDEVC);
            node{1} = node{1}(idx);

            Cells = [base.info{node{1}}];
            Word = strjoin(Cells);
            
            
            
            
        end
        
        % reset database
        function obj = resetDatabase(obj)
            
            obj.s.database.flag  = obj.s.flags.id;
            obj.s.database.slang = obj.s.slangs.id;
            
        end
        
        % function printout
        function searchDatabase(obj,word)
            
            disp('Word Location Listings:')
            
            
            if ismember({word},obj.s.database.skip)
                disp('skip words cell array')
            end
            
            if ismember({word},obj.s.words_bot)
                disp('bottom words cell array')
            end
            
            
            if ismember({word},obj.s.words_top)
                disp('top words cell array')
            end
            
            if ismember({word},obj.s.database.bad_words)
                disp('bad words cell array')
            end
            
            if ismember({word},obj.s.database.add_words)
                disp('add words cell array')
            end
            
            if ismember({word},fieldnames(obj.s.politics))
                disp('politics map')
            end
            
            if ismember({word},obj.s.hardSlang.id)
                disp('had slang table')
            end
            
            if ismember({word},fieldnames(obj.s.all_states))
                disp('all states state abv cell array')
            end
            
            if ismember({word},fieldnames(obj.s.all_states))
                disp('all states map')
            end
            
            disp(' ')
            
            
            
        end
        
    end
    
    % search method functions
    methods
        
        
        % extract previously found word data to update node
        function nodes = extraction_update(obj,nodes,base)
             % check if word case has already been found
             %  if any(isfield(base.s,nodes{1,2}))
             %      nodes = extraction_update(obj,nodes,base);
             %      continue
             %  end
            
            old_word_idx = isfield(base.s,nodes{1,2});
            old_word = nodes{1,2}(old_word_idx);
            nodes{1,2} = nodes{1,2}(~old_word_idx);

            % obtain old word idx
            for i = 1:numel(old_word)
                vector = base.s.(old_word{i});
                nodes = fill_Node(nodes,vector,old_word{i});
            end
            
            if obj.verbose
                fprintf('%s word previously identified \n',old_word)
            end
        end
        
        function [nodes,word] = get_word_update_nodes(obj,nodes,NUM_V)
           
            % pop the item of the first expandable node
            word = nodes{1,2}{1};
                
            % remove the poped item from list
            if NUM_V == 1, nodes{1,2} = {};
            else, nodes{1,2} = nodes{1,2}(2:end);
            end
            
            if obj.verbose
                % fprintf('extracted word: %s \n',word)
            end
            
        end
    end

    % start and end replacement methods
    methods
        % word ending replaced
        function p = endReplace(obj,word,p,space,rs)
            
            if nargin < 5, rs = true; end % replace sland
            if ~obj.endsWithProcess, return, end
            
            
            % Check what the word ends with
            if endsWith(word,space)
                for i = 1:numel(space)
                    if endsWith(word,space{i})
                        p = obj.basicCheck(word(1:(end-numel(space{i}))),p);
                        if p.found
                            if rs, p = obj.slangReplace(p.target,[],p); end
                            p.target = [p.target,space(i)];
                            return
                        end
                    end
                end
            end
            
        end
        
        % start of word replaced
        function  p = startReplace(obj,word,p,space,rs)
            
            if nargin < 5, rs = false; end % replace slang logic
            if ~obj.startsWithProcess, return, end 
           
            % Check what the word starts with
            if startsWith(word,space)
                for i = 1:numel(space)
                    if startsWith(word,space{i})
                        p = obj.basicCheck(word((numel(space{i})+1):end),p);
                        if p.found
                            if rs, p = obj.slangReplace(p.target,[],p); end
                            p.target = [space(i),p.target];
                            return
                        end
                    end
                end
            end
            
        end
        
    end
    
    % high level tools
    methods
        
        % attempt to replace slang.
        function p = slangReplace(obj,words,thresh,p)
            % thresh maximum size of word to replace.
            
            words = cellstr(words);
            if nargin < 3, thresh = []; end
            
            p.slang = false;
            p.small = false;
            p.found = false;
            
            % setup output words cell array...
            WORDS = {};

            % loop through length of list...
            for k = 1:length(words)
                
                if ~isempty(thresh)
                    if numel(words{k}) > thresh
                        WORDS = [WORDS,words(k)]; %#ok
                        continue;
                    end
                end

                if ismember(words(k),obj.s.words_bot)
                    p.small = true;
                    p.slang = false;
                    WORDS  = [WORDS,words(k)]; %#ok
                    continue;
                else
                    [Maybe,I] = obj.wordReplace(words{k});
                    if I
                        p.small = false;
                        p.slang = true;
                        p.found = true;
                        p.correct = true;
                        WORDS = [WORDS,Maybe]; %#ok
                    else
                        WORDS = [WORDS,words(k)]; %#ok
                    end
                end
            end
            
            p.target = WORDS;
            
        end
        
        % verify bad word
        function p = verifyBadWord(obj,word,p)
           
            word = cellstr(word);
           
            % check if word is a member of bad words
            if ismember(word,obj.s.database.flag)
                p.target = obj.flagReplace(word);
                p.flag    = true;
                p.found   = true;
                p.flagfix = true;
                return
            elseif ismember(word,obj.s.database.bad_words)
                p.badword = true;
                p.found   = true;
                p.flagfix = false;
                p.target  = word;
                p.return  = {'bad word'};
            end
        end
        
        % baseline correction
        function p = stringBaseCase(obj,word,p)
            
            % setup p structure if not define
            if nargin < 3
                p.correct = false;
                p.numel   = numel(p);
            end
            
            % perform spell check and count
            p = spellCheck(obj,word,p);

            % spell correct
            p = spellCorrect(obj,word,p);
            
            % return if word found and allowed to be.
            if p.correct, if obj.returnCorrect, return, end, end
            
            % check if word exists as a true word.
            p = obj.commonWordCheck(word,p);
            
            % return if word found and allowed to be.
            if p.correct, if obj.returnCorrect, return, end, end
            
            % begin testing:
            p.tested = true;

            % lookup word in the thesaurus 
            p.target = cellstr(obj.thesaurusLookup(word,p));
           
        end
        
    end
    
    % low level tools
    methods
        
        % replace Flag for both single word and multi word:
        function words = flagReplace(obj,words)

            % if Starter word was located switch out for fix
            words = cellstr(words);
            
            % get index of word
            IXW = ismember(words,obj.s.database.flag);
            
            % check if any words are present if not return
            if ~any(IXW), return,  end
            
            % isolate known words
            wds = words(IXW);
            wds = obj.s.flags{wds,'replace'};
            
            % replace old words with new words
            words(IXW) = wds;
            words = cleanup_string(words);
            words = strsplit(words);
            
        end
        
        % replace tenths
        function word = replaceTense(obj,word,p)
            
            if ~obj.tenseProcess, return; end
           
            % obtain true words
            True_Words = getTrueWords(obj);
            
            % s and es check:
            if endsWith(word,'s')
                if ismember({word(1:end-1)},True_Words)
                    word = word(1:end-1);
                    p.found = true; % found as s
                    p.return = {'Tested, s'};
                    return

                elseif endsWith(word,'es')
                    if ismember({word(1:end-2)},True_Words)
                        word = word(1:end-2);
                        p.found = true; % found as es
                        p.return = {'Tested, es'};
                        return

                    end
                elseif endsWith(word,'ies')
                    if ismember({[word(1:end-3),'y']},True_Words)
                        word = [word(1:end-3),'y'];
                        p.found = true; % found as es
                        p.return = {'Tested, es'};
                        return

                    end
                end

            elseif endsWith(word,'ed')
                if ismember({word(1:end-2)},True_Words)
                    word = word(1:end-2);
                    p.found = true;
                    p.return = {'Tested, ed'};
                    return

                else % check if ends in d
                    if ismember({word(1:end-1)},True_Words)
                        word = word(1:end-1);
                        p.found = true; % found as d
                        p.return = {'Tested, d'};
                        return
                    end
                end

            elseif endsWith(word,'ish')
                if ismember({word(1:end-3)},True_Words)
                    word = word(1:end-3);
                    p.found = true; % found as ing
                    p.return = {'Tested, ish'};
                    return
                end

            elseif endsWith(word,'ing')
                if ismember({word(1:end-3)},True_Words)
                    word = word(1:end-3);
                    p.found = true; % found as ing
                    p.return = {'Tested, ing'};
                    return
                end

            elseif endsWith(word,'ness')
                if endsWith(word,'edness')
                    if ismember({word(1:end-6)},True_Words)
                        word = word(1:end-6);
                        p.found = true; % with ility
                        p.return = {'Tested, edness'};
                        return

                    elseif ismember({word(1:end-5)},True_Words)
                        word = word(1:end-5);
                        p.found = true; % with ility
                        p.return = {'Tested, dness'};
                        return
                    end
                else
                    if ismember({word(1:end-4)},True_Words)
                        word = word(1:end-4);
                        p.found = true; % with ility
                        p.return = {'Tested, ness'};
                        return
                    end
                end

            elseif endsWith(word,'y')
                if endsWith(word,'ility')
                    if ismember({[word(1:end-5),'le']},True_Words)
                        word = [word(1:end-5),'le'];
                        p.found = true; % with ility
                        p.return = {'Tested, ility'};
                        return
                    end

                elseif endsWith(word,'ically')
                    if ismember({word(1:end-4)},True_Words)
                        word = word(1:end-4);
                        p.found = true; % with ility
                        p.return = {'Tested, ally'};
                        return
                    end

                elseif endsWith(word,'ely')
                    if ismember({word(1:end-2)},True_Words)
                        word = word(1:end-2);
                        p.found = true; % found as ing
                        p.return = {'Tested, ly'};
                        return
                    end

                elseif endsWith(word,'ly')
                    if ismember({word(1:end-2)},True_Words)
                        word = word(1:end-2);
                        p.found = true; % with ility
                        p.return = {'Tested, ally'};
                        return
                    end

                elseif endsWith(word,'ingly')
                    if ismember({word(1:end-5)},True_Words)
                        word = word(1:end-5);
                        p.found = true; % with ility
                        p.return = {'Tested, ally'};
                        return
                    end
                end
            end
            
        end
        
        % lookup values in a thesaurus
        function [word,p] = thesaurusLookup(obj,word,p)
            
            % check if processes is allowed
            if ~obj.thesaurusProcess, return; end

            [wd_mby,Exists] = searchThesaurus(word);
            if Exists
                wd_mby = wd_mby(ismember(wd_mby,getTrueWords(obj)));
                if ~isempty(wd_mby)
                    fprintf('%s -> %s \n',word,wd_mby{1});
                    word = wd_mby{1};
                    p.found = true; % with ility
                    p.return = {'obtained, thesaurus'};
                end
            end
        end
        
        % basic check
        function p = basicCheck(obj,word,p)

            % check if word is a member of bad words
            if ismember({word},obj.s.database.flag')
               
                p.target = obj.flagReplace({word});
                p.flag  = true;
                p.found = true;
                return
                    
            % check if the word is a bad word
            elseif ismember({word},obj.s.database.bad_words)
                p.target  = {word};
                p.badword = true;
                p.found   = true;
                p.return  = {'bad word'};
                return
                
            elseif ismember({word},obj.s.words_top)
                p.target = obj.flagReplace({word});
                p.found = true;
                return
            end
            
            
            % check if bad word:
            if numel(word) > 3
                IDX = char_feature({word},obj.s.database.bad_words,5,[6,2;10,3],[2,1]);
                if IDX ~= 0
                    if Levenshtein(word,obj.s.database.bad_words{IDX}) <= 2
                        p.found   = true;
                        p.badword = true;
                        p.target = cellstr(obj.s.database.bad_words(IDX));
                        return
                    end
                end
            end
            
            % Stage I: check if the word is spelled correctly.
            if obj.h.CheckSpelling(word) % word is correct
                p.target  = {word};
                p.correct = true;
                p.found   = true;
                return
            end

            % if the word does not exist as true word check for spelling
            if obj.h.GetSpellingSuggestions(word).count == 0
                return
            end
            
            % Recheck spelling given a new transformation
            p.spell = obj.h.GetSpellingSuggestions(word).Item(1).get('name');
            p.spell = lower(p.spell); % lower spelled word
            p.spell(p.spell == '''') = []; % remove
            
            % Return found word is a dual words
            if ~(sum(p.spell == ' ') == 0)
                p.duel = true;
                return
                
            % if single word correct spelling
            else
                
                % remove all potential non-alphabetical character
                p.spell = regexprep(lower(p.spell),'[^a-z]+','');
                
                % transform word to cell string
                p.spell = cellstr(p.spell);
                
                % Check for single word
                p = obj.checkSingleWord(word,p);
                if p.found
                    p.return = {'single, Spell Check'};
                    p.target = obj.flagReplace(p.spell);
                    return
                end
            end
        end
        
    end
    
    % low level spell check
    methods
        
        % perform spell check...
        function p = spellCheck(obj,word,p)
           
            
            falsePositive = {'wtf'};
            
            % Stage I: check if the word is spelled correctly.
            p.correct = obj.h.CheckSpelling(word); % word is correct
            if ismember({word},falsePositive)
               p.correct = false; 
            end

            % if the word does not exist as true word check for spelling
            if ~p.correct
                p.count = obj.h.GetSpellingSuggestions(word).count ~= 0;
            end
            
        end
        
        % baseline spell correct...
        function p = spellCorrect(obj,w,p)
            
            % setup and check inital conditions
            if nargin < 3, p = spellCheck(obj,w); end
            if ~p.count, return, end
            
            % if word is indeed correct or is name
            p.spell = obj.h.GetSpellingSuggestions(w).Item(1).get('name');
            p.spell = lower(p.spell); % lower spelled word

            if ~(sum(p.spell == ' ') == 0) % if a dual words

                % setup word:
                p.spell = strsplit(p.spell); % split words
                p.spell = cellfun(@(x)regexprep(x,'[^a-z]+',''),p.spell,'un',0);
                p.dual  = true;

                % word spell check:
                p = checkDualWords(obj,w,p);

                if p.found
                    p.return = {'Dual, Spell Check'};
                    return
                end

            else % else if a single word
                p.spell = regexprep(p.spell,'[^a-z]+',''); % clean word
                p.spell = cellstr(p.spell); % turn spell to cell

                % check if the original word is equal to bad word
                if ismember(p.spell,{w})
                    if isstrprop(p.spell{1}(1),'upper')
                        p.name  = true;
                    else
                        p.correct = true;
                    end
                end
            end
        end
        
        % check if word is a dual word:
        function p = checkDualWords(obj,word,p)

            % compare word with additional word
            if numel(p.spell) == 2
                str_1 = strjoin(p.spell([1,2]),'');
                str_2 = strjoin(p.spell([2,1]),'');
            else
                return
            end
            
            % If the word is indeed missing a space than
            if ismember(word,{str_1,str_2})
               p.found = true;
               p.correct = true;
               
               % save target data
               if strcmpi(word,str_1), p.target = p.spell([1,2]);
               else, p.target = p.spell([2,1]);
               end
               
               % check if any of the words are small
               if min(numel(str_1),numel(str_2))<4,p.small=true;return
               else, p.small = false; return
               end
               
            end

            % get dual word length...
            dual_len = numel(str_1);

            % word comparing logic:
            L1 = char_feature({word},{str_1},obj.d.S,obj.d.M,obj.d.W);
            L2 = char_feature({word},{str_2},obj.d.S,obj.d.M,obj.d.W);
            LVL_1 = Levenshtein(word,str_1);
            LVL_2 = Levenshtein(word,str_2);
            LV_1 = LVL_1 <= ceil(dual_len/6);
            LV_2 = LVL_2 <= ceil(dual_len/6);
            
            % Word Logic:
            if (L1 == 1 && LV_1) || (LV_2 && L2 == 1)
                p.found = true;
            elseif L1 == 1 && L2 == 0 && LV_1
                p.found = true;
            elseif L1 == 0 && L2 == 1 && LV_2
                p.found = true;
            elseif LVL_1 < ceil(dual_len/7) || LVL_2 < ceil(dual_len/12)
                p.found = true;
            end
        end
        
        % check if word is a dual word:
        function p = checkSingleWord(obj,word,p)
        % compare word with additional word


            % set up inital information
            str = char(p.spell); % obtain found spell check word
            dual_length = numel(str); % length of spell check word
            Lev = 4.25; % Levenshtein Theshold
            Lev_special = 6.5; % Levenshtein Theshold

            % word comparing logic:
            L1 = char_feature({word},{str},obj.d.S,obj.d.M,obj.d.W);
            LVL_1 = Levenshtein(word,str);

            % Word Logic:
            if L1 == 1 && (LVL_1 <= ceil(dual_length/Lev))
                p.found = true;
                if str(1) ~= word(1)
                    p.letter = true;
                end
            elseif LVL_1 <= ceil(dual_length/Lev_special)
                p.found = true;
                if str(1) ~= word(1)
                    p.letter = true;
                end
            end


        end
        
        % common word check
        function p = commonWordCheck(obj,word,p)
           
            if ismember({word},[obj.s.words_bot';obj.s.words_top])
                % obtain return type of three cases
                if p.name, p.return = {'Name, Member'};
                elseif p.correct, p.return = {'Correct, Member'};
                else, p.return = {'Member'};
                end,  p.found  = true; p.member = true;
                return
            end
            
        end
        
    end
    
    % sort methods
    methods 
        
        % sort words
        function obj = sortDataBaseWords(obj)
            
            wds = unique(obj.s.words_top);
            Wsz = cell2mat(cellfun(@(x) numel(x),wds,'un',0));
            [~,Ix] = sortrows(Wsz,'descend');
            obj.s.words_top = wds(Ix);
            
        end
        
    end
    
    % node expansion
    methods
        
        % Build Nodes
        function p = buildNodes(obj,word,p)

            % attempt to build nodes
            p = obtainNodes(obj,word,p);

            % Check For Nodes
            if p.nodes

                % Check Info to see if nods passed expected test
                if p.numel > 8 && p.correct && p.k == 1

                    % Obtain Delete Index for one letter characters...
                    del_idx = cell2mat(cellfun(@numel,p.node_tbl(:,2),'un',0)) == 1;

                    % Check Special Cases
                    if all(~del_idx)
                        p.nodes = false;
                        p.found = false;
                        return

                    % Else Return Word
                    else
                        p.node_tbl = p.node_tbl(del_idx,:);
                        p.return = {'build nodes'};
                        return
                    end

                % Word is small    
                else
                    p.nodes = true;
                    p.found = true;
                    p.return = {'build nodes'};
                    return
                end

            end

        end

        % Obtain nodes findings
        function p = obtainNodes(obj,word,p)

            wds = obj.s.words_top; % pull top words
            
            % if word is not contained return word
            if ~contains(word,wds), return, end
            
            % if word is contained match once
            wds = regexp(word,wds,'match','once');
            wds = wds(cell2mat(cellfun(@(x) ~isempty(x),wds,'un',0))~= 0);
            
            valid_wrds = [obj.s.database.bad_words;obj.s.database.flag;obj.s.database.add_words];
            
            L = false(1,numel(wds));
            for i = 1:length(L)
                if all(wds{i}(1)==wds{i}) % check if word is not repeated letters
                    if ~ismember(wds(i),valid_wrds)
                        L(i) = true; % if so delete word
                    end

                elseif ~obj.h.CheckSpelling(wds{i}) % make sure word is correct
                    if obj.h.GetSpellingSuggestions(wds{i}).count == 0
                        if ~ismember(wds(i),valid_wrds)
                            L(i) = true;
                            continue
                        end
                    elseif ~ismember(wds(i),valid_wrds)
                        spl = obj.h.GetSpellingSuggestions(wds{i}).Item(1).get('name');
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
                p.nodes = true; % nodes have been identified
                p.nodes = true; % nodes are true
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
                TnE{i}     = obj.flagReplace(wds(i));
                value(i,2) = ~any(contains(wds(Idx_Vec~=i),wds{i}));
                value(i,3) = numel(wds{i});

                if numel(other{i}) == 2
                    wdlg = [obj.h.CheckSpelling(other{i}{1}),obj.h.CheckSpelling(other{i}{2})];
                    if any(wdlg)
                        if all(wdlg)
                            % ---------------------------------------------------------
                            LG_Vec = [numel(other{i}{1}) < 3,numel(other{i}{2}) < 3];
                            if any(LG_Vec)

                                % check if word is spelled wrong & less than three
                                LG_Vec = LG_Vec & ~ismember(other{i}(:),obj.s.words_bot)';

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
                                if ~ismember(other{i}{wdlg},obj.s.words_bot)
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
                    if obj.h.CheckSpelling(other{i}{1}) % check for spelling
                        if numel(other{i}{1}) < 3 % if word is less than three
                            if ~ismember(other{i}{1},obj.s.words_bot) % check spelling
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


            p.node_tbl = [wds,other,TnE];
            value(:,4) = and(value(:,3) > 5,value(:,1) >= 0);
            [~,idx] = sortrows(value,[2 4 1 3],'descend');
            p.node_tbl = p.node_tbl(idx,:);

       end
       
    end
       
    % Miscellaneous Methods
    methods 
           
        % obtain true words list
        function True_Words = getTrueWords(obj)
            True_Words = [obj.s.words_bot';obj.s.words_top];
        end
        
        % setup deaul decoder thresholds
        function obj = setupDualDecoder(obj)
            
            obj.d.S = 3; 
            obj.d.W = 2; 
            obj.d.M = [6,1;8,2;10,3];
            
        end
        
    end
    
    
end

% remove n-repeat spaces
function str = cleanup_string(str)

if iscell(str)
    str = str(~ismember(str,{''}));
    if numel(str) == 1
        str = char(str);
    else
        str = strjoin(str);
    end
end

% split word
str = strsplit(str);

% remove spaces
str = str(~ismember(str,{''}));

% rejoin word
str = strjoin(str);

end

% String Functions
% -----------------------

% add to base:
function wd_base = addToBase(wd_base,ND,K)

if nargin == 2, K = 2;  end

if isstruct(wd_base.s)
    ND = ND(~isfield(wd_base.s,ND(:,1)),:);
    if isempty(ND), return, end
end

NUM   = size(ND,1);
IDVEC = wd_base.id + (1:size(ND,1))';


wd_base.id = wd_base.id + NUM;
wd_base.info(IDVEC,1) = ND(:,3);
wd_base.info(IDVEC,2) = ND(:,1);


for i = 1:NUM
    wd_base.s.(ND{i,1}) = [IDVEC(i),K]; 
end

end

% push nodes
function [nodes,past,base] = pushNodes(nodes,base,ND,past)
% updates the nodes, past and word base data structures.

node = nodes(1,:); % obtain the first node
nodes(1,:) = [];   % pop the first node from list

% update word base
base = addToBase(base,ND);
Data = getBase(base,ND(:,1));

if base.k == 1
    past = cellfun(@(x,y) [{x},y{:}],ND(:,1),ND(:,2),'un',0);
    past = cellfun(@(x) strjoin(sort(x)),past,'un',0);
    emp = cell(size(ND,1),4); % empty cells for bad/slang/score
    emp(:,end) = {0};         % fill all end columns with 0
    nodes = [Data(:,1),ND(:,2),Data(:,1),Data(:,1),emp];
    return
end


% unknown
pt_new = cellfun(@(x) [x,node{3}],Data(:,1),'un',0);
pt_new = cellfun(@(x,y)[y{:},base.info{x,1}],pt_new,ND(:,2),'un',0);
pt_new = cellfun(@(x) strjoin(sort([x,node{2}])),pt_new,'un',0);
I = ~ismember(pt_new,past);
past = [past;pt_new(I)];
ND = ND(I,:);

% unknown
Data = getBase(base,ND(:,1));
NND = cell(size(ND,1),8);

% Unknown
NND(:,1) = cellfun(@(x) [x,node{1}],Data(:,1),'un',0);
NND(:,2) = cellfun(@(x) [x,node{2}],ND(:,2),'un',0);
NND(:,3) = cellfun(@(x) [x,node{3}],Data(:,1),'un',0);
NND(:,4) = cellfun(@(x) [x,node{4}],Data(:,1),'un',0);
NND(:,5) = node(5); NND(:,6) = node(6); 
NND(:,7) = node(7); NND(:,8) = node(8);
nodes = [NND;nodes];

[~,idx] = sort([nodes{:,8}]);
nodes = nodes(idx,:);

end

% get base:
function Data = getBase(wd_base,ND,ADD_Data)

% setup output data structure
Data = cell(size(ND,1),2);

% unknown
if nargin == 3
    for i = 1:length(ND)
        Data(i,:) = {[ADD_Data,wd_base.s.(ND{i})(1)],wd_base.s.(ND{i})(2)};
    end
    return
end

% unknown
for i = 1:length(ND)
    Data(i,:) = {wd_base.s.(ND{i})(1),wd_base.s.(ND{i})(2)};
end


end

% fill nodes:
function nodes = fill_Node(nodes,VECTOR,old_word)


        switch VECTOR(2)
            case 2
                nodes{1,1}(end+1) = VECTOR(1);
                nodes{1,3}(end+1) = VECTOR(1);
                nodes{1,4}(end+1) = VECTOR(1);
                return
                
            case 1
                nodes{1,1}(end+1) = VECTOR(1);
                nodes{1,3}(end+1) = VECTOR(1);
                nodes{1,5}(end+1) = VECTOR(1);
                return
                
            case 3
                nodes{1,3}(end+1) = VECTOR(1);
                nodes{1,7}(end+1) = VECTOR(1);
                nodes{1,8} = nodes{1,8} + numel(old_word);
                [~,idx] = sort([nodes{:,8}]);
                nodes = nodes(idx,:);
                return
                
            case 4
                nodes{1,1}(end+1) = VECTOR(1);
                nodes{1,3}(end+1) = VECTOR(1);
                nodes{1,4}(end+1) = VECTOR(1);
                nodes{1,8} = nodes{1,8} + .1;
                [~,idx] = sort([nodes{:,8}]);
                nodes = nodes(idx,:);
                
            otherwise
                error('undetected case')
        end

end

% sort cell array by length:
function [words,stringLength,L] = SortByLength(words)

[~,stringLength] = sort(cellfun(@length,words),'descend');
words = words(stringLength);

if nargout== 3
   L = cell2mat(cellfun(@(x) length(x),words,'un',0)); 
end

end

% sort cells
function nodes = sortCells(nodes,Ix)

[~,idx] = sort([nodes{:,Ix}]);
nodes = nodes(idx,:);

end


% Word Functions
% -----------------------

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

% search Thesaurus Websites
function [Cells,Found] = searchThesaurus(word)

try
    [Cells,Found] = betterSearch(word);
catch
    [Cells,Found] = search_website(word);
end

if numel(Cells) < 4
    [word,T] = CleanWordEndings(word);
    if T
        try
        [Cells,Found] = betterSearch(word);
        catch
            [Cells,Found] = search_website(word);
        end
    end
end


Cells = unique(Cells,'stable');

end

% clean word ending
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

% search primary websites
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

% search backup websites
function [Cells,Found] = search_website(word)

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

% obtain statistics on word:
function s = obtain_stats(word)

Stats = tabulate(double(word));
s.info   = Stats(Stats(:,2) ~=0,:);

end

% General Default
% -------------------------

function B = getDefaults()

% set up constants:
B.small   = false;  % is word a small word
B.name    = false;  % initial pass statement is true
B.member  = false;  % if word is in true words
B.count   = false;  % does have spelling suggestions
B.dual    = false;  % did correct word have more than one words
B.tested  = false;  % has the word tested had normilization test
B.nodes   = false;  % nodes
B.badword = false;  % bad word
B.decode  = false;  % is word decodable
B.found   = false;  % word has been found
B.flag    = false;  % is flag word which needs to be corrected
B.letter  = false;  % used as a negative reward
B.correct = false;  % is the word correct
B.Ret_Cor = true;  % return if correct
B.T       = false;  % break down word slowly
B.theor   = false;
B.k       = 0;
B.spell   = '';
end