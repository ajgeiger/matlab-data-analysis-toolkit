classdef UrlDecoder
    % Extract meaningful insights from url's the following code allows
    % users to obtain important information which may just be of use to you
    % in whatever you are attempting to doing.
    
    % Services for the class
    properties
        
    end
    
    % Decoding Methods
    methods
        
        % decode url
        function [rev,links,media] = bc_decode_url(obj,document)
            % Pass the document you wish to have decoded into the function.
            % Then let the algirithm work it's magic.
            
            % basic prep word which cannot exist in the sprintf format
            document = strrep(document,'\t',' ');
            document = strrep(document,'\n',' ');
            document = strrep(document,'\',' ');
            document = strrep(document,' u.s. ','usa');
            document = sprintf(document);
            
            % identification keys for a website
            validKeys = {' :www.',' www.','.com ','.org ','.edu/',...
                         '.com/','.ca/','.org/','.edu ','http://',...
                         'https://'};
                     
            links = '';
            media = '';
            
            % identify and fix urls
            if any(contains(lower(document),validKeys))
                
               % decrypt hidden text
               document = textCipher(document);
               
               % break apart document to extract url
               words = strsplit(document);
               rev = '';
               
               % search for url
               for k = 1:numel(words)
                   if any(contains(lower(words{k}),validKeys))
                       % check and find youtube title
                       
                       % extrack word
                       url_word = words{k};
                       
                       % check twitter link
                       [info,twitter_lgc,addon] = addTwitterRead(url_word);
                       
                       if twitter_lgc
                           links = [links,' ',addon];  %#ok
                           media = [media,' ',info,' '];  %#ok
                           printLast(media);
                           continue
                       end
                       
                       
                       
                       % check for bitly
                       [info,lgc,failed] = checkbitly(url_word);
                       
                       if failed
                           links = [links,' ',words{k}]; %#ok
                          continue
                          
                       elseif lgc
                           links = [links,' ',words{k}];    %#ok
                           media   = [media,' ',info,' '];  %#ok
                           printLast(media);
                           continue
                       else
                          url_word = info; 
                       end
                       
                       
                       % check for youtube title links
                       if obj.youtubeTitle
                            
                           % youtube titles
                           [info,lgc,addon] = addYoutubeTitle(url_word);
                           
                           if lgc
                               links = [links,' ',addon];  %#ok
                               media = [media,' ',info,' '];  %#ok
                               printLast(media);
                               continue
                           end
                       end
                       
                       links = [links,' ',words{k}]; %#ok
                       continue
                   end
                   
                   rev = [rev,' ',words{k}];%#ok
               end
               
            % if no url is present return the original document
            else
               rev = document; 
            end
        end
        
        % decode url
        function rev = decode_url(obj,document)
            % Pass the document you wish to have decoded into the function.
            % Then let the algirithm work it's magic.
            
            % basic prep word which cannot exist in the sprintf format
            document = strrep(document,'\t',' ');
            document = strrep(document,'\n',' ');
            document = strrep(document,'\',' ');
            document = strrep(document,' u.s. ','usa');
            document = sprintf(document);
            
            % identification keys for a website
            validKeys = {' :www.',' www.','.com ','.org ','.edu/',...
                         '.com/','.ca/','.org/','.edu ','http://',...
                         'https://'};
            
            % identify and fix urls
            if any(contains(lower(document),validKeys))
                
               % break apart document to extract url
               words = strsplit(document);
               rev = '';
               
               % search for url
               for k = 1:numel(words)
                   if any(contains(lower(words{k}),validKeys))
                       % check and find youtube title
                       
                       % extrack word
                       url_word = words{k};
                       
                       % check for bitly
                       [url_word,lgc,failed] = checkbitly(url_word);
                       
                       if failed
                          rev = [rev,' urlbrokenflag websitelinkflag ',url_word];%#ok  
                          continue
                       end
                       
                       if ~any(contains(lower(url_word),validKeys))
                           if lgc
                              if contains(url_word,'websitelinkflag')
                                 rev = [rev,url_word];%#ok
                              else
                                 rev = [rev,' websitelinkflag ',url_word];%#ok 
                              end
                           end
                           continue
                       end
                       
                       % check for youtube title links
                       if obj.youtubeTitle
                            
                           % youtube titles
                           url_word = addYoutubeTitle(url_word);
                       end
                       
                       % URL Split
                       url_word = url_cleanup_fun(obj,url_word);
                       
                       % check for context requirement
                       if numel(strsplit(url_word)) < 6
                          
                       end
                       
                       disp([url_word,' <- ',words{k}])
                       
                       % add final url
                       
                       if contains(url_word,'websitelinkflag')
                         rev = [rev,' ',url_word];%#ok
                       else
                         rev = [rev,' websitelinkflag ',url_word];%#ok 
                       end
                       
                       continue
                   end
                   
                   rev = [rev,' ',words{k}];%#ok
               end
               
            % if no url is present return the original document
            else
               rev = document; 
            end
        end
        
        % Attempt to extract more meaning
        function [url_word,lgc] = attemptExtraction(obj,url)
            
            url_word = '';
            lgc      = false;
            
            
            try 
                try
                    url_word = webread(url);
                catch
                    url_word = webread(url(1:end-1));
                end
            catch
                return
            end
            url_word = extractHTMLText(url_word);
            cleanTextData = erasePunctuation(url_word);
            documents = tokenizedDocument(cleanTextData);
            bag = bagOfNgrams(documents,'NGramLengths',3);
            
            figure
            wordcloud(bag);
            lgc = true;
            url_word = url_cleanup_fun(obj,url_word);
        end
        
        % URL Cleanup
        function url_word = url_cleanup_fun(obj,url_word)
            
            % set all characters to lowercase 
            url_word = lower(url_word);

            % check if news outlet is present
            url_word = news_outlet(url_word);

            % replace url information
            url_word = obj.url_replacement(url_word);

            % pre-word cleanup
            url_word = pre_url_cleanup(url_word);

            % decode end of word url
            url_word = end_url_cleanup(url_word);
        end
            
        % decode url document
        function wd = url_replacement(obj,wd)
            
            % url decoded domain ending location
            if contains(wd,'.gov')  || contains(wd,'.us/') 
                if contains(wd,'state.')
                    
                    % replace state name type where as ex (state.ny)
                    for k = obj.s.state_abv

                        % valid keys
                        key = ['state.',k{1}];

                        % check for state
                        if ~any(contains(wd,key)), continue, end

                        % replace state name
                        wd = strrep(wd,key,[obj.s.all_states.(k{1}),' state.']);
                        return
                        
                    end
                    
                else

                    % replace state name whereas (/ny/)
                    for k = obj.s.state_abv
                        key = ['/',k{1},'/'];
                        wd = strrep(wd,key,['/',obj.s.all_states.(k{1}),'/']);
                    end
                end
            end
            
            % setup safe and unsafe websites (all are to be safe in this
            % current version. However next version these values may change
            % depending on the end results.
            safe_website     = ' websitelinkflag ';
            not_safe_website = ' websitelinkflag ';
            
            % url info
            wd = strrep(wd,'/cv/','/');
            wd = strrep(wd,'/sp/','/');
            wd = strrep(wd,'/oct/','/october/');
            wd = strrep(wd,'/nov/','/november/');
            wd = strrep(wd,'/sept/','/september/');
            wd = strrep(wd,'/apr/','/april/');
            wd = strrep(wd,'/aug/','/augest/');
            wd = strrep(wd,'/mar/','/march/');
            wd = strrep(wd,'/2016/','/election year/');
            wd = strrep(wd,'/2017/','/after election/');
            wd = strrep(wd,'/dmv/','/driver motor vehicle/');
            wd = strrep(wd,'/dp/','/display picture/');
            wd = strrep(wd,'/docs/','/documents/');

            % look for search
            wd = strrep(wd,'/search?q=/',' search for ');
            wd = strrep(wd,'/search?q/',' search for ');
            wd = strrep(wd,'/watch?v=/',' watch video ');
            wd = strrep(wd,'search?q=',' search for ');
            wd = strrep(wd,'search?q',' search for ');
            wd = strrep(wd,'watch?v=',' watch video ');

            
            % exchange url endings websites
            wd = strrep(wd,'.com/'  ,' commercial website/');
            wd = strrep(wd,'.org/'  ,' organization website/');
            wd = strrep(wd,'.gov/'  ,' government website/');
            wd = strrep(wd,'.ru/'   ,' russia website/');
            wd = strrep(wd,'.ca/'   ,' canadian website/');
            wd = strrep(wd,'.edu/'  ,' educational website/');
            wd = strrep(wd,'.us/'   ,' usa/');
            wd = strrep(wd,'.net/'  ,' netword website/');
            wd = strrep(wd,'.co.uk/',' global international united kingdom website/');
            wd = strrep(wd,'.co/'   ,' global international website/');
            wd = strrep(wd,'.ie/'   ,' ireland website/');
            
            
            % exchange url endings important websites
            wd = strrep(wd,'.com '  ,' commercial website ');
            wd = strrep(wd,'.org '  ,' organization website ');
            wd = strrep(wd,'.gov '  ,' usa government website ');
            wd = strrep(wd,'.ru '   ,' russia website ');
            wd = strrep(wd,'.ca '   ,' canadian website ');
            wd = strrep(wd,'.edu '  ,' educational website ');
            wd = strrep(wd,'.net '  ,' netword website ');
            wd = strrep(wd,'.co.uk ',' global international united kingdom website');
            wd = strrep(wd,'.co '   ,' global international website');
            wd = strrep(wd,'.ie '   ,' ireland website');
            % url prefix
            wd = strrep(wd,'https://lh5.',safe_website);
            wd = strrep(wd,'https://www.',safe_website);
            wd = strrep(wd,'http://www.',not_safe_website);
            wd = strrep(wd,'www.',not_safe_website);
            wd = strrep(wd,'http://',not_safe_website);
            wd = strrep(wd,'https://',safe_website);
            wd = strrep(wd,'-',' ');
            wd = strrep(wd,'_',' ');
            wd = strrep(wd,'''','');
            wd = strrep(wd,'`','');
            
        end
        
    end
end


% print context of word
function printLast(rev)

past = 70;

start = max(numel(rev)-past,1);
rev = rev(start:end);

fprintf('%s \n',rev)


end



% after web read has been done first attempt to pull data
function [url_word,lgc] = standard_scrape(info)

lgc = false;

% If no youtube link is present look for the title
new = strsplit(info,'<meta property="og:title" content="');

% if title not found look for "Title" with a capitial T
if numel(new) == 1,  new = strsplit(info,'<meta property="og:Title" content="'); end

% If title found look for description
if numel(new) > 1

   % clean up word
   new_add = strsplit(new{2},'/>');

   % try new split if last failed
   if numel(new_add) == 1, new_add = strsplit(new{2},'">'); end

   % try new split if last failed
   if numel(new_add) == 1, new_add = strsplit(new{2},'>');  end

   % if all attempts failed pull the rip coard
   if numel(new_add) == 1, return, end

    new_add = new_add{1};

  % check if description of article exists
   new = strsplit(info,'<meta property="og:description" content="');

   % if not found look for "Description" with a capital D
   if numel(new) == 1,  new = strsplit(info,'<meta name="Description" content="'); end

   % return if new is cell one
   if numel(new) == 1, return, end

   % split string based on spaces
   ls_new = strsplit(new{2},'/>');

   % try new split if last failed
   if numel(ls_new) == 1, ls_new = strsplit(new{2},'">'); end

   % try new split if last failed
   if numel(ls_new) == 1, ls_new = strsplit(new{2},'>');  end

   % if all attempts failed pull the rip coard
   if numel(ls_new) == 1, return, end

   % extract the key word
   ls_new = ls_new{1};

   % lock check
   lockCheck = {'<meta property=','<meta name="google"'};
   
   % one last safty check we can never be to careful
   if contains(ls_new,lockCheck)
       ls_new = strsplit(ls_new,'>');
       if numel(ls_new) == 1, return, end
       ls_new = ls_new{1};
   end

   % one last safty check we can never be to careful
   if contains(new_add,lockCheck)
       new_add = strsplit(new_add,'>'); 
       if numel(new_add) == 1, return, end
       new_add = new_add{1};
   end
   
    % clean ending of description
    if endsWith(ls_new,'...')
        ls_new = strsplit(ls_new);
        ls_new = strjoin(ls_new(1:end-1));
    end

   url_word = ['title ',new_add,' description ',ls_new]; 
   lgc = true;
   return
      
end


end

% next scrape function
function [url_word,lgc] = next_scrape(info)

lgc = false;

% If no title is found look for a header
new = strsplit(info,'<!--Header-->');
if numel(new) > 1
	return 
end

% if found look for the end of a header
new = strsplit(new{2},'<!--EndHeader-->');
if numel(new) > 1
    url_word = new{1};
    url_word = strrep(url_word,'</h1>','');
    url_word = strrep(url_word,'<h1 align="center">','');
    url_word = strrep(url_word,'<h1 align="left">','');
    url_word = strrep(url_word,'<h1 align="right">','');
    url_word = strrep(url_word,'<h1 align="justify">','');
    lgc = true;
    return
end


end

% attempt to decode bit.ly and tinyurl website adresses
function [url_word,lgc,found] = checkbitly(url_word)
% The following will be returned
% 1. original web adress
% 2. failed web adress (of target site, this is good)
% 3. youtube link
% 4. title and description info

lgc = false;
found = false;
% read in a bit.ly website adress
if contains(url_word,{'/bit.ly/','tinyurl','/gee.su/'})
   
   try
       if url_word(end) == '.'
           url_word = url_word(1:end-1);
       end
       
        % The following will extract a youtube link.
        info = webread(url_word);
        new = strsplit(info,' <meta property="og:url" content="');
        if numel(new) > 1
           new = strsplit(new{2},'">');
           url_word = new{1}; 
           return
        else
            
            % perform a standard scrape
           [url_word,lgc] = standard_scrape(info);
           
           % return if standard scrape had worked
           if lgc,  url_word = extractHTMLText(url_word); return,  end
           
           % if the standard scrape failed attemp the next scrape.
           [url_word,lgc] = next_scrape(info);
           
           % return if standard scrape had worked
           if lgc,  url_word = extractHTMLText(url_word); return,  end
           
        end
    catch ME
        
        % Try to extract old URL link
        new = strsplit(ME.message,' in response to the request to URL ');
        if numel(new) > 1
           url_word = new{2}; 
        else
           found = true; 
        end
   end 
end

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


% Website Decoder Outlet ------------------------------
% -----------------------------------------------------

% news outlet replacement
function document = news_outlet(document)


% potential important url information
document = strrep(document,newline,'');
document = strrep(document,'Â­','');
document = strrep(document,'://en.m.','://english mobile access.'); 
document = strrep(document,'/?q=','/search '); 
document = strrep(document,'://m.','://mobile access.'); 
document = strrep(document,'/quiz/','/participate quiz test evaluation/');
document = strrep(document,'/item/','/');
document = strrep(document,'/usa/','/united states of america/'); 
document = strrep(document,'/2016/','/presidential election year trump/');
document = strrep(document,'amchamhkpublications','publications');
document = strrep(document,'/?sk=','/');



% USA Government Websites
document = strrep(document,'bls.gov','informationflag usa for americans with disabilities act.gov'); 
document = strrep(document,'cdc.gov','informationflag usa centers for disease control and prevention.gov');
document = strrep(document,'gao.gov','informationflag usa government accountability office.gov');
document = strrep(document,'fbi.gov','informationflag usa federal bureau of investigation.gov'); 
document = strrep(document,'cia.gov','informationflag usa central intelligence agency.gov'); 
document = strrep(document,'bea.gov','informationflag usa bureau of economic analysis.gov');
document = strrep(document,'dol.gov','informationflag usa department of labor.gov'); 
document = strrep(document,'bls.gov','informationflag usa bureau of labor statistics.gov'); 
document = strrep(document,'census.gov','informationflag usa census bureau.gov'); 
document = strrep(document,'irs.gov','informationflag usa internal revenue service.gov'); 

% Basic webpages
document = strrep(document,'opb.org','oregon public broadcasting opb.org');
document = strrep(document,'redcross','humanitarian aid redcross');
document = strrep(document,'answers.yahoo','socialflag opinion facts answers yahoo');

% Media & Search Engines Websites
document = strrep(document,'tinyurl.com','unknown url tinyurl.com'); 
document = strrep(document,'yahoo','search engine yahoo'); 
document = strrep(document,'youtube','video media youtube'); 
document = strrep(document,'wikipedia','informationflag wikipedia'); 
document = strrep(document,'tumblr','leftnewsflag media tumblr website'); 
document = strrep(document,'google.com','search engine google.com'); 
document = strrep(document,'facebook','socialflag facebook'); 
document = strrep(document,'twitter','socialflag twitter');
document = strrep(document,'reddit','socialflag reddit');
document = strrep(document,'bing.com','search engine website bing.com'); 
document = strrep(document,'amazon.com','online store amazon.com'); 
document = strrep(document,'linkedin','socialflag job professional');
document = strrep(document,'soundcloud','audio media songs artist website');
document = strrep(document,'.wix.com',' unknown website wix.com');
document = strrep(document,'awsamazon','amazon web services hosting');
document = strrep(document,'paypal.com','online payment agency paypal.com');

% major news outlets
document = strrep(document,'www.cnn','www.farleftnewsflag network cnn');
document = strrep(document,'foxnews','rightnewsflag news network foxnews'); 
document = strrep(document,'cbsnews','farleftnewsflag network cbsnews'); 
document = strrep(document,'cnbc','farleftnewsflag network cnbc');
document = strrep(document,'abcnews','leftnewsflag news network abcnews');
document = strrep(document,'vice','farleftnewsflag network vice');
document = strrep(document,'khon2','local news hawaii khon2');

% newspaper
document = strrep(document,'nytimes','centernewsflag newspaper nytimes'); 
document = strrep(document,'latimes','leftnewsflag newspaper latimes');
document = strrep(document,'nypost.com','leftnewsflag newspaper nypost.com');
document = strrep(document,'wsj.com','farleftnewsflag newspaper wsj.com');
document = strrep(document,'adn.com','anchorage daily news newspaper alaska adn.com');

% Magaizine
document = strrep(document,'nymag.com','farleftnewsflag magazine nymag.com');
document = strrep(document,'gq.com','left news magazine gq.com');
document = strrep(document,'time.com','farleftnewsflag magazine time.com');
document = strrep(document,'vanityfair.com','farleftnewsflag magazine time.com');

% less known news outlets
document = strrep(document,'breitbart','farrightnewsflag outlet breitbart'); 
document = strrep(document,'infowars','farrightnewsflag outlet infowars'); 
document = strrep(document,'dailycaller','rightnewsflag outlet dailycaller');
document = strrep(document,'thefederalist','rightnewsflag outlet thefederalist'); 

document = strrep(document,'salon','farleftnewsflag outlet salon'); 
document = strrep(document,'kezi.com','farleftnewsflag opinion news outlet kezi.com');
document = strrep(document,'politicususa.com','extreme farleftnewsflag opinion news outlet politicususa.com');
document = strrep(document,'worldcitizen','farleftnewsflag outlet worldcitizen'); 
document = strrep(document,'globalcitizen','farleftnewsflag outlet globalcitizen'); 
document = strrep(document,'change.org','farleftnewsflag activist news outlet change.org'); 
document = strrep(document,'dailybeast','farleftnewsflag news outlet dailybeast'); 
document = strrep(document,'nakedcapitalism','farleftnewsflag socialism news outlet nakedcapitalism'); 
document = strrep(document,'msn.com','leftnewsflag outlet msn.com');
document = strrep(document,'huffingtonpost','left news outlet huffingtonpost'); 
document = strrep(document,'ted.com','leftnewsflag left news information ted.com');

document = strrep(document,'www.wweek.com','portland news outlet wweek.com');
document = strrep(document,'debunkingportland.com','news outlet debunkingportland.com');
document = strrep(document,'theblaze','center right news outlet theblaze'); 
document = strrep(document,'cashapp24','spamwebsite'); 
document = strrep(document,'.rt.com','.centernewsflag outlet.com');


% Potlitical
document = strrep(document,'teaparty','rightnewsflag teaparty');
document = strrep(document,'trump.com','rightnewsflag president policy trump.com');
document = strrep(document,'wikileaks','informationflag expose uncover truth offical material wikileaks'); 
document = strrep(document,'peninsuladailynews.com','centernewsflag peninsula daily news peninsuladailynews.com');
document = strrep(document,'thenation.org','farleftnewsflag media thenation.org');
document = strrep(document,'ppic.org','farleftnewsflag media ppic.org');
document = strrep(document,'democracynow.org','farleftnewsflag media.org');
document = strrep(document,'clintonfoundation','leftnewsflag outlet clinton foundation');
document = strrep(document,'protectthepfd','leftnewsflag alaska politics democrat'); 
document = strrep(document,'aljazeera','leftnewsflag aljazeera');
document = strrep(document,'politico','leftnewsflag network politics politico');
document = strrep(document,'pbs.com','leftnewsflag network public broadcast station pbs.com');
document = strrep(document,'hillaryclinton.com','leftnewsflag political hillary clinton hillaryclinton.com');
document = strrep(document,'berniesanders.com','leftnewsflag political socialism berniesanders.com');

% Other
document = strrep(document,'ncaa.com','college sports national championships ncaa.com'); 
document = strrep(document,'phys.com','physics.com'); 
document = strrep(document,'gofundme.com','request money support aid gofundme.com'); 
document = strrep(document,'www.monster.com','www.job search engine.com');
document = strrep(document,' nfl ',' leftnewsflag sports national football ');
document = strrep(document,'nfl.com','leftnewsflag sports national football.com');
document = strrep(document,'/nfl/','/leftnewsflag sports national football/');

% finacial and factual
document = strrep(document,'snopes','informationflag centernewsflag facts outlet snopes');
document = strrep(document,'reuters','informationflag centernewsflag facts outlet reuters');
document = strrep(document,'factcheck','informationflag centernewsflag facts factcheck');
document = strrep(document,'fivethirtyeight','informationflag centernewsflag information facts fivethirtyeight');
document = strrep(document,'forbes','informationflag economicnewsflag outlet forbes.com'); 
document = strrep(document,'bloomberg','informationflag economicnewsflag outlet bloomberg.com'); 
document = strrep(document,'marketwatch','informationflag economicnewsflag outlet marketwatch');
document = strrep(document,'ford.com','automotive industry car company ford.com');
document = strrep(document,'cnet.com','informationflag review technology news cnet.com');
document = strrep(document,'bizjournals.com','informationflag economicnewsflag business journals bizjournals.com');

% Non-sense websites
document = strrep(document,'urbandictionary','extremeflag red flag toxic harmful urban dictionary urbandictionary');
document = strrep(document,'buzzfeed','extremeflag farleftnewsflag buzzfeed');
document = strrep(document,'rawstory.com','extremeflag farleftnewsflag opinion news rawstory.com');
document = strrep(document,'alternet.com','extremeflag farleftnewsflag opinion news alternet.com');
document = strrep(document,'washingtonpost','extremeflag farleftnewsflag opinion news paper washingtonpost');
document = strrep(document,'thinkprogress.com','extremeflag farleftnewsflag opinion news.com');
document = strrep(document,'yournewswire.com','extremeflag farrightnewsflag opinion news.com');
document = strrep(document,'michaelparenti.com','extremeflag farleftnewsflag socialism michael parenti.com');
document = strrep(document,'addictinginfo.com','extremeflag farleftnewsflag outlet addictinginfo.com');
document = strrep(document,'forcedfluoridationfreedomfighters.com','extremeflag farleftnewsflag activist australia propaganda forcedfluoridationfreedomfighters.com');
document = strrep(document,'/bit.ly/',' bitly unknown website ');
document = strrep(document,'http://owl.li/',' owlli unknown website ');


% school websites
document = strrep(document,'ucla','far left university of california ucla');
words    = strsplit(document,'/');

if numel(words) > 1
    if numel(regexprep(words{end},'[^a-z]+','')) < 5
        document = [strjoin(words(1:end-1),'/'),'/'];
    end
end


end

function words = repWords(words,given,change)
words(ismember(words,given)) = {change};
end

% end of url cleanup replacement
function document = end_url_cleanup(document)

% clean up document
document = strrep(document,' p ',' page ');
document = strrep(document,' en ',' english ');
document = strrep(document,' vs ',' versus ');
document = strrep(document,' app ',' application ');
document = strrep(document,' utils ',' utilities ');
document = strrep(document,' util ',' utility ');
document = strrep(document,' wordpress ',' unknown unverified website ');
document = strrep(document,'aspxrp','');

% Find key words
words = strsplit(document);
words = repWords(words,{'faqs','faq'},'frequently asked questions');
words = repWords(words,{'pdf','doc','docs'},'document');
words = repWords(words,{'html','php','htm'},'article');
words = repWords(words,{'png','jpeg','jpg','gif'},'picture');
words = repWords(words,{'en'},'english');
words = words(~ismember(words,{'','http','https','www','website','href','asp'}));
I = cell2mat(cellfun(@(x)numel(x),words,'UniformOutput',false));
words = words(I > 1 | ismember(words,{'a','i','u'}));

document = strjoin(words);

% Find Other words
document = correct_gdp(document);

end

% end of url cleanup replacement
function rev = pre_url_cleanup(document)

document = strrep(document,'?','');
document = strrep(document,'â€"',' ');
document = strrep(document,'â€?',' ');
document = strrep(document,'â€œ',' ');
document = strrep(document,'â€™','''');
document = strrep(document,'â€”',' ');
document = strrep(document,'â€”',' ');
document = strrep(document,'â€¦',' ');
document = strrep(document,'â€',' ');
document = strrep(document,'â€?',' ');
document = strrep(document,'â€œ','');


document = strrep(document,']','');
document = strrep(document,'[','');
document = strrep(document,'/',' ');
document = strrep(document,'\',' ');
document = strrep(document,'''','');
document = strrep(document,'-',' ');
document = strrep(document,'_',' ');
words    = strsplit(document);


rev = '';
for k = 1:numel(words)
   start = regexp(words{k},'[0-9]','start');
   e = regexp(words{k},'[0-9]','end');
   if numel(start) == 0
       rev = [rev,' ',words{k}]; %#ok
   elseif numel(start) == 1 && (start(1) == 1 || e(1) == numel(words{k}))
       rev = [rev,' ',words{k}]; %#ok
   end
end

% clean out word
rev =  clean_out_word(rev);

% get rid of special characters
rev = regexprep(rev,'[^a-z]+',' ');

% split word
rev = strsplit(rev);

% remove n-repeat spaces
rev = cleanup_string(rev);

end

% add twitter read
function [document,lgc,addon] = addTwitterRead(url)

% setup add on
addon = 'https://www.twitter.com/';
document    = '';
twitterlink = '';

%lgc2 = false;
lgc = false; 
if contains(url,'twitter.com/')
    lgc = true; 
    twitterlink = strsplit(url,'twitter.com/');
    if numel(twitterlink) == 2 
        twitterlink = ['https://www.twitter.com/',twitterlink{2}]; 
        [title,lgc_found] = twitter_url_read(twitterlink); 
        lgc = true;
    end
end

% add hashtag
if contains(twitterlink,'/hashtag/')
    addon = twitterlink;
    twitterlink = strsplit(url,'/hashtag/');
    if numel(twitterlink) == 2 
        title = [title,' ',twitterlink{2}];
    end
end



    
if lgc
    if ~lgc_found
        title = ' the twitter link was broken '; 
    end
    document = lower(title);
end


end

% obtain youtube title
function [document,lgc,addon] = addYoutubeTitle(document)

% setup add on
if 1 == 2, addon = 'websitelinkflag youtube ';
else,      addon = 'https://www.youtube.com/';
end

%lgc2 = false;
lgc = false; 
if contains(document,'youtube.com/watch?')
    lgc = true; 
    youstr = strsplit(document,'youtube');
    if numel(youstr) == 2 
        youlink = ['https://www.youtube',youstr{2}]; 
        [title,~,bk] = getYoutubeTitle(youlink); 
        lgc = true;
    end
elseif contains(document,'youtu.be/')
    youstr = strsplit(document,'youtu.be/');
    if numel(youstr) == 2
        youlink = ['https://youtu.be/',youstr{2}];  
        [title,~,bk] = getYoutubeTitle(youlink); 
        lgc = true;
    end
end



    
if lgc
    if bk
        title = ' the video link was broken '; 
    end
    document = lower(title);
end

end

% correct for GDP (generally used by url cleanup)
function document = correct_gdp(document)

document = strrep(document,'gdp in','gross domestic product gdp by');
document = strrep(document,'gdp by','gross domestic product gdp by');
document = strrep(document,'gdp from','gross domestic product gdp from');
document = strrep(document,'gdp of','gross domestic product gdp of');
document = strrep(document,' past gdp ',' past gross domestic product gdp ');
document = strrep(document,' of gdp ',' of gross domestic product gdp ');
document = strrep(document,' real gdp ',' real gross domestic product gdp ');
document = strrep(document,' us gdp ',' united states gross domestic product gdp ');
document = strrep(document,' gdp growth ',' gross domestic product gdp growth ');
document = strrep(document,' gdp ppp ',' gdp purchasing power parity');

end



% TOP = 'Please click here if you are not redirected within a few seconds.';
% KEY = 'Google SearchSearch Images Maps Play YouTube News Gmail';
% url_word = extractHTMLText(url_word);
% new = strsplit(new{2},KEY);
% if numel(new) == 1,  return, end
% new = strsplit(new{1},TOP);
% if numel(new) == 1, return,  end
% url_word = url_word{1};
% lgc = true;
           