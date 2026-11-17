
% extract original data
% id      = lower(s.s');
% replace = lower(s.fix');
% new_tbl = unique(table(id,replace));
% 
% new_tbl.Properties.RowNames = new_tbl.id;
% s.flags = new_tbl;

id      = lower(s.slang);
replace = lower(s.meaning);
replace = strrep(replace,',','');
replace = strrep(replace,'''','');
replace = strrep(replace,'-','');
replace = strrep(replace,'.',' ');
replace = strrep(replace,'!',' ');
replace = strrep(replace,'?',' ');

for k = 1:numel(replace)
   replace{k}  = cleanup_string(replace{k}); 
end




elements = cell2mat(cellfun(@(x)numel(x),id,'UniformOutput',false));
new_tbl = unique(table(id,replace,elements));
lgc = ~ismember(new_tbl.replace,{'cam to cam (webcams)','parents are watching',...
                                 'not much you','to long; didnt read',...
                                 'what you up too'});
new_tbl = new_tbl(lgc,:);

lgc = ~ismember(new_tbl.id,{'ut'});
new_tbl = new_tbl(lgc,:);

% property names
new_tbl.Properties.RowNames = new_tbl.id;
new_tbl = new_tbl(new_tbl.elements < 30,:);
s.slangs = new_tbl;
dd.s = s;

% remove n-repeat spaces
function str = cleanup_string(str)

if iscell(str)
    str = str(~ismember(str,{''}));
    if numel(str) == 1
        str = char(str);
    else
        str = strjoin(str);
    end
end

% split word
str = strsplit(str);

str = str(~ismember(str,{''}));

% rejoin word
str = strjoin(str);

end
