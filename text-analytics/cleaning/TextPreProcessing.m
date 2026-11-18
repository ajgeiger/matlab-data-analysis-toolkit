function [D,statTbl,PreTbl,PostTbl] = TextPreProcessing(D)

tic
[D,stat_wiki] = wikiCleanUp(D); % wiki clean words with WP:(string)
fprintf('Wiki Finished: %0.2f\n',toc')

tic
[D,stat_slang] = SlangCleanUp(D); % clean up slang
fprintf('Slang Finished: %0.2f\n',toc')


tic
[D,stats_wp] = switchoutWP(D); % clean up wp as wrong person.
fprintf('Switch WP Finished: %0.2f\n',toc')

tic
[D,PreTbl,PostTbl] = fixWords(D); % fix miss spelled words
fprintf('Fix Words Finished: %0.2f\n',toc')

tic
[D,bad_stats] = switchBadWordsLDA(D); % switch bad words.
fprintf('Switch Bad Words Finished: %0.2f\n',toc')


statTbl = [stat_wiki;stat_slang;stats_wp;bad_stats];

disp(statTbl)
fprintf('\n\n')


end


% Switch Wiki Words Out:
function [D,statTbl] = wikiCleanUp(D)

load WikiLoopUp.mat WikiLoopUp
[D,N] = strWordRep(D,WikiLoopUp.words,WikiLoopUp.meaning);
Total = sum(N);
Freq  = sum(N~=0);
Name = {'Wiki'};
statTbl = table(Name,Total,Freq);

end


% Switch Wiki Words Out:
function [D,statTbl] = SlangCleanUp(D)

load Slang_Table_clean.mat slang_table
[D,N] = strWordRep(D,slang_table.words,slang_table.meaning);

Total = sum(N);
Freq  = sum(N~=0);
Name = {'Slang'};
statTbl = table(Name,Total,Freq);

end


% Switch out WP:
function [D,statTbl] = switchoutWP(D)

[D,N] = ifStrAndNot(D,'wp','wp:',{'wrong person '});

Total = sum(N);
Freq  = sum(N~=0);
Name = {'WP_Replace'};
statTbl = table(Name,Total,Freq);

end


% Switch out WP:
function [D,statTbl] = switchBadWordsLDA(D)

words = {'fck','fuk','fuck','fucking','fucked','fcking','fuking'...
    'loser','you','bye','okay','hide',...
    'wrong','page','hang','yourself','gay','bitch','shit','cockface',...
    'dickface','penis','dickhead','cunt','whore','slut','fuckface',...
    'dckface','dckhead','queef','dicksucker','buttfucker',...
    'fcker','fucka','arsewipe'};

fixed = {'fuck','fuck','fuck','fucking','fucked','fucking','fucking'...
    'loser','you','bye','okay','hide',...
    'wrong','page','hang','yourself','gay','bitch','shit','cockface',...
    'dickface','penis','dickhead','cunt','whore','slut','fuckface',...
    'dckface','dckhead','queef','dicksucker','buttfucker',...
    'fucker','fucker','asswipe'};

for i = 1:length(words)
    
    [D,N] = fixBadWords(D,words{i},fixed{i});
    
    Total = sum(N);
    Freq  = sum(N~=0);
    Name = {strjoin({'WR',words{i}})};
    
    if i == 1
        statTbl = table(Name,Total,Freq); else
        statTbl = [statTbl;table(Name,Total,Freq)]; %#ok
    end
    
    fprintf('|\t switch %s Freq: %0.0f, Total %0.0f \n',words{i},Freq,Total)
    
end


end


% Base Functions:
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


% switch word for words in database:
function [D,N] = strWordRep(D,Words,Meaning)

sz = length(D);
N = zeros(sz,1);

parfor i = 1:sz
    [I,II] = ismember(D{i},Words); % try to find word
    if ~any(I),continue, end % join words go to next
    D{i}(I) = Meaning(II(I)); %#ok replace word with meaning
    D{i} = strsplit(strjoin(D{i}),' '); % join str
    N(i) = sum(I); % Solve for Sum of All Words
end


end


% correct abv. words:
function [D,N] = ifStrAndNot(D,Starts,Not,Switch)

sz = length(D);
N = zeros(sz,1);

parfor i = 1:sz
    % check if any words start with: Starts
    I = startsWith(lower(D{i}),Starts) & startsWith(lower(D{i}),Not);
    if ~any(I), continue, end % if none do continue
    D{i}(I)= strcat(Switch,cellfun(@(x) x(3:end),D{i}(I),'un',0));
    D{i} = strsplit(strjoin(D{i})); % join and resplit words
    N(i) = sum(I); % Solve for Sum of All Words
end


end


% correct pre and post duplicate words:
function [D,Pre_Table,Post_Table] = fixWords(D)
% LC = ismember(D{i},skip_list);
% SC = cellfun(@(x) h.CheckSpelling(x),D{i});
% SC = cellfun(@(x) h.CheckSpelling(x),D{i});
 
sz = length(D);
PreWords  = cell(sz,1);
PostWords = cell(sz,1);
PreList   = cell(0,0);
PstList  = cell(0,0);

parfor i = 1:sz
    if length(D{i}) == 1 && isempty(D{i}{1}), continue, end
    try % pre-word section
        
        WN = cellfun(@(x) double(lower(x)),D{i},'un',0);
        LC = cellfun(@(x) length(x),WN,'un',0);
        CN = cellfun(@(x) x(1) > 96 & x(1) < 123,WN,'un',0);
        WC = cellfun(@(x) sum(cumprod(x == x(1))),WN,'un',0);
        I = [LC{:}] > 3 & [CN{:}] & [WC{:}] > 1;
        if any(I)
            D{i}(I) = cellfun(@(x,y) x(y:end),D{i}(I),WC(I),'un',0);
            PreWords{i} = D{i}(I);
        end
        
        % post-word section
        WN = cellfun(@(x) double(lower(x)),D{i},'un',0);
        LC = cellfun(@(x) length(x),WN,'un',0);
        WC = cellfun(@(x) sum(cumprod(flip(x == x(end)))),WN,'un',0);
        CN = cellfun(@(x) x(end) > 96 & x(end) < 123,WN,'un',0);
        
        I = [LC{:}] > 3 & [CN{:}] & [WC{:}] > 2;
        if any(I)
            D{i}(I) = cellfun(@(x,y) x(1:end-y+1),D{i}(I),WC(I),'un',0);
            PostWords{i} = D{i}(I);
        end
    catch
        
    end
end

for i = 1:sz
    if ~isempty(PreWords{i}), PreList = [PreList,PreWords{i}]; end %#ok
    if ~isempty(PostWords{i}), PstList = [PstList,PostWords{i}]; end %#ok
end


Names ={'Word','Count','Percent'};
Pre_Table = cell2table(tabulate(PreList),'VariableNames',Names);
Post_Table = cell2table(tabulate(PstList),'VariableNames',Names);

end


% correct pre and post duplicate words:
function [D,N] = fixBadWords(D,B,New)
% LC = ismember(D{i},skip_list);
% SC = cellfun(@(x) h.CheckSpelling(x),D{i});
% SC = cellfun(@(x) h.CheckSpelling(x),D{i});


if nargin == 2, New = B; end
 
sz  = length(D);
New = cellstr(New);
B   = double(lower(B));
N   = zeros(sz,1);
FtL = B(1);
EtL = B(end);
parfor i = 1:sz
    if length(D{i}) == 1 && isempty(D{i}{1}), continue, end
    try % pre-word section
        
        WN = cellfun(@(x) double(lower(x)),D{i},'un',0);
        CN = cellfun(@(x) all(x > 96) & all(x < 123),WN,'un',0);
        FL = cellfun(@(x) x(1) == FtL,WN,'un',0);
        LL = cellfun(@(x) x(end) == EtL,WN,'un',0);
        WC = cellfun(@(x) all(ismember(x,B)),WN,'un',0);
        CW = cellfun(@(x) all(ismember(B,x)),WN,'un',0);
        
        I = ~ismember(lower(D{i}),New)&[CN{:}]&[WC{:}]&[CW{:}]&[FL{:}]&[LL{:}];
        D{i}(I) = New;
        N(i) = sum(I); % Solve for Sum of All Words
    catch
    end
end

end

