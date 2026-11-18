% demo decoder
how = 'test';
% dd = DocumentDecoder();
% dd.T = readtable([how,'.csv'],'Encoding','UTF-8');
% dd.T = dd.T(:,{'id','comment_text'});

clc
% Part One The URL:
% dd.thesaurusProcess = false; 
% dd = dd.fitURL();


dd = dd.fitPreprocessing(true);
dd = dd.fitPatterns();
dd = dd.fitSyntax();
% dd = dd.fitDemands();

file_table = [how,'_table.csv'];
file_name =  [how,'_decoder_1.csv'];
dd.saveTable(file_name,file_table);

% dd = dd.fitDecoder();
% dd.saveTable(file_name);
% dd.h.Quit