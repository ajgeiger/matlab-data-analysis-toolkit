
% setup info:
name = {'toxic','severe_toxic','obscene','threat','insult','identity_hate'};
col = 'comment_text';
new_col = 'comment_text_clean';
col_id = 'idx';
Thresh = 25;


% generate hashmap
[T,statTbl] = cleanWords(train,col,new_col); % clean data
T = [T,statTbl]; % combine tables
T{:,col_id} = (1:size(T,1))'; % build index col
[hashmap,T] = build_id_struct(T,new_col,col_id);