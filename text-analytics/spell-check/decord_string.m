function [Cells,Word,Score] = decord_string(Word,h,s,T_Cor,THOR)
% node cell placement
% 1. full word
% 2. words to be expanded
% 3. all words good and bad found
% 4. good words
% 5. slang words
% 6. small words
% 7. bad words
% 8. performance
%
%
% Cases
% 1. decoded
% 2. good word
% 3. bad word


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
B.Ret_Cor = T_Cor;  % return if correct
B.T       = false;  % break down word slowly
B.theor   = THOR;




wd_base.info = cell(0,2);
wd_base.s    = [];
wd_base.id   = 0;
Cells  = {};
Score = 0;

nodes = {{},{Word},{},{},{},{},{},{}};
past  = cell(0,0);
k = 0;

while 1, k = k + 1;
    
    % basic logical arguments to continue or quit
    NUM_V = numel(nodes{1,2});
    if k > 400, Score = numel(Word); return, end
    if NUM_V == 0,node = nodes(1,:); break, end
    
    % check if word case has already been found
    if any(isfield(wd_base.s,nodes{1,2}))
        VE_I = isfield(wd_base.s,nodes{1,2});
        old_word = nodes{1,2}(VE_I);
        nodes{1,2} = nodes{1,2}(~VE_I);
        
        if numel(old_word) == 1
            vector = wd_base.s.(old_word{1});
            new_word = wd_base.info{vector(1)}; %#ok
            nodes = fill_Node(nodes,vector,old_word{1});
            continue
        else
            for i = 1:numel(old_word)
                vector = wd_base.s.(old_word{i});
                new_word = wd_base.info{vector(1)}; %#ok
                nodes = fill_Node(nodes,vector,old_word{i});
            end
            
            continue
        end
    end
    
    
    % if nodes exist then pop the item of the first expandable node
    if NUM_V == 1
        old_word = nodes{1,2}{1};
        nodes{1,2} = {};
    else
        old_word = nodes{1,2}{1};
        nodes{1,2} = nodes{1,2}(2:end);
    end
    
    
    % processes word.
    B.k = k; % store last value of B as k
    [new_word,p] = debugWord(h,old_word,s,B);
 
    if k == 1
        if p.correct
            B.T = true;
        end
    end
    
    if p.nodes % if word is found via a node.
        [nodes,past,wd_base] = pushNodes(nodes,wd_base,p.node_tbl,past,k);
        continue
    elseif p.decode % if word has been decoded
        if k == 1
            Cells = cellstr(new_word);
            Word = strjoin(cellstr(new_word));
            return
        end
        wd_base = addToBase(wd_base,{old_word,[],new_word},1);
        Data = getBase(wd_base,{old_word});
        nodes{1,1}(end+1) = Data{1,1};
        nodes{1,3}(end+1) = Data{1,1};
        nodes{1,5}(end+1) = Data{1,1};
        continue 
        
    elseif p.letter
        if k == 1
            Cells = cellstr(new_word);
            Word = strjoin(cellstr(new_word));
            return
        end
        
        wd_base = addToBase(wd_base,{old_word,[],new_word},4);
        Data = getBase(wd_base,{old_word});
        nodes{1,1}(end+1) = Data{1,1};
        nodes{1,3}(end+1) = Data{1,1};
        nodes{1,4}(end+1) = Data{1,1};
        nodes{1,8} = nodes{1,8} + .1;
        [~,idx] = sort([nodes{:,8}]);
        nodes = nodes(idx,:);
        
    elseif p.found % if the word has not been found add to trash
        if k == 1
            Cells = cellstr(new_word);
            Word = strjoin(cellstr(new_word));
            return
        end
        
        wd_base = addToBase(wd_base,{old_word,[],new_word},2);
        Data = getBase(wd_base,{old_word});
        nodes{1,1}(end+1) = Data{1,1};
        nodes{1,3}(end+1) = Data{1,1};
        nodes{1,4}(end+1) = Data{1,1};
        continue
    else % if word is trash
        if k == 1, Score = numel(Word); return, end
        wd_base = addToBase(wd_base,{old_word,[],new_word},3);
        Data = getBase(wd_base,{old_word});
        nodes{1,3}(end+1) = Data{1,1};
        nodes{1,7}(end+1) = Data{1,1};
        nodes{1,8} = nodes{1,8} + numel(old_word);
        [~,idx] = sort([nodes{:,8}]);
        nodes = nodes(idx,:);
        continue
    end
