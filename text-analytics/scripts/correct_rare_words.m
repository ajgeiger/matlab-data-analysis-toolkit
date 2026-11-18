
%h = actxserver('word.application');
% h.Document.Add;



% part I:
s = obtain_database(hashmap); 
[Tbl,Found] = str_decoding('iso',s,h,true);
[T,hashmap] = hashmap_correct(s,T,hashmap,Tbl,Found);

% Part II:
% s = obtain_database(hashmap);
[Tbl,Found] = str_decoding('iso',s,h,false,true);
[T,hashmap] = hashmap_correct(s,T,hashmap,Tbl,Found);