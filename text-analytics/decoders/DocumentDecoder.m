classdef DocumentDecoder < WordDecoder & preDecoder & UrlDecoder & PatternDecoder
    % decode online-chat text into features which are able to be used.
    % 1. spell check and correction
    % 2. slang replacement
    % 3. numeric quanity replacement
    % 4. unit extrapolation
    % 5. thesaurus word replacement
    
    % properties setup
    properties
        T;
        serviceIQ = true;
        replaceDisp = true;
        youtubeTitle = true;
        keepIncorrect = true;
        
        
    end
    
    % user interface methods
    methods 
        
        % constructor method
        function obj = DocumentDecoder()
            
        end
        
        % decode word service
        function rev = decode(obj,document)
            
            % do not retain incorrect words
            obj.youtubeTitle  = true;
            obj.keepIncorrect = false;
            obj.smallWordLock = false;
            
            % decode any present url
            rev = obj.decode_url(document);
            
            % now retain incorrect words
            obj.keepIncorrect = true;
            obj.smallWordLock = true;
            
            % clean up words for last minute adjustments
            rev = obj.cleanup_word(rev);
            
            % decode full word
            rev = obj.decode_sentence(rev);
            
            % display end result
            dispBA(document,rev)
            
        end
       
        % save data table.
        function saveTable(obj,name,file)
            
            x = cellstr(obj.T.comment_text);
            writetable(obj.T,file,'Encoding','UTF-8');
            
            try
                y = cellstr(obj.T.website_links);
                z = cell(numel(x),1);
                for k = 1:numel(x)
                    if isempty(y{k}),  z{k} = x{k};  continue, end
                    z{k} = [x{k},' ',y{k}];
                end
            catch
                z = x;
            end
            
            % replace new lines
            for k = 1:numel(x)
                z{k} = strrep(z{k},newline,' ');
            end
            
            tbl = obj.T(:,'id');
            tbl.comment_text = z;
            tbl.comment_text = cellstr(tbl.comment_text);
            writetable(tbl,name,'Encoding','UTF-8');
        end
        
    end
    
    % new decoders
    methods
        % fit decoder
        function obj = fitSyntax(obj)
            
             
            % extract documents
            docs = obj.T.comment_text;
            n = numel(docs);
            
            
            % loop through data
            parfor k = 1:n
                docs{k} = obj.syntaxDecoderAlg(docs{k}); %#ok
            end
            
            % save data
            obj.T.comment_text = docs;
            
            
        end
        
        % fit decoder
        function obj = fitDemands(obj)
            
             
            % extract documents
            docs = obj.T.comment_text;
            n = numel(docs);
            
            
            % loop through data
            parfor k = 1:n
                docs{k} = obj.demandDecoderAlg(docs{k}); %#ok
            end
            
            % save data
            obj.T.comment_text = docs;
            
            
        end
        
        % fit Preprocessing Transformation
        function obj = fitPatterns(obj)
            
            
            % extract documents
            docs = obj.T.comment_text;
            n = numel(docs);
            
            
            % loop through data
            parfor k = 1:n
                docs{k} = obj.patternDecoderAlg(docs{k}); %#ok
            end
            
            % save data
            obj.T.comment_text = docs;
            
        end
        
    end
    
    % decoders
    methods
        
        % obtain URL links and data
        function obj = fitURL(obj)
            
            % setup settings
            obj.youtubeTitle  = true;
            obj.keepIncorrect = false;
            obj.smallWordLock = false;
            
            % set up document info
            docs = obj.T.comment_text;
            links = cell(numel(docs),1);
            links(:) = {''};
            media = links;
            n = numel(docs);
            

            x  = datetime('now');
            for k = 1:n
                printTime(x,k,n)
                [docs{k},links{k},media{k}] = obj.bc_decode_url(docs{k});
            end
            
            % save comments and website links
            obj.T.comment_text  = docs;
            obj.T.website_links = links;
            obj.T.media_text    = media;
        end
        
        % fit Preprocessing Transformation
        function obj = fitPreprocessing(obj,parallel)
            
            if nargin < 2, parallel = false; end
            
            % now retain incorrect words
            obj.keepIncorrect = true;
            obj.smallWordLock = true;
            
            % extract documents
            docs = obj.T.comment_text;
            n = numel(docs);
            
            if parallel
                parfor k = 1:n
                    docs{k} = obj.cleanup_word(docs{k});%#ok
                end
                
                obj.T.comment_text = docs;
                return
            end
            
            % obtain start time
            x  = datetime('now');
            
            for k = 1:n
                printTime(x,k,n)
                [docs{k},obj] = obj.cleanup_word(docs{k});
            end
            
            % save documents
            obj.T.comment_text = docs;
            
        end
        
        % fit decoder
        function obj = fitDecoder(obj)
            
            % now retain incorrect words
            obj.keepIncorrect = true;
            obj.smallWordLock = true;
            
            % extract data
            documents = obj.T.comment_text;
            n = numel(documents);
            
            % get current time
            x  = datetime('now');
            
            % % run algorithm
            for k = 1:n
                printTime(x,k,n) % print remaining time in algorithm
                documents{k} = obj.decode_sentence(documents{k});
            end
            
            obj.T.comment_text = documents;
            
        end
        
        
    end
    
    % standard methods
    methods
        
        % add update
        function [rev,p,obj] = uploadSolution(obj,rev,p,print,remSpaces)
            
            % remove spaces at the end
            if nargin < 100, remSpaces = false; end
            
            % check to remove past.
            if p.removePast
                rev = rev(1:end-numel(p.stack{end}));
                p.stack = p.stack(1:(end-1));
            end
            
            % check to remove past.
            if p.removePastLast && p.removePast
                rev = rev(1:end-numel(p.stack{end}));
                p.stack = p.stack(1:(end-1));
            elseif p.removePastLast
               error('Logic is wrong') 
            end
            
            % check to remove past.
            if p.removeHistoric && p.removePastLast && p.removePast
                rev = rev(1:end-numel(p.stack{end}));
                p.stack = p.stack(1:(end-1));
            elseif p.removeHistoric
               error('Logic is wrong') 
            end
            
            % retain old document string section
            if isempty(p.solution)
                p.stack{end+1} = [p.lead,p.current];
                rev = [rev,p.lead,p.current];
                return
            end
            
            % remove spaces at ending
            if remSpaces
                
                while 1
                    if p.solution(end) == ' '
                        p.solution = p.solution(1:(end-1));
                    else
                       break 
                    end
                end
                
                % set last new word to current
                split_solution = strsplit(p.solution);
                p.current = split_solution{end};
                error('failed')
            end
            
            % update stack
            p.stack{end+1} = p.solution;
            rev = [rev,p.solution]; 
            
            % print statement
            if print, printLast(rev); end
        end
        
        % decode sentances
        function rev = decode_sentence(obj,doc)
            
            % setup p structure
            p = getContext(doc,false);
            
            % return if only the word is present
            if p.n == 0,  rev = doc;  return, end
        
            % set reviewed text to the last word
            rev = p.current;
            k   = 0;
            
            
            % loop in all words
            while 1, k = k + 1;
                
                % check loop logic for break
                if k > p.n, break, end
                
                % setup word context and info.
                p = getContext(doc,k,p);
                rev = obj.review_word(p,rev);
            end
        end
        
        % review word
        function rev = review_word(obj,p,rev)
            
            % verify word needs to be decoded
            [word,correct,edit] = verify_word_unknown(obj,p.current,p);
             
            % correct word
            if correct
                rev = [rev,p.lead,word];
                if ~edit, return, end
                fprintf('REPLACED WORD: (%s <- %s) ',word,p.current)
                printLast(rev)
                return
                
            end
            
            
            
            
            % ADDED LOGIC ================
            if numel(p.current) < 5, rev = [rev,p.lead,word]; return, end
            
            
            
            past = p.current; % save backup of word
            word = obj.enhance(word,p); % enhance current word
            
            % correct word
            correct = strcmpi(strrep(word,' ',''),past);
            
            % return if word is correct
            if correct, rev = [rev,p.lead,p.current]; end
            
            % save word if found to be incorrect and small
            if numel(past) < 6, rev = [rev,p.lead,past]; return, end
            
            if numel(unique(past)) < 4 && numel(word) < 5
                fprintf('FAILED WORD: (%s <- %s) ',word,past)
                rev = [rev,p.lead,past]; 
                return
            end
            
            
            % replace incorrect word
            if ~correct && obj.replaceDisp 
                p.current = word;
                rev = [rev,p.lead,word];
                fprintf('INCORRECT WORD: (%s <- %s) ',word,past)
                printLast(rev)
            end
            
            % throw away if incorrect (used during url decoding)
            if ~obj.keepIncorrect && ~correct, rev = [rev,p.lead]; end
            
        end
        
        % verify unknown word
        function [word,correct,edit] = verify_word_unknown(obj,word,p)
        
            % assume the word is true.
            correct = true;
            edit = false;
            
            % check if word is member.
            ba_wrds = {p.before,p.after};
            
            % location state abv.
            if isfield(obj.s.us_states,word)
                if any(ismember(ba_wrds,obj.s.context.location))
                    word = obj.s.us_states.(word);
                    edit = true;
                    return
                end
            end
            
            % political short hand abv.
            if isfield(obj.s.politics,word)
                if any(ismember(ba_wrds,obj.s.context.politics))
                    word = obj.s.politics.(word);
                    edit = true;
                    return
                end
            end
            
            % political short hand abv.
            if strcmp('us',word)
                if ismember({p.before},{'the','is','are'})
                    word = 'usa';
                    edit = true;
                    return
                elseif ismember({p.after},{'relations','politics','political','Intervention'})
                    word = 'usa';
                    edit = true;
                    return
                end
            end
            
            % run through all cases now.
            if ismember({word},obj.s.newsNetworks)
                return
              
            % check for unknown slang.
            elseif ismember({word},obj.s.unknownSlang)
                return 
                
            % check if word in top or bottom words.
            elseif ismember({word},[obj.s.words_bot,obj.s.words_top'])
                return
                
            % check if all letters in word are m.
            elseif all(double(word) == 109) && numel(word) > 2
                word = 'okay i think i get it';
                return
            
            % check for slang heh.
            elseif isfield(obj.s.start_rep,word)
                word = obj.s.start_rep.(word);
                edit = true;
                return
                
            elseif ismember({word},obj.s.flags.id)
                word = char(obj.s.flags{word,'replace'});
                edit = true;
                return

            end
            
            % otherwise return false
            correct = false;
            
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

% Print remaining time in alg.
function printTime(x,k,n)

if rand > .0001, return, end
fprintf('%0.5f hours left \n',hours(((x -  datetime('now'))/k).*(k-n)))

end

% display before and after function
function dispBA(before,after)

before =  clean_out_word(before);

fprintf('%s  <- %s \n',after,before)

end

% get work ready to print out
function word =  clean_out_word(word)
    
    word = strrep(word,'?','');
    word = strrep(word,'â€"',' ');
    word = strrep(word,'â€?',' ');
    word = strrep(word,'â€œ',' ');
    word = strrep(word,'â€™','''');
    word = strrep(word,'â€”',' ');
    word = strrep(word,'â€”',' ');
    word = strrep(word,'â€¦',' ');
    word = strrep(word,'â€',' ');
    word = strrep(word,'â€?',' ');

    % remove bad letters
    word = strrep(word,'\n','');
    word = strrep(word,'\t','');
    word = strrep(word,'\','');
    
    word = sprintf('%s',word);
    
    word = regexprep(word,'[\n\r]+','');
    

end


