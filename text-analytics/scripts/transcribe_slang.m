% re-edited function, use when hashmap is complete.


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

name = {'toxic','severe_toxic','obscene','threat','insult','identity_hate'};
col = 'comment_text';
new_col = 'comment_text_clean';
col_id = 'idx';
Thresh = 25;

[T,statTbl] = cleanWords(trainn,col,new_col); % clean data
T = [T,statTbl]; % combine tables
T{:,col_id} = (1:size(T,1))'; % build index col
[hashmap,T] = build_id_struct(T,new_col,col_id);


% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% setup inital functions
h = actxserver( 'word.application' );
h.Document.Add;
s = obtain_database(hashmap);
[Cells,Found] = str_decoding('iso',s,h,true);

% isolate variables
words = Cells(:,2);
fixed_sol = Cells(:,3);
Score = Cells(:,1);
full_word = Cells(:,4);

% build table and process
Tbl = table(words,fixed_sol,Score,full_word);
[T,hashmap] = hashmap_correct(s,T,hashmap,Tbl,Found);
tbl_fz = build_fz_tbl(hashmap,T,name);






