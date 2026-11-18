function [T,Feature_Space,statTbl] = cleanWords(T,col,NCol)

 % Data Prep:
 if nargin == 1, D = T; else
     if nargin == 2, NCol = col; end
     D = T.(col); % extract data
     D = processWords(D,'split'); % switch out words and fix spelling
 end
 

% Part I: Pre-process data & Basic Features -------------------------------
[D,RMTbl] = deleteWords(D);
[D,Feature_Space] = BasicFeatures(D);


% Part II: LDA Pre-Processing Functions -----------------------------------
fprintf('\nLDA Preprocessing:\n')
[D,statTbl] = TextPreProcessing(D);
statTbl = [statTbl;RMTbl];


% Part III: Pre-process data & Basic Features -----------------------------
D = processWords(D,'join');
if nargin ~= 1, T.(col) = D; end % reinsert data
D = processWords(D,'advsplit');


% Indepth Pre-Processing Functions ----------------------------------------
fprintf('\nAdvanced Preprocessing:\n')
[D,statTbl_new] = TextPreProcessing(D);
statTbl = [statTbl;statTbl_new];


% D: Advanced Features ----------------------------------------------------
fprintf('\nDerive Advanced Features:\n')
Feature_Space = [Feature_Space,deriveBadWordFeatures(D)];


% END: Obtain Data and Finish Processing:
if nargin ~= 1, T.(NCol) = D; % reinsert data
else, T = D; 
end

end


% Obtain Basic Features Functions:
% -------------------------------------------------------------------------


% Delete Words:
function [D,N] = delWords(D,B)
% LC = ismember(D{i},skip_list);
% SC = cellfun(@(x) h.CheckSpelling(x),D{i});
% SC = cellfun(@(x) h.CheckSpelling(x),D{i});

 
sz  = length(D);
N = zeros(sz,1);

parfor i = 1:sz
    if length(D{i}) == 1 && isempty(D{i}{1}), continue, end
    try % pre-word section
        I = startsWith(lower(D{i}),B)
        D{i}(I) = D{i}(I==0);
        N(i) = sum(I); % Solve for Sum of All Words
    catch
    end
end

end


% Delete Words:
function [D,statTbl] = deleteWords(D)

words = {'http://www','www.','http'};

for i= 1:length(words)
    [D,N] = delWords(D,words{i});
    
    Total = sum(N);
    Freq  = sum(N~=0);
    Name = {strjoin({'RM',words{i}})};
    
    if i == 1
        statTbl = table(Name,Total,Freq); else
        statTbl = [statTbl;table(Name,Total,Freq)]; %#ok
    end
end

end


% Basic Features:
function [D,Feature_Space] = BasicFeatures(D)

Feature_Space = countEndings(D);
Feature_Space = [Feature_Space,countUpper(D)];
Feature_Space = [Feature_Space,countLower(D)];

end


function F = deriveBadWordFeatures(D)


load bad_words_table.mat bad_words_table
load bad_word_features.mat varNames

BWs = bad_words_table.words;
WF = bad_words_table{:,varNames};

sz = length(D);
F = zeros(sz,length(varNames));

parfor i = 1:sz
    try
        if isrow(D{i}), D{i} = D{i}'; end
        F(i,:)= sum(cell2mat(cellfun(@(x) WF(ismember(BWs,x),:),D{i},'un',0))); %#ok
    catch
        
    end
end

F = array2table(F,'VariableNames',varNames);

end



% General Pre-Processing Functions:
% -------------------------------------------------------------------------


% Count Uppercase Letters:
function tbl = countUpper(D)

sz = length(D);
B = 65:80;
Uppercase  = zeros(sz,1);
parfor i = 1:sz
    
    WN = cellfun(@(x) double(x),D{i},'un',0);
    WC = cellfun(@(x) sum(ismember(x,B)),WN,'un',0);
    Uppercase(i) = sum([WC{:}]);
    
end

tbl = table(Uppercase);

end


% Count Lowercase Letters:
function tbl = countLower(D)

sz = length(D);
B = 97:122;
Lowercase  = zeros(sz,1);
parfor i = 1:sz
    
    WN = cellfun(@(x) double(x),D{i},'un',0);
    WC = cellfun(@(x) sum(ismember(x,B)),WN,'un',0);
    Lowercase(i) = sum([WC{:}]);
    
end

tbl = table(Lowercase);

end


% Count Endings:
function tbl = countEndings(D)

B = {'!','.','?',','};
Name = {'ExcMrk','period','question','comma'};
Array = zeros(length(D),length(B));

for i = 1:length(B)
    Array(:,i) = countLetters(D,B{i});
end

tbl = array2table(Array,'VariableNames',Name);
end


% Count Letters:
function tbl = countLetters(D,B)


sz  = length(D);
B   = double(B);
Uppercase   = zeros(sz,1);
parfor i = 1:sz
    
    WN = cellfun(@(x) double(x),D{i},'un',0);
    WC = cellfun(@(x) sum(ismember(x,B)),WN,'un',0);
    Uppercase(i) = sum([WC{:}]);
    
end

tbl = Uppercase;

end


% split word:
function D = processWords(D,T)

sz = length(D);
del  = {':',';','(',')','''',',','.','?','!',' '};

switch T
    case 'split'
        parfor i = 1:sz
            D{i} = strsplit(D{i},' '); % split str
        end
        
    case'join'
        parfor i = 1:sz
            D{i} = strjoin(D{i}); % split str
        end
        
        
    case 'advsplit'
        parfor i = 1:sz
            D{i} = strsplit(lower(D{i}));
            D{i} = unique(regexprep(erase(lower(D{i}),del),'[^a-z]+',''));
            D{i} = D{i}(~ismember(D{i},{''}));
        end
        
end
end