end




[Original,idx] = SortByLength(wd_base.info(node{1},2));

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

Cells = [wd_base.info{node{1}}];
Word = strjoin(Cells);


end

% sort cell array by length:
function [words,stringLength,L] = SortByLength(words)

[~,stringLength] = sort(cellfun(@length,words),'descend');
words = words(stringLength);

if nargout== 3
   L = cell2mat(cellfun(@(x) length(x),words,'un',0)); 
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

% add to base:
function wd_base = addToBase(wd_base,ND,K)

if nargin == 2
   K = 2; 
end

if isstruct(wd_base.s)
    ND = ND(~isfield(wd_base.s,ND(:,1)),:);
    if isempty(ND)
        return
    end
end

NUM = size(ND,1);
IDVEC = wd_base.id + (1:size(ND,1))';
wd_base.id = wd_base.id + NUM;

wd_base.info(IDVEC,1) = ND(:,3);
wd_base.info(IDVEC,2) = ND(:,1);


for i = 1:NUM
    wd_base.s.(ND{i,1}) = [IDVEC(i),K]; 
end

end

% get base:
function Data = getBase(wd_base,ND,ADD_Data)


if nargin == 3
    Data = cell(size(ND,1),2);
    for i = 1:length(ND)
        Data(i,:) = {[ADD_Data,wd_base.s.(ND{i})(1)],wd_base.s.(ND{i})(2)};
    end
else
    Data = cell(size(ND,1),2);
    for i = 1:length(ND)
        Data(i,:) = {wd_base.s.(ND{i})(1),wd_base.s.(ND{i})(2)};
    end
end


end

% push nodes
function [nodes,past,wd_base] = pushNodes(nodes,wd_base,ND,past,k)

node = nodes(1,:);
nodes(1,:) = []; % pop node




if k == 1
    wd_base = addToBase(wd_base,ND);
    Data = getBase(wd_base,ND(:,1));
    past = cellfun(@(x,y) [{x},y{:}],ND(:,1),ND(:,2),'un',0);
    past = cellfun(@(x) strjoin(sort(x)),past,'un',0);
    emp = cell(size(ND,1),4); % empty cells for bad/slang/score
    emp(:,end) = {0};
    nodes = [Data(:,1),ND(:,2),Data(:,1),Data(:,1),emp];
    return
end


wd_base = addToBase(wd_base,ND);
Data = getBase(wd_base,ND(:,1));
pt_new = cellfun(@(x) [x,node{3}],Data(:,1),'un',0);
pt_new = cellfun(@(x,y)[y{:},wd_base.info{x,1}],pt_new,ND(:,2),'un',0);
pt_new = cellfun(@(x) strjoin(sort([x,node{2}])),pt_new,'un',0);
I = ~ismember(pt_new,past);
ND = ND(I,:);
pt_new = pt_new(I);
past = [past;pt_new];



Data = getBase(wd_base,ND(:,1));
NND = cell(size(ND,1),8);
NND(:,1) = cellfun(@(x) [x,node{1}],Data(:,1),'un',0);
NND(:,2) = cellfun(@(x) [x,node{2}],ND(:,2),'un',0);
NND(:,3) = cellfun(@(x) [x,node{3}],Data(:,1),'un',0);
NND(:,4) = cellfun(@(x) [x,node{4}],Data(:,1),'un',0);
NND(:,5) = node(5); NND(:,6) = node(6); 
NND(:,7) = node(7); NND(:,8) = node(8);
nodes = [NND;nodes];


end
