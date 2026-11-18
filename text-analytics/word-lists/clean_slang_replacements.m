% clean up slang file
idfld = s.slangs.id;
names = s.slangs.replace;

for k = 1:numel(names)
    pause(1)
    D = strsplit(char(names{k}),' '); % join str
    D = regexprep(lower(D),'[^a-z]+','');
    D = strjoin(D(~ismember(D,{''})));
    
    disp([idfld{k},' -> ',D])
    
    names{k} = D;
    
end