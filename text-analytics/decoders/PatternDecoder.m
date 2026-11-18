classdef PatternDecoder
    % The following code looks into the patters of letters, which is
    % different than looking at the patterns between letters. In addition
    % there are also several other methods which  look into other things.
    
    properties
        
        
    end
    
    % run algorithms
    methods
        
        
    end
    
    
    methods
       
        % Decode Numerical Meaning
        function rev = patternDecoderAlg(obj,doc)
            
             % setup p structure...
            p = getContext(doc);
            
            % return if only the word is present
            if p.n == 0,  rev = doc;  return, end
            
            % set reviewed text to the last word
            rev = '';
            
            print_this = false;
            
            % Perform for loop.
            for k = 1:p.n
                
                % check to return
                if k > p.n, return, end
                
                
                
                % review full word
                p = patternSolver(obj,p);
                
                if ~isempty(p.solution)
                   fprintf('%s < %s ',p.solution,p.current) 
                end
                
                % upload solution found
                [rev,p,obj] = uploadSolution(obj,rev,p,true);
                
                if print_this && 1 == 1
                    printLast([rev,' ',p.after]);
                end
                
                print_this = false;
                
                if ~isempty(p.solution)
                    print_this = true;
                end
                
                % setup word context and info.
                p = getContext(doc,k,p);
                
                % if current is empty save lead and return
                if isempty(p.current)
                    rev = [rev,p.lead]; %#ok
                    return
                end
                
            end
        end
        
        % Decode Numerical Meaning
        function rev = demandDecoderAlg(obj,doc)
            
             % setup p structure...
            p = getContext(doc);
            
            % return if only the word is present
            if p.n == 0,  rev = doc;  return, end
            
            % set reviewed text to the last word
            rev = p.current;
            
            k = 0;
            
            % Perform for loop.
            while 1, k = k + 1;
                
                % check to return
                if k > p.n, return, end
                
                % setup word context and info.
                p = getContext(doc,k,p);
                
                % if current is empty save lead and return
                if isempty(p.current)
                    rev = [rev,p.lead]; %#ok
                    return
                end
                
                % review full word
                [p,lgc,kadd] = obj.cleanString(p);
                
                if lgc
                   k = k + kadd; 
                end
                
                % upload solution found
                [rev,p,obj] = uploadSolution(obj,rev,p,true);
                
            end
        end
        
        % solve for patterns in text...
        function p = patternSolver(obj,p)
            
            % check for doo doo
            if any(strcmp(p.current,{'dodo','doodoo','poopoo','voodoo'})),return,end
            
            % remove repeats
            p = obj.removeRepeats(p);
            
            
            if ~isempty(p.solution)
                if obj.isWordKnown(p.solution(p.solution ~= ' '))
                   return 
                end
            end
            
            if (numel(unique(p.current)) < 4 && numel(p.current) > 7) || (numel(unique(p.current)) < 3 && numel(p.current) > 5)
                pv = decodeWordPattern(obj,p.current);
                if pv.decode
                   p.solution = [' ',char(pv.target),' ']; 
                   return
                end
            end
        end
        
        % syntax decoder alg.
        function rev = syntaxDecoderAlg(obj,doc)
            
              % setup p structure...
            p = getContext(doc);
            
            % return if only the word is present
            if p.n == 0,  rev = doc;  return, end
            
            % set reviewed text to the last word
            rev = p.current;
            
            k = 0;
            
            % Perform for loop.
            while 1, k = k + 1;
                
                % check to return
                if k > p.n, return, end
                
                % setup word context and info.
                p = getContext(doc,k,p);
                
                % if current is empty save lead and return
                if isempty(p.current)
                    rev = [rev,p.lead]; %#ok
                    return
                end
                
                % review full word
                p = syntaxSwitch(obj,p);
                
                
                % upload solution found
                [rev,p,obj] = uploadSolution(obj,rev,p,true);
                
            end
            
        end
        
    end
    
    methods
       
        % correct syntax
        function p = syntaxSwitch(obj,p)
            
            if ~strcmp(p.lead,'/'), return, end
            if numel(p.before) < 4, return, end 
            if numel(p.current) < 4, return, end 
            
            if ~obj.isWordKnown(p.current), return, end
            if ~obj.isWordKnown(p.before), return,  end
            
            p.solution = [' and ',p.current];
            
        end
        
        % dictate valid words
        function [p,lgc,k] = cleanString(obj,p)

            lgc  = false;
            k    = 0;

            if ~strcmp(p.historic,'use'), return,   end
            if strcmp(p.before,'not'), lgc = true;  end

            if ~lgc
                if strcmp(p.before,'instead')
                    if strcmp(p.current,'of')
                        lgc = true;
                        k = 1;
                    end
                end
            end

            bad_words = obj.s.database.bad_words;
            if ~ismember({p.beforelast},[bad_words;{'jew';'jews'}])
                lgc = false;
                return
            end


            if lgc
               p.solution = [' use ',p.beforelast];
               p.removePast = true;
            end
        end
    end
    
    % Pattern methods
    methods
        
        % remove repeated letters greater than 3
        function p = removeRepeats(obj,p)
            
            % return if word is slang
            if ismember(p.current,obj.s.database.slang), return, end
            
            % check size
            if numel(p.current) < 6, return, end
            
            % make the word smaller
            wd = p.current;
            
            if all(p.current(1:3) == p.current(1))
                wd = [wd(1),wd(cumsum(wd ~= wd(1))~= 0)];
            end
            
            % easy return size
            if numel(wd) < 5, p.current = wd; return, end
            
            if all(p.current((end-3):end) == p.current(end))
                wd = [wd(cumsum(wd ~= wd(end),"reverse")~= 0),wd(end)];
            end
            
            % easy return size
            if numel(wd) < 5, p.current = wd; return, end
            
            % obtain new word
            [new_word,lgc]  = clearRepeatLoop(obj,wd,1);
            
            if lgc == 0, return, end
            
            if lgc > 2
                p.solution = [' ',p.solution,' '];
                return
            end
            
            % attempt to identify word.
            if obj.isWordKnown(new_word)
                p.solution = new_word;
            else
                new_word = wd([true,diff(wd)~=0]);
                if obj.isWordKnown(new_word)
                    p.solution = new_word;
                else
                    p.solution = clearRepeatLoop(obj,wd,2);
                end
            end
            
            if strcmp(p.solution,p.current)
                p.solution = '';
            end
            
            if ~isempty(p.solution)
               p.solution = [' ',p.solution,' '];
            end
            
        end
        
        % function clear loop repeats
        function [new_word,lgc] = clearRepeatLoop(obj,wd,how)
        
            lgc = 0;
            new_word = '';
            while 1
                if isempty(wd), break, end
                letter = wd(1);
                I = cumsum(wd ~= wd(1))== 0;
                if sum(I) > 2
                    lgc = lgc + 1;
                    wd = wd(~I);
                    if obj.isWordKnown([new_word,letter,wd])
                        new_word = [new_word,letter,wd]; %#ok
                        return
                    else
                        if how == 1, new_word = [new_word,letter]; %#ok
                        else, new_word = [new_word,letter,letter]; %#ok
                        end
                    end
                else
                    new_word = [new_word,wd(I)]; %#ok
                    wd = wd(~I);
                end
            end
        end
        
        % decode word pattern
        function p = decodeWordPattern(obj,word)
           
            % word statistics:
            p.word   = double(word);   % word in double form
            p.numel  = numel(word);    % numel of word
            p.unique = unique(p.word); % get unique letters
            p.target = {word};         % return information
            p.decode = false;
            
            % decode word pattern
            p = decodePattern(obj,p);
        end
        
        % decode pattern
        function p = decodePattern(obj,p)
            % decode pattern in string
            
            
            % check for processes
            if ~obj.patternProcess, return; end
            
            % check size of word
            if p.numel < 6, return, end
            
            % check if word is known
            if obj.isWordKnown(p.target), return, end
            
            if endsWith(p.target,'ed') && ~startsWith(p.target,'e')
                return
            end
            
            % return if numel is too big
            if numel(p.unique) > 3, return, end
            
            
            % extract words and meanings
            Words = obj.s.database.slang;
            
            % extract second word
            L2 = p.unique(~ismember(p.unique,p.word(1)));
            
            % filer word
            remain = p.word(cumsum([0,diff(p.word)] ~= 0)~= 0);

            % set word so small variable for better handling
            w = p.word;
            
            % one letter change over case.
            if numel(unique(remain)) == 1
                
                if ismember(char([w(1),L2]),Words)
                    p.decode = true;
                    p.target = cellstr(char([w(1),L2]));
                    return
                
                elseif numel(p.word) > 3
                    p.decode = true;
                    p.target = cellstr(char([w(1),L2,L2,L2]));
                    return
                else
                    p.decode = true;
                    p.target = cellstr(char([w(1),L2,L2]));
                    return
                end
            elseif numel(unique(remain)) == 0
                p.target = cellstr(char([w(1),w(1),w(1)]));
            end
                
                
            
            % refiller word
            L2 = remain(1);
            remain = remain(cumsum([0,diff(remain)] ~= 0)~= 0);

            % three letter change over case.
            if numel(unique(remain)) == 1
                
                if p.numel > 8,  return;  end
                
                L3 = remain(1);
                if ismember(char([w(1),L2,w(1)]),Words)
                    p.decode = true;
                    p.target = cellstr(char([w(1),L2,L3]));
                    return
                    
                elseif numel(p.word) > 3
                    p.decode = true;
                    p.target = cellstr(char([w(1),L2,L3,L3]));
                    return
                else
                    p.decode = true;
                    p.target = cellstr(char([w(1),L2,L3,L3]));
                    return
                end
                
            elseif numel(p.unique) == 3
               return 
            end
            
            % check if word is member
            I = ismember([101,97,104],p.unique);
            if xor(I(1),I(2)) && I(3) && p.numel > 4
                if p.word(1) == p.word(3) && p.word(1) ~= p.word(2)
                    if ismember(101,p.unique)
                        p.target = 'hehe';
                        p.decode = true;
                        if numel(p.word) > 8
                            p.correct = true;
                            p.target = {'hehehehe'};
                        end
                        return
                    else
                        p.target = 'haha';
                        p.decode = true;
                        if numel(p.word) > 8
                            p.correct = true;
                            p.target = {'hahahaha'};
                        end
                        return
                    end
                end
            end
            
            
            
            
            
            w = p.word;
            if p.numel > 3
                if w(1) == w(3) && w(1) ~= w(2)
                     
                    if w(1) == w(end)
                        
                        % check for bad word
                        if ismember(char([w(1),L2,w(1)]),Words)
                            p.decode = true;
                            p.target = cellstr(char([w(1),L2,w(1)]));
                            return
                        end
                        
                        p.decode = true;
                        p.target = cellstr(char([w(1),L2,w(1),L2,w(1)]));
                        return
                        
                    else
                        
                        % check for bad word
                        if ismember(char([w(1),L2]),Words)
                            p.decode = true;
                            p.target = cellstr(char([w(1),L2]));
                            return
                        end
                        
                        p.decode = true;
                        p.target = cellstr(char([w(1),L2,w(1),L2]));
                        return
                    end
                end
            end
            
            
            if p.word(1) == p.word(end)
                p.target = char([w(1),L2,w(1)]);
                p.decode = true;
                return
            else
                p.target = char([w(1),L2]);
                p.decode = true;
                return
            end
        end
        
        % attempt to replace word
        function [D,I] = wordReplace(obj,D)
            
            % extract words and meanings
            Words = obj.s.database.slang;
            
            I = ismember(D,Words); % try to find word
            if ~I,return, end % join words go to next
            
            D = obj.s.slangs{D,'replace'};
            D = strsplit(char(D),' '); % join str
            D = cellfun(@(x) regexprep(lower(x),'[^a-z]+',''),D,'un',0);
            D = D(~ismember(D,{''}));

        end
        
    end
end


% print context of word
function printLast(rev)

past = 45;

start = max(numel(rev)-past,1);
rev = rev(start:end);

fprintf('%s \n',rev)


end

