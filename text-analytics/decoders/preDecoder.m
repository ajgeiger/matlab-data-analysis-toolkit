classdef preDecoder
    % The following class helps us understand how numbers and letters
    % combinations can be used to draw meaning full insight. The follow
    % class provides users an:
    %
    % 1. Embedded word decipher
    % 2. Symbolic word decryption
    % 3. Numeric slang conversion
    % 4. IQ testing
    % 5. Unit conversion
    % 6. Currency conversion
    
    % general properties
    properties
        
        numLetMap;
        
    end
     
    % General
    methods
        
        % pre-processing word clean up.
        function [rev,obj] = cleanup_word(obj,doc)
            % In the following section we clean up the words and switch out
            % short hand notation including unit conversions and more.
            %
            %   1. document prep for decoding.
            %   1. numeric quanity replacement
            %   2. unit extrapolation
            %   3. Hard to identify slang clean up.
            
            % setup document variables...
            doc = obj.prepDocument(doc);
            
            % decode hidden words...
            doc = obj.hiddenWordDecode(doc);
            
            % Decode hidden sybol words...
            doc = SymWordDecoder(obj,doc);
            
            % decode numerical meaning...
            [rev,obj] = obj.numericalWordDecoder(doc);
            
            % Delete Symbols
            rev = strrep(rev,'‰','');
            rev = strrep(rev,'ø¹','');
            rev = strrep(rev,'ð','');
            rev = strrep(rev,'±','');
            
        end
        
         % removes bad characters and decodes hard slang
        function document = prepDocument(obj,document)

            % for bad text
            document = lower(document);
            document = textCipher(document);

            % Bad Text
            document = strrep(document,'â­','');
            document = strrep(document,'Â­','');
            document = strrep(document,'â€"',' ');
            document = strrep(document,'â€?',' ');
            document = strrep(document,'â€œ',' ');
            document = strrep(document,'â€™','');
            document = strrep(document,'â€”',' ');
            document = strrep(document,'â€”',' ');
            document = strrep(document,'â€¦',' ');
            document = strrep(document,'â€',' ');
            document = strrep(document,'â€?',' ');
            document = strrep(document,'â”?','');
            document = strrep(document,'â?¥','');
            document = strrep(document,'â”£','');
            document = strrep(document,'«ð•','');
            document = strrep(document,['â”',char(8212)],'');
            document = strrep(document,'ï¼¯','');
            document = strrep(document,'â\xad','');
            document = strrep(document,'â\x9d','');
            document = strrep(document,'\x8f','');
            document = strrep(document,'\x81','');
            document = strrep(document,'\x8d','');
            document = strrep(document,'ñ\x81','');
            document = strrep(document,'…â','');
            document = strrep(document,char([202,143]),'y');
            document = strrep(document,'â€™','''');

            % symbol words
            document = strrep(document,'(.)(.)','boobz');
            document = strrep(document,'/(.)(.)\','boobz');
            document = strrep(document,'g@y','gay');
            document = strrep(document,'f@t','fat');
            document = strrep(document,'niglet','nigger');
            
            
            % special cases
            document = strrep(document,'can''t','cannot');
            document = strrep(document,'he''ll','he will');
            document = strrep(document,'she''ll','she will');

            % may switch later
            document = context_concept(document,'''ll','ll');
            document = context_concept(document,'''ve','ve');
            document = context_concept(document,'s', 's');
            document = context_concept(document,'n''t','nt');
            document = context_concept(document,'''re','re');
            document = context_concept(document,'''d', 'd');

            document = context_concept(document,'1/2',' half');
            document = context_concept(document,'1/3', ' third');
            document = context_concept(document,'1/4', ' fourth');
            document = context_concept(document,'1/5', ' fifth');
            document = context_concept(document,'1/7', ' fifth');
            document = context_concept(document,'100%', ' completely');

            document = strrep(document,'f**k','fuck');

            % Hard to identify words
            document = strrep(document,'child(ren)','child');
            document = strrep(document,' ta ta ','spanking');
            document = strrep(document,' tata ','spanking');
            document = strrep(document,'tit for tat','retaliation');
            document = strrep(document,'24/7','all the time');
            document = strrep(document,'/week',' per week');
            document = strrep(document,'/month',' per month');
            document = strrep(document,'/hour',' per hour');
            document = strrep(document,'/day',' per day');
            document = strrep(document,' vs. ',' versus ');


            if contains(document,{'fck'})
                document = strrep(document,'fck','fuck');
                disp(document)
            end

            if contains(document,{'muvva','mutha'})
                document = strrep(document,'muvva','mother');
                document = strrep(document,'mutha','mother');
                disp(document)
            end

            % replace words
            document = strrep(document,' effin ',' fucking ');
            document = strrep(document,'antiscience','against science');
            document = strrep(document,'chillen','relaxing');
            document = strrep(document,'niqqer','nigger');
            document = strrep(document,'altright','far right');
            document = strrep(document,'lgtb','lgbt');
            document = strrep(document,'lgbtq','lgbt');
            document = strrep(document,'dtrump','trump');
            document = strrep(document,'fuckenews','fucken news');

            % small word corrections
            % dual meaning words
            document = strrep(document,'i''d','i would');
            document = strrep(document,'i''m','i am');
            document = strrep(document,' i.e ',' for example ');
            document = strrep(document,'p.s.','post message');
            document = strrep(document,'a.m.','am');
            document = strrep(document,'p.m.','pm');
            document = strrep(document,'w.e.','whatever');
            document = strrep(document,'u.s.',' united states ');
            document = strrep(document,'b.s.','bachelor of science');
            document = strrep(document,'dr.','doctor');
            document = strrep(document,'mr.','mister');
            document = strrep(document,'#feelthebern','socialist bernie sanders slogan');

            % numeric word  conversion
            document = strrep(document,'1st','first');
            document = strrep(document,'2nd','second');
            document = strrep(document,'3rd','third');

            if contains(document,'th')
                document = strrep(document,'4th','fourth');
                document = strrep(document,'5th','fifth');
                document = strrep(document,'6th','sixth');
                document = strrep(document,'7th','seventh');
                document = strrep(document,'8th','eighth');
                document = strrep(document,'9th','ninth');
                document = strrep(document,'10th','tenth');
                document = strrep(document,'11th','eleventh');
                document = strrep(document,'12th','twelfth');
            end

            document = context_concept(document,' 1.0 version',' first version');
            document = context_concept(document,' 2.0 version',' second version');
            document = context_concept(document,' 3.0 version',' third version');
            document = context_concept(document,' 4.0 version',' fourth version');

            % replace the $ in bad words
            if contains(document,obj.s.hardSlang.id)
                document = strsplit(document);
                [Ix,Id] = ismember(document,obj.s.hardSlang.id);

                if ~all(Ix==0)
                    document(Ix~=0) = strcat(obj.s.hardSlang.replace(Id(Ix~=0)),' ');
                end

                 % clean up document.
                 document = cleanup_string(document);

            end

            % basic star word fixes
            document = strrep(document,'f**k','fuck');
            document = strrep(document,'c**t','cunt');
            document = strrep(document,'c*nt','cunt');
            document = strrep(document,'sh*t','shit');
            document = strrep(document,'s**t','shit');
            document = strrep(document,'bi**h','bitch');
            document = strrep(document,'b***h','bitch');
            document = strrep(document,'b**ch','bitch');
            document = strrep(document,'b*tch','bitch');

            % remove bad letters
            document = strrep(document,'`','');
            document = strrep(document,'''','');
            document = strrep(document,'----','');
            document = strrep(document,'---','');
            document = strrep(document,'--','');
            document = strrep(document,'-',' ');
            document = strrep(document,'­','');
            document = strrep(document,'','');

        end
              
        % check if word is known
        function lgc = isWordKnown(obj,word)
            
            word = cellstr(word);
            lgc = true;
            
            % check if word is known
            if obj.isCheckWordKnown(word), return, end
            
            % check for z
            if endsWith(word,'z'), word = [word(1:(end-1)),'s']; end
            
            % check if words
            if obj.isCheckWordKnown(word), return, end
            
            
            lgc = false;
        end
        
        % check if word is known
        function lgc = isCheckWordKnown(obj,word)
            lgc = false;
            
            if ismember(word,[obj.s.words_bot,obj.s.words_top'])
                lgc = true;
                return
                
            elseif ismember(word,obj.s.newsNetworks)
                lgc = true;
                return
                
            elseif ismember(word,obj.s.unknownSlang)
                lgc = true;
                return
                
            elseif ismember(word,obj.s.database.bad_words)
                lgc = true;
                return
            end
        end
    end
    
    % Loop Methods
    methods
        
        % This loop decodes hidden words.
        function [rev,obj] = hiddenWordDecode(obj,doc)
        
            % setup p structure
            p = getContext(doc,false);
            
            % return if only the word is present
            if p.n == 0,  rev = doc;  return, end
        
            % set reviewed text to the last word
            rev = p.current;
            k   = 0;
            
            % Perform for loop.
            while 1, k = k + 1;
                
                % check loop logic for break
                if k > p.n, return, end
                
                % setup word context and info.
                p = getContext(doc,k,p);
                
                % if current is empty return
                if isempty(p.current)
                    rev=[rev,p.lead]; %#ok
                    return
                end
                
                % pattern detection
                package = obj.hiddenDecoder(p,doc,k-1);
                
                % package has passed
                if package.pass
                    
                    % display decoded word
                    displayDecode(doc,package,p,k)
                    
                    % update new context package values
                    p.removePast     = true;
                    p.removePastLast = true;
                    p.current  = package.word;
                    p.solution = [' ',p.current,' '];
                    
                    % upload offical solution found
                    [rev,p,obj] = uploadSolution(obj,rev,p,false);
                    
                    % print data
                    printLast(rev);
                    
                    % return if package exit is flagged
                    if package.exit, return, end
                    
                    % set new search index
                    p.k = package.index - 1;
                    k   = package.index - 1;
                    
                    % reset context
                    p.before     = p.historic;
                    p.beforelast = '';
                    continue;
                end
                
                % upload results
                [rev,p,obj] = uploadSolution(obj,rev,p,false);
                
            end
        end
        
        % This loop decodes hidden words.
        function [rev,obj] = SymWordDecoder(obj,doc)
            
            % setup p structure
            p = getContext(doc,false);
            
            % return if only the word is present
            if p.n == 0,  rev = doc;  return, end
        
            % set reviewed text to the last word
            rev = p.current;
            k   = 0;
            
            % Perform for loop.
            while 1, k = k + 1;
                
                % check loop logic for break
                if k > p.n, break, end
                
                % setup word context and info.
                p = getContext(doc,k,p);
                
                % check if current exists
                if isempty(p.current)
                    rev = [rev,p.lead]; %#ok
                    return
                end
                
                % decode words
                [p,obj] = DecodeSymWord(obj,p);
                
                
                % upload results
                [rev,p,obj] = uploadSolution(obj,rev,p,false,true);
                
                if ~isempty(p.solution), printLast(rev); end
                
               
            end
        end
        
        % Decode Numerical Meaning
        function [rev,obj] = numericalWordDecoder(obj,doc)
            
             % setup p structure...
            p = getContext(doc);
            
            % return if only the word is present
            if p.n == 0,  rev = doc;  return, end
            
            % set default graph this value
            disp_this = false;
            
            % add rev
            rev = '';
            
            % Perform for loop.
            for k = 1:p.n
                
                % check to return
                if k > p.n, return, end
                
                % --------------------
                % Plot Code To Next
                % ---------------------
                
                % review full word
                if p.type.full,  p = obj.reviewFullWord(p);        end
                
                % review left word
                if p.type.left, [p,obj] = obj.reviewLeftWord(p);   end
                
                % review right word
                if p.type.right, [p,obj] = obj.reviewRightWord(p); end
                
                % upload solution found
                [rev,p,obj] = uploadSolution(obj,rev,p,false);
                
                % --------------------
                % Display To Next
                % ---------------------
                
                % plot data
                if disp_this && 1 == 2, printLast([rev,' ',p.after]); end
                
                % always reset
                disp_this = false;
                
                % check for graph
                if ~isempty(p.solution), disp_this = true; end
                
                % --------------------
                % Loop To Next
                % --------------------
                
                % setup word context and info.
                p = getContext(doc,k,p);
                
                % if current is empty save lead and return
                if isempty(p.current)
                    rev = [rev,p.lead]; %#ok
                    return
                end
            end
        end
        
    end
    
    % swear word decoder
    methods
        
        % Decode symbolic words
        function [p,obj] = DecodeSymWord(obj,p)
            
            % Logical Checks
            if isempty(p.current) || isempty(p.before), return, end
            if any(ismember(p.lead,[' ',newline])),     return, end
            if ~any(ismember(p.lead,'@$#!*%?~^'));      return, end
            if numel(unique(p.before)) > 4,             return, end
            
            
            % Decode Bad Words
            if startsWith(p.before,'f')
                [p,obj] = checkSymPattern(obj,p,'fuck');
            elseif startsWith(p.before,'c')
                check_lgc = ~any(strcmp(p.current,{'tonne','ton'}));
                if check_lgc || numel(p.before)>2
                    [p,obj] = checkSymPattern(obj,p,'cunt');
                end
            elseif startsWith(p.before,'b')
                
                % avoid special case
                if ~(startsWith(p.before,'bit') && endsWith(p.before,'s'))
                    [p,obj] = checkSymPattern(obj,p,'bitch');
                end
                
                % if nothing found then check for for bastard
                if isempty(p.solution)
                    [p,obj] = checkSymPattern(obj,p,'bastard');
                end
                
            elseif startsWith(p.before,'d')
                [p,obj] = checkSymPattern(obj,p,'dick');
            elseif startsWith(p.before,'n')
                [p,obj] = checkSymPattern(obj,p,'nigger');
            elseif startsWith(p.before,'w')
                [p,obj] = checkSymPattern(obj,p,'whore');
            end
            
            % if solution found return
            if ~isempty(p.solution)
               p.solution = [' ',p.solution,' '];
               fprintf('%s -> decoded from -> %s %s %s -> ',p.solution,p.before,p.lead,p.current)
               p.removePast = true;
               return
               
            % check for known words with @ symbol
            elseif numel(p.lead) == 1 && ismember(p.lead,'@')
                if isWordKnown(obj,[p.before,'a',p.current])
                    p.solution = [' ',p.before,'a',p.current,' '];
                    p.removePast = true;
                end
            end
            
        end
        
        % Check for symbol pattern
        function [p,obj] = checkSymPattern(obj,p,match)
            
            N      = numel(p.lead); % The number of elements in lead
            END = ''; % word ending
            REM = ''; % remaining before ending

            if     endsWith(p.current,{'ing'}),  END = 'ing';
            elseif endsWith(p.current,{'in'}),   END = 'in';
            elseif endsWith(p.current,{'en'}),   END = 'en';
            elseif endsWith(p.current,{'ed'}),   END = 'ed'; 
            elseif endsWith(p.current,{'es'}),   END = 'es'; 
            elseif endsWith(p.current,{'s'}),    END = 's';     
            else,  REM = p.current;
            end

            % If rem is empty set then ending was found. 
            if isempty(REM) && numel(p.current) > numel(END)
               REM = p.current(1:end-numel(END));
            end
            
            % setup start
            START = p.before([true,diff(p.before)~=0]);
                
            % Logical Checks
            if numel(match) < numel(START),          return, end
            if ~strcmp(START,match(1:numel(START))), return, end
            if isempty(REM) && N > 1
                p.solution=[match,END];
                return
            end
            
            % Special Cases
            if all(ismember(p.lead,'@')) && strcmp(p.before,'ke')
                if strcmp(START,'f'), p.solution='fake'; return, end
            end
            
            % setup general info
            remap = match((1+numel(START)):end);
            remid = REM;
            n     = numel(remap);
            sz    = numel(remid);
            
            
            for k = 1:n
                
                % Ensure the Size is valid
                if n - k + 1 > sz, continue, end
                
                % Check If Strings Match
                if strcmp(remap(k:n),remid(1:n-k+1))
                    if k == 1, p.solution = [START,remid,END]; return, end
                    p.solution = [START,remap(1:(k-1)),remid,END];
                    return
                end
            end
        end
        
    end
    
    % high level replacement functions
    methods
        
        % add review word
        function [p,obj] = reviewFullWord(obj,p)
            
            % generate word
            word = [p.before,p.lead,p.current];
            
            % check for h1b
            if strcmpi(word,'h1b')
                word         = 'honebflag';
                p.removePast = true;
                p.solution   = word;
                return
            end
            
            % convert slang words
            word = slang_coverter(word);
            
            % check if word is known
            if isWordKnown(obj,word)
                p.removePast = true;
                p.solution   = word; 
                return

            elseif strcmp(p.lead,'0') && strcmp('pr',p.before)
                p.removePast = true;
                p.solution   = word; 
                return
            end

            % check for hidden swear words
            p = conv_hidden_swr_wrds(p);
            
            % solution
            if isempty(p.solution)
                p.solution = [p.before,p.lead,p.current];
            end
        end
        
        % review left word
        function [p,obj] = reviewLeftWord(obj,p)
            
            % convert hidden swear words
            p = conv_hidden_swr_wrds(p);
            
            % check for co2 in text
            if strcmpi([p.before,p.left.number],'co2')
                p.solution = ' carbon dioxide ';
                p.removePast = true; p.exit = true;
                return
                
            %  look if word ref a senate or house bills.
            elseif ismember({p.before},{'sb','hb'})
                p = govBillDecoder(p);
                return
                
            % check for special case (M1, F16, F35,..., ect)
            elseif numel(p.before) < 3 && numel(p.left.number) < 4
                p.solution = [' ',p.before,p.left.number];
                p.removePast = true;
                return
                
            end
            
            % add word to table for debugging
            [p,obj] = obj.singleNumber(p);
            
            % small word check
            if isempty(p.solution)
                
                % generate logical vector
                L = (numel(p.left.number)>2 && numel(p.before)>1);
                
                if numel(p.before)>4|| L
                    p.removepast = true;
                    p.solution = [' ',p.before];
                    return
                end
            else
               1; % perform debugging
            end

            
           % add word to table for debugging
           obj = addSpecialWord(obj,[p.before,p.left.number]);
            
        end
        
        % review right word
        function [p,obj] = reviewRightWord(obj,p,v)
            
            % set default view to false
            if nargin < 3, v = false; end
            
            % first complex iq test
            if strcmp('an iq of',[p.historic,' ',p.beforelast,' ',p.before])
                p = iq_test(p);
                p.removePast     = true;
                p.removePastLast = true;
                p.removeHistoric = true;
            end
            
            % setup values
            unit_found = false;
            unit = p.current;
            
            
            if strcmp(p.right.number,'401') && any(strcmp(unit,{'k','ks'}))
                 p.solution = [p.solution,' retirement savings plan '];
            end
            
            % look for unit conversion
            if ismember(p.current,obj.s.unit_cv.unit)
                unit_found = true;
                unit = obj.s.unit_cv{p.current,'names'}{1};
            end
            
            % check if value is a date time
            [p,lgc] = obj.datetime_conv(p,unit,v);
            if lgc,  return , end
            
            % check if value is number
            p = convert_USD(obj,p,unit_found,unit);
            if p.exit, return, end
            
            % check for percent sign
            if p.right.pctFlag
                setup = [p.solution,' ',p.right.number];
                p.solution  = [setup,' percent ',unit,' '];
            end
            
            
            % perform iq test
            if ismember(p.current,{'iq'}) && obj.serviceIQ
                p = iq_test(p);
                if v, printLast(rev); end
                return
            end
            
            % bedroom verification
            if strcmp('bdr',p.current)
               if  any(ismember({'bathrooms','bath','closets','families','family'},{p.before,p.after}))
                   unit = 'bedrooms';
               else
                  unit = 'bdr'; 
               end
            end
            
            if ~strcmp(unit,p.current) && (numel(p.current) > 2 || numel(p.right.number) > 3)
                p.solution = [p.solution,' ',p.right.number,' ',unit,' '];
            end
            
            % add space if word & letter probabily not connected
            if isempty(p.solution)
                if numel(p.current) > 4 || numel(p.right.number)>1
                    p.solution = [p.solution,' ',p.right.number,' ',p.current,' '];
                end
            end
            
        end
        
        % Decoder words embedded in text
        function pack = hiddenDecoder(obj,p,doc,start)
            % The following function decodes words embedded in a string.
            % The word is defined by a set symbol spacing examples include
            % the method covers two letter space, and a standard space.
            %
            % 1. this <- t.h.i.s
            % 2. this <- tâ--hâ--iâ--s
            
            % Setup Outputs
            pack.pass = false;
            pack.exit = false;
            
            % Attempt to discover pattern
            if ~all([numel(p.beforelast),numel(p.before),...
                    numel(p.current),numel(p.after)] == 1)
                return
            end
            
            % setup basic parameters
            indexs = (p.start(start)-1):numel(doc); % index of letters
            symbol = doc((p.start(start)):p.end(start)); % setup symbol
            str    = doc(indexs);   % valid letters to search
            n      = numel(symbol); % size of symbol
            len = numel(str);       % size of valid letters
            word = '';              % decoded word
            k    = 1;               % loop index
            last = nan;             % last count logic
            
            while 1
                if k+n > len % check exit condition
                    if k <= len
                        if isletter(str(k)), last = k;
                            word = [word,str(k)]; %#ok
                        end
                    end,break
                end
                
                % if word exist add to line
                if strcmpi(symbol,str((k+1):(k+n))) && isletter(str(k))
                    last = k; word = [word,str(k)]; %#ok
                    k = k + n + 1; continue
                
                % if current letter is a letter then
                elseif isletter(str(k))
                    
                    % preset check to false
                    check_word = false;
                    
                    % Check word logic
                    if numel(str) > k + 1
                        if ~isletter(str(k+1)),  check_word = true;  end
                    else,  check_word = true; 
                    end
                    
                    % break loop
                    if ~check_word, break , end
                    
                    % check special cases if passes update word then break
                    if obj.isWordKnown([word,str(k)])
                        last = k; word = [word,str(k)]; %#ok
                    % check for bad first letter special case
                    elseif ismember(word(1),{'i','a'})
                        if obj.isWordKnown([word(2:end),str(k)])
                            last = k; word = [word,str(k)]; %#ok
                        end
                    end 
                    
                    % break loop
                    break
                end
                
                % break if the symbol is less than two
                if n < 1, break, end
                
                % check for when two letters are together a space is made.
                if k + n + 1 <= len && all(isletter(str([k,k+1])))
                    
                    % obtain next potential symbol.
                    next = str((k+2):(k+n+1));
                    
                    if strcmpi(symbol,next), last = k;
                        word = [word,str(k),' ']; %#ok
                        k = k + 1;
                        continue
                    end
                end
                
                % check for space between two encoded words
                if isletter(str(k)), last = k; word = [word,str(k)]; %#ok
                    if ~isspace(str(k+1)), break,                end
                    if len > k + 3, k = k + (isspace(str(k+1))); end
                    k = k + 2; word = [word,' ']; %#ok
                    continue
                end
                
                % break loop if all failed
                break
            end
            
            % return if data obtained is limited
            if numel(word) < 4, return, end
            
            % check if word has a space
            if any(word == ' ')
                words = strsplit(word);
                pack.pass = false;
                for k = 1:numel(words)
                    if isempty(words{k}), continue; end
                    if numel(words{k}) < 5 || isWordKnown(obj,word)
                        % pack.pass = false;
                    else
                        pack.pass = true;
                    end
                end
                
            % check if word is known
            elseif obj.isWordKnown(word)
                pack.pass = true;
                
            % check for potianl conflicting letters ('a')
            elseif strcmp(symbol,' ')
                
                % generate check for special cases
                for BK = {'i','a'}
                    if ~pack.pass && word(1) == BK{1}
                        if isWordKnown(obj,word(2:end))
                            word = [BK{1},' ',word(2:end)];
                            pack.pass = true;
                        end
                    end
                end
                
                % pause if word not found
                if ~pack.pass
                   1; 
                end
            end
            
            % last ditch attempt... check for s ending
            if ~pack.pass && endsWith(word,'s')
                if obj.isWordKnown(word(1:end-1))
                    word = [word(1:end-1),' is'];
                    pack.pass = true;
                end
            end
            
            
            % return if the word did not pass.
            if ~pack.pass, return, end
            
            % setup word and set pass to true
            pack.pass = true; pack.word = word;
                
            % check for new index in loop
            I = p.start > indexs(last);
            
            % if no index exists set exit to true and return
            if ~any(I), pack.exit = true; return, end
            
            % find the minimum index which exists
            pack.index=max((1:numel(p.start)).*(p.start==min(p.start(I))));
            
        end
        
    end
    
    % Background Functions
    methods
           
        % convert USD and slang 
        function p = convert_USD(obj,p,unit_found,unit)
            
            % check if value is number
            if strcmp(p.right.front,'$')
                p.exit = true;
                
                % attempt to identify full word
                if ~unit_found, unit_found = ismember(p.current,obj.s.unit_cv.names); end
                
                % check if no unit has still not been found
                if ~ unit_found
                    % check for month as a last ditch effort
                    if strcmp(p.current,'mo')
                        unit_found = true; 
                        unit = ' month ';
                    end
                end
                
                if strcmp(p.right.end,'/')
                    p.solution = [p.solution,' ',p.right.number,' dollars per ',unit,' '];
                    return
                else
                    if unit_found
                        p.solution  = [p.solution,' ',p.right.number,' ',unit,' dollars '];
                    else
                        p.solution  = [p.solution,' ',p.right.number,' dollar ',unit,' '];
                    end
                    return
                end
            end
        end
          
        % decode word ending with a single number
        function [p,obj] = singleNumber(obj,p)
           % Attempt to decode word ending in a single number. The method
           % only words for the numbers
           % 
           % 1. '1' = one, won
           % 2. '2' = too, to
           % 3. '3' = three (only for ww3)
           % 4. '4' = for, four
           
            
            % cannot be a 1 letter word can cause big problems.
            if numel(p.before) == 1,        return,   end
            if numel(p.left.number) ~= 1,   return,  end
            
            % only allow follow to be 1,2 or 4
            if ~ismember(p.left.number,{'1','2','3','4'}), return, end
            
            % setup word space
            wrds = {p.beforelast,p.after,p.current};
            
            % and one decoder
            [p,lgc] = and1decoder(p,wrds);
            if lgc, return, end
            
            % world war decoder
            [p,lgc] = ww_decoder(p,wrds);
            if lgc, return, end
            
            % if word ends in ing & is followed by 2, set known to invalid
            sc = ~(endsWith(p.before,'ing') && strcmp(p.left.number,'2'));
            
            % Check if word does not exixt if so attempt to decode
            if ~isWordKnown(obj,p.before) && sc
                
                % first decoding qualification
                if numel(p.before) < 6, return, end
                
                % second decoding qualification
                if numel(unique(p.before)) > 2, return,  end
                
                % decode word pattern
                vp = decodeWordPattern(obj,p.before);
                
                % return if decoder failed
                if ~vp.decode, return, end
                
                % extract new target word
                p.before = char(vp.target);
                
                % filter any extra letters which tagged along.
                p.before = p.before([true,diff(p.before)==1]);
                
            end
           
            % decode word ending
            p = decodeEndingNumber(p,obj);
            
        end
        
        % date time converter
        function [p,lgc] = datetime_conv(obj,p,unit,v)
            % First:
            % The biggest by far of the function converts the keyword
            % mf into monday through friday in stead of a very nasty word.
            %
            % Second:
            % the keyword am number pm is corrected for.
            %
            
           if nargin < 4,v = false; end
            
            %  setup logic
            lgc = false;
            p.lgc = false;
            
            % check for monday through friday short hand
            if ismember({p.current},{'pm','am'})
                if strcmpi(p.before,'mf')
                    p.removeBefore = true;
                    p.solution = [p.solution,' moday through friday '];
                    if v, printLast(rev); end
                end
                
                % convert am and pm
                if strcmpi({p.current},'am') && strcmpi(p.after,'pm')
                    ending = obj.s.unit_cv{p.after,'names'}{1};
                    p.solution = [p.solution,' ',p.right.number,' ',...
                                  unit,' to ',p.right.number,' ',ending,' '];
                    p.lgc = true; lgc = true;
                    if v, printLast(rev); end
                    return
                end
            end
            
            % check for monday through friday short hand
            if strcmpi(p.current,'mf')
                if strcmpi(p.before,'work'), lgc = true;
                    p.solution = [p.solution,' moday through friday '];
                    if v, printLast(rev); end
                end
            end
        end
       
    end
    
    % table methods
    methods
        
        % Add word to table
        function obj = addSpecialWord(obj,word)
           
            % remove spaces
            word = strrep(word,' ','');
            
            if isempty(obj.numLetMap)
                count = 1;
                obj.numLetMap = table(count,'RowNames',{word});
            else
                try
                   count =  obj.numLetMap{word,'count'};
                catch
                   obj.numLetMap(word,'count') = {1};
                   return
                end
                
                % add to count
                obj.numLetMap(word,'count') = {count+1};
            end
            
            
        end
          
    end
    
end


% Print Statements ------------------------------------
% -----------------------------------------------------

% print context of word
function printLast(rev)

past = 45;

start = max(numel(rev)-past,1);
rev = rev(start:end);

fprintf('%s \n',rev)


end

% display decoded word
function displayDecode(doc,package,p,k)

% setup start values
start =  p.start(k-1) - 1;
                    
% print results
if package.exit
    fprintf('%s -> decoded from -> %s  ',...
        package.word,doc(start:end))
else
    fprintf('%s -> decoded from -> %s  ',...
    package.word,doc(start:p.start(package.index)))
end

end


% Numeric Corrections ---------------------------------
% -----------------------------------------------------

% the iq test
function p = iq_test(p)


% top threshold for average intelligence
top_thresh = 115;

% calculate double value
number = str2double(p.right.number);

% check for average iq.
if number > 89 && top_thresh + 1 > number
    p.solution = [p.solution,' average iq '];

% check for very high iq
elseif 139 < number
    p.solution = [p.solution,' very high iq '];    

% check for high iq
elseif 115 < number
    p.solution = [p.solution,' high iq '];

% check for very low iq
elseif 50 > number
    p.solution = [p.solution,' low iq ']; 
   
% check for low iq
elseif 95 > number
    p.solution = [p.solution,' extremely low iq '];  

% could not find
else
   p.solution = [rev,start_word,new_word];
   return
end
                    

end

% convert hidden swear words
function p = conv_hidden_swr_wrds(p)
   
   % set logic to false...
   lgc = false;
   
   % check for the word he11
    if strcmpi(p.left.number,'11') && strcmpi(p.before,'he'),lgc = true;
        if    p.type.full, p.solution = [' hell',p.current,' '];
        else, p.solution = ' hell ';
        end
        
    % check for the word a55
    elseif strcmpi(p.left.number,'55') && strcmpi(p.before,'a'),lgc = true;
        if p.type.full, p.solution = [' ass',p.current,' '];
        else, p.solution = ' ass ';
        end
    end
    
    % turn on remove past.
    if lgc, p.removePast = true; end
end

% converts numbers to letters
function word = slang_coverter(word)

word = strrep(word,'0','o');
word = strrep(word,'3','e');
word = strrep(word,'8','b');
word = strrep(word,'9','g');
word = strrep(word,'5','s');
word = strrep(word,'1','l');
word = strrep(word,'$','s');
word = strrep(word,'@','a');

end

% context concept analysis
function doc = context_concept(doc,change,new)

start_doc = doc;

doc = strrep(doc,[change,' '],[new,' ']);

if endsWith(doc,change)
    doc = [doc(1:end-numel(change)),new];
end

if ~strcmp(doc,start_doc)
   1; 
end

end

% Event Decoder ----------------------------------------
% -------------------------------------------------------

% and 1 decoder
function [p,lgc] = and1decoder(p,wrds)

lgc = false;

% basketball attire
if strcmp(p.before,'and')
    if strcmp(p.left.number,'1')
       if any(ismember(wrds,{'more','other','of','brand','competitors'}))
           p.removePast = true; lgc = true;
           p.solution = ' basketball sportswear ';
       end
    end
end
            
end

% world war decoder
function [p,lgc] = ww_decoder(p,wrds)

lgc = false;
if strcmp(p.before,'ww')
    if ismember({p.left.number},{'1','2','3'})
        if p.left.number == '1'
           year = 'one'; 
        elseif p.left.number == '3'
           year = 'three';
        else
           year = 'two';
        end
        if any(ismember(wrds,{'the','before','post','after','into'...
                              'to','of','during','in','what','tour',...
                              'airforce','army','men','loss',...
                              'save','for','yet','and','vet','history',...
                              'vietnam','german'}))
            lgc = true;
        else
            1;
        end
    end
end

if lgc
   p.removePast = true;
   p.solution = [' world war ',year,' '];
end
            
end

% setup government bill decoder
function p = govBillDecoder(p)
% flds = {p.beforelast,p.before,p.after,p.current,p.historic};
% wrds = {'proposed','propose','attempting','force','voted','vote',...
%         'under','vetting','of','voter','voters','how'};

% assume it is a government bill


p.removePast = true;

if strcmp(p.before,'sb')
    p.solution = ' senate legislation ';
else
    p.solution = ' hb legislation ';
end

end