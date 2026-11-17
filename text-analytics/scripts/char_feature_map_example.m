% Mapping Demo:

model = 'toxic'; 
model_words  = 1200;
feature_pref = 1200;
null_words   = 1200;

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% create temp variable:
model = cellstr(model);
tbl_features = tbl_fz;


% clean data & derive preformance value indicators:
N = {'toxic','severe_toxic','obscene','threat','insult','identity_hate'};
W = tbl_fz{:,[N,{'none'}]}./sum(tbl_fz{:,[N,{'none'}]});
tbl_features{:,[N,{'none'}]} = W./sum(W,2);
tbl_features{:,'Score'} = var(tbl_features{:,N},0,2);

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% 1. obtain features specific to the prediction null-class:
tbl_features = sortrows(tbl_features,model,'descend');
words = tbl_features{1:model_words,'words'};


% 2. obtain features specific to prediction class volitlity:
tbl_features = sortrows(tbl_features,'Score','descend');
words = unique([words;tbl_features{1:feature_pref,'words'}]);


% 3. obtain features specific to prediction class:
tbl_features = sortrows(tbl_features,'none','ascend');
words = unique([words;tbl_features{1:null_words,'words'}]);


% 4. build feature space:
id = (1:length(words))';
FeatureSpace = table(words,correct_words,id);

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% build train test inputs
MapFeatureSpace = char_feature(correct_words);
