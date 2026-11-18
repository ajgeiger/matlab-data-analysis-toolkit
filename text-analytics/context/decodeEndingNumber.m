function [p,lgc,obj] = decodeEndingNumber(p,obj)

% set p to true
p.lgc = true;
lgc   = true;

% set remove past to true
p.removePast = true;
numeric_lead = {'the','number','season','buy'};
numeric_after = {'of','can'};

switch p.left.number
    case '1'
        

        % check for word ending in one
        if isWordKnown(obj,[p.before,'one'])
            p.solution = [p.solution,' ',p.before,'one '];
            
        % check for word
        elseif isWordKnown(obj,[p.before,'won'])
            p.solution = [p.solution,' ',p.before,'won '];
            
        % check for word
        elseif ismember({p.before},{'he','she','they','both'}) || ismember({p.after},{'the'})
            p.solution = [p.solution,' ',p.before,' won '];
        
        % default to one
        else
            p.solution = [p.solution,' ',p.before,' one '];
        end

    case '2'
        
        % check for word ending in to
        if isWordKnown(obj,[p.before,'to'])
            p.solution = [p.solution,' ',p.before,'to '];
            
        % check for word ending in too
        elseif isWordKnown(obj,[p.before,'too'])
            p.solution = [p.solution,' ',p.before,'too '];
            
        % check for the number (two)
        elseif ismember({p.before},numeric_lead) || ismember({p.after},numeric_after)
            p.solution = [p.solution,' ',p.before,' two '];
            
        % check for too indication 
        elseif ismember({p.before},{'me','us','you'})
            p.solution = [p.solution,' ',p.before,' too '];
        
        % otherwise default to to
        else
            p.solution = [p.solution,' ',p.before,' to '];
        end
        
    case '3'
        
        % set to false.
        p.removePast = false;
        p.lgc        = false;
        lgc          = false;

    case '4'
        
        if p.type.full && numel(p.current) > 0
            if isWordKnown(obj,[p.before,'r',p.current])
                p.solution = [p.solution,' ',p.before,'r',p.current,' '];
                p.removePast = true;
                return
            end
        end
           
        % check for word ending in (for)
        if isWordKnown(obj,[p.before,'for'])
            p.solution = [p.solution,' ',p.before,'for '];
            
        % check for word ending in (fore)
        elseif isWordKnown(obj,[p.before,'fore'])
            p.solution = [p.solution,' ',p.before,'fore '];
            
        % check for word ending in (four)
        elseif isWordKnown(obj,[p.before,'four'])
            p.solution = [p.solution,' ',p.before,'four '];
            
        % check for number four (four)
        elseif ismember({p.before},numeric_lead) || ismember({p.after},numeric_after)
            p.solution = [p.solution,' ',p.before,' four '];
        
        % otherwise just default to for.
        else
            p.solution = [p.solution,' ',p.before,' for '];
        end
end

end

