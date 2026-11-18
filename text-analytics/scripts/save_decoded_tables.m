
how = 'test';
file_table = [how,'_table.csv'];
file_name =  [how,'_decoder_1.csv'];

dd = DocumentDecoder();
dd.T = readtable(file_name,'Encoding','UTF-8');
dd.saveTable(file_name,file_table);
dd.h.Quit