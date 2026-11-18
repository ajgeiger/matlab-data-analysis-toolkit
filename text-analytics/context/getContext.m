function p = getContext(doc,k,p)
% Setup the structure for providing context to the word. Rather store the
% words around the word.
%
% none - no numbers present
% full - the lead is all numbers
% right - right structure
%
% right fields
%   specialKey = does the number start with a key ex. $ or #

p.solution   = '';
p.revision   = false;

p.removePast     = false;
p.removePastLast = false;
p.removeHistoric = false;

% setup type cases
p.type.left  = false;
p.type.right = false;
p.type.full  = false;
p.type.none  = false;
p.right.number = '';
p.left.number  = '';


% Setup structure if no inputs present
if nargin < 3
    
    % run calculations
    [p.start,p.end] = regexp(doc,'[^a-z]+','start','end');
    p.n = numel(p.start);
    p.after      = '';    % word after current
    p.current    = '';
    p.before     = '';    % current word
    p.beforelast = '';    % word before last
    p.historic   = ''; 
    p.lead       = ''; 
    p.lgc        = false; % skip next future word
    p.exit       = false;
    p.stack      = {};
    p.numericService = true;
    if nargin == 2, p.numericService = k; end
    
    % check to add before if exists
    if p.n>0,if p.start(1) > 1,p.current=doc(1:p.start(1)-1); end, end
    p.stack = {p.current};
    return
    
end

% look to see if a next word exist if so save to after
if k+2 <= numel(p.start)
    p.after  = doc(p.end(k+1)+1:p.start(k+2)-1);
else
    p.after = '';
end

% generate previous and current words
if k > 2, p.historic = p.beforelast; end
if k > 1, p.beforelast = p.before;   end
if k > 0, p.before = p.current;      end


% Get leading information
p.lead = doc(p.start(k):p.end(k));  % slang leading up to word

if k < p.n
    word = doc(p.end(k)+1:p.start(k+1)-1); % the current word
else
    if p.end(k) == numel(doc)
        p.current = '';
        return
    else
        word = doc((p.end(k)+1):end); % the current word
    end
end

p.current = word; % resave the current word

if ~p.numericService, return, end

% setup left word
[p,remain] = setup_left(p);

if p.type.full || p.type.none
    return
end

% setup right number word
p = setup_right(remain,p,k);


end


% setup left word number word
function [p,remain] = setup_left(p)

% back word
e = regexp(p.lead,'[0-9]','end'); % extract end index
remain = '';

% check if no numbers exist
if isempty(e), p.type.none = true; return, end

if e(1) == 1
    % check for word front
    max_value = max(e(e == (1:numel(e))));
    p.left.number = p.lead(1:max_value);
    p.type.full = numel(p.lead) == numel(p.left.number);
    
    % type full
    if p.type.full, return, end
    p.type.left = true;
    remain = p.lead((max_value+1):end);
else
    p.type.left = false;
    p.left.number = false;
    remain = p.lead;
end

end

% setup right number word
function p = setup_right(remain,p,~)

p.right.frontIsPer = false;
p.right.front      = '';    % front of right key
p.right.specialKey = false; % special characters in front key
p.right.pctFlag    = false; % percent flag in end key
p.right.end        = '';    % right end key
p.right.trash      = '';    % numbers & symbols between words

% used during front key logic
lgc = false;

% extract end index
s = regexp(remain,'[0-9]','end');

% check if s is empty.
if isempty(s),  p.type.right = false; return, end

% set is right to true
p.type.right = true;

% clean up end of string
if s(end) < numel(remain)
    
    % extract end of word.
    ekey = remain(s(end)+1:end);
    
    % percent flag check
    if ekey(1) == '%'
        p.right.pctFlag = true;
        
        % remove percent end key
        if numel(ekey) > 1, ekey = ekey(2:end); else, ekey = '';  end
    end
    
    % if end key is not empty remove spaces
    if ~isempty(ekey), ekey = ekey(ekey ~= ' '); end
    
    % if end key has one character set right end key
    if numel(ekey)==1, p.right.end = ekey; else, p.right.end = ''; end
    
    % develop remaining values
    remain = remain(1:s(end));
end

% numeric word decoder
[remain,p.info] = numericDecoder(remain);

% extract end index
s = regexp(remain,'[0-9]','end');

% detect symbols located between right and left numbers
I = ~[cumsum(diff(s,2) ~= 0,'reverse') == 0,true,true];

% remove trash
if any(I)
    s = s(I); %                         extract bad s characters 
    p.right.trash = remain(1:s(end)); % extract right trash value
    remain = remain((s(end)+1):end);  % extract remaining values
    s = regexp(remain,'[0-9]','end'); % generate new s values
end

% clean up front of string
if s(1) > 1

    % extract front end character key
    frontKey = remain(1:(s(1)-1));

    % attempt to find lagging special key ex. $100k ($ is the special key)
    % ====================================================================
    
    % the first letter in sentance is the start key 
    if isempty(p.right.trash) && ~p.type.left && numel(frontKey) == 1
        lgc = true;
    
    % else if the front key is followed by a space
    elseif numel(frontKey) > 1
        lgc = frontKey(end-1) == ' ';
    end
    
    % remove spaces is any are present
    if lgc
        frontKey = frontKey(frontKey ~= ' ');
        n = numel(frontKey);
        lgc = n > 0;
    end
    
    % identify dollar sign or other symbol and front is '/' logic
    if lgc
        
        % obtain word view 
        if n == 1, view = 0; else, view = 1; end
            
        % set to front is per
        p.right.frontIsPer = frontKey(end-view) == '/';

        % check for number
        if n == 1 && ~p.right.frontIsPer
            p.right.front = frontKey(end);
        elseif n == 2
            % check front key ending is different then second to last
            if frontKey(end-1) ~= frontKey(end)
                p.right.front = frontKey(end);
            end
        end
        
    end

    % extract number
    p.right.number = remain(s(1):end);
else
    
    % extract word remaining
    p.right.number = remain;
end


end


