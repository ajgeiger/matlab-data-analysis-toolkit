function str = cleanup_string(str)
% remove n-repeat spaces

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
