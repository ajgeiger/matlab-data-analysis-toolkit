function [word,p] = numericDecoder(str)


p = extractNumber(str);
p.isComma = p.isComma && ~p.isCommaFail;

% clean number
try
p.cleaned = strrep(p.number,'.','');
p.cleaned = strrep(p.number,',','');
catch
   1; 
end
word = [str(p.logic==0),p.cleaned];
end


% extract number
function p = extractNumber(str)


% develop logic vectors
clgc = str == ',';
lgc  = isstrprop(str,'digit');

n   = numel(str);
Ix  = 1:n;
Ix     = fliplr(Ix(lgc==0));
failed = false(n,1);
start  = 1;

p.isNumFail   = false;
p.isCommaFail = false;
p.isDecimal   = false;
p.isComma     = false;
p.exit        = false;

if str(Ix(1)) == '.'
    
   if (Ix(1) > 1) 
        if ~lgc(Ix(1) - 1), failed(Ix(1)) = true; end
   end
   
   % set start value
   start = 2;
   
   % set decimal values
   p.isDecimal = true;
   
   % return if only a decimal exists
   if numel(Ix) == 1
       
       % extract number
       p = filterNumber(str,failed,p);
       return
   end
     
   % check if next element is a comma
   if clgc(Ix(2))
       
       % check spacing
       [p,failed]  = checkCommaSpacing(Ix,1,2,p,failed);
       p = filterNumber(str,failed,p);
       if p.exit, return; end
       
   end
else
    if clgc(Ix(1))
       
       % k + 1 is the smaller number bc it is counting down
        p = dualCommaCheck(failed,p,str,Ix(1),numel(str),Ix(1));
        
        % return if comma check failed
        if p.exit, return; end
       
        % set comma fail to false
        p.isComma     = true;
        
        if numel(Ix) == 1
       
           % extract number
           p = filterNumber(str,failed,p);
           return
       end
    end 
end


% loop through number
for k = start:(numel(Ix) -1)

    % Check for comma
    if clgc(Ix(k)) && clgc(Ix(k+1))
        
        % check comma spacing
        [p,failed]  = checkCommaSpacing(Ix,k,k+1,p,failed);
        if p.exit
            p = filterNumber(str,failed,p);
            return;
        end
        
    elseif clgc(Ix(k))
        
        % k + 1 is the smaller number bc it is counting down
        p = dualCommaCheck(failed,p,str,Ix(k+1),Ix(k),Ix(k));
        
        % return if comma check failed
        if p.exit, return; end
        
        % otherwise set comma to true
        p.isComma     = true;
    else
        
        % fail letter if unknown
        failed(Ix(k)) = true;
        p = filterNumber(str,failed,p);
        return
    end
end

if clgc(Ix(end))
    
    p = dualCommaCheck(failed,p,str,1,Ix(end),Ix(end));
    if p.exit, return; end
    p.isComma     = true;
    p = filterNumber(str,failed,p);
        
else
    % fail letter if unknown
    failed(Ix(end)) = true;
    p = filterNumber(str,failed,p);
    
end
    
end

% comma fail
function [p,failed] = commaFail(failed,lgc,str,p,s,Ix)

% fail comma test
p.isCommaFail = true;  

% check for miss spelling
if ~checkCommaNotation(lgc,Ix(s))

    % set exit key
    p.exit = true;

    % fail number
    p.isNumFail = true;

    % fail element
    failed(Ix(s)) = true;

   % extract number
   p = filterNumber(str,failed,p);
end

end

% check spacing
function [p,failed]  = checkCommaSpacing(Ix,s,e,p,failed)


% verify spacing when compared to decimal
if abs(Ix(s) - Ix(e)) ~= 4

    % fail comma test
    p.isCommaFail = true;  

    % check for miss spelling
    if abs(Ix(s) - Ix(e)) > 1 && abs(Ix(s) - Ix(e)) < 6
        % set exit key
        p.exit        = true;
        failed(Ix(s)) = true;
        p.isNumFail   = true;
        return
    end

% else word is proper
else

   % comma was detected
   p.isComma = true;

end

end


% OTHER METHODS
% =============

% dual comma check
function p = dualCommaCheck(failed,p,str,s,e,fail)

if e - s == 4
   return 
end

p.isCommaFail = true;

if (e - s) > 5 || (e - s) < 1
    p.exit = true; % set exit key
    p.isComma  = false;
    p.isNumFail = true; % fail number
    failed(fail) = true; % fail elemen
    p = filterNumber(str,failed,p); % extract number
end
       
end

% filter numbers
function p = filterNumber(str,failed,p)

numberLogic = cumsum(fliplr(failed),'reverse') == 0;
p.number    = str(numberLogic);
p.logic     = numberLogic;
end

% checks comma notation
function lgc = checkCommaNotation(vector,k)

try
    if numel(vector) > k+2
        lgc1 = all(vector((k+1):(k+2)));
    else
        lgc1 = vector(k+1);
    end

    if 1 < k-2
        lgc2 = all(vector((k-2):(k-1)));
    else
        lgc2 = vector(k-1);
    end
    
catch
   lgc = false; 
   return
end

lgc = lgc1 & lgc2;


end
