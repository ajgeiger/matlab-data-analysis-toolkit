function doc = textCipher(doc)

% setup save doc for debugging
save_doc = doc;

% perform first word replacement
key      = [7424,665,7428,7429,7431,1171,610,668,618,7434,7435,671,7437,628,7439,7448,640,115,7451,7452,7457,7456,7437,7458];
values   = 'abcdefghijklmnoprstuwyz';
doc_num  = double(doc);
[IV,ix]  = ismember(doc_num,key);
doc(IV)  = values(ix(IV));

% perform second word replacement
key = [7468,7470,7472,7473,7475,7476,7477,7478,7479,7480,7481,7482,7484,7486,7487,7488,7489,7490,7491,7493,7495,7496,7497];
values = 'abdeghijklmnoprtuwaabde';

% attempt to perform second cipher with threshold
doc_num = double(doc);
[IV,ix] = ismember(doc_num,key);

% filter out key data
if numel(unique(ix(IV))) > 4
    doc(IV) = values(ix(IV));
end


if ~strcmp(save_doc,doc)
   1; 
end


end

