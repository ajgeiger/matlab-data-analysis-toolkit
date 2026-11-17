function [hashmap,T] = build_id_struct(T,col,col_id)
% map a column with elements containing unique words to a structure which
% stores the word as a fieldname and the correspond numeric row id's of
% table T to the corresponding fieldname's value.
%
% Notes on function
% - word must not exceed 25 characters
% - the process takes words through a clean phase


hashmap = struct(); % create empty structure
WD = T.(col);       % unique cellstr vectors
id = T.(col_id);    % column id's

for i = 1:size(T,1)
   % clean up any loose ends in table which may be a problem
   WD{i} = cellfun(@(x) regexprep(lower(x),'[^a-z]+',''),WD{i},'un',0);
   WD{i} = WD{i}(~ismember(WD{i},{''}));
end

T.(col) = WD; % re-save column vector.

% process data
for i = 1:size(T,1)
    if length(WD{i}) == 1 && isempty(WD{i}{1}), continue, end
    for j = 1:numel(WD{i})
        if length(WD{i}{j}) > 25, continue, end
        if ~isfield(hashmap, WD{i}(j))
            hashmap.(WD{i}{j}) = id(i);
        else
            hashmap.(WD{i}{j})(end+1) = id(i);
        end
    end
end





end

