% single column generator inputs:

model = 'toxic'; 
model_words  = 900;
feature_pref = 900;
null_words   = 900;

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

% 1. obtain features specific to prediction class:
tbl_features = tbl_features(tbl_features.freq > 25,:);
tbl_features = sortrows(tbl_features,'none','ascend');
words = tbl_features{1:model_words,'words'};


% 2. obtain features specific to prediction class volitlity:
tbl_features = tbl_features(tbl_features.freq > 50,:);
tbl_features = sortrows(tbl_features,'Score','descend');
words = unique([words;tbl_features{1:feature_pref,'words'}]);


% 3. obtain features specific to the prediction null-class:
tbl_features = sortrows(tbl_features,model,'descend');
words = unique([words;tbl_features{1:null_words,'words'}]);

% 4. build feature space:
id = (1:length(words))';
FeatureSpace = table(words,id);

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


% build train test inputs
Train_Input = zeros(size(T,1),size(FeatureSpace,1));
Test_Input = zeros(size(T,1),size(model,2));

% to improve parfor perfomance:
Cleaned_Comments = T.comment_text_clean;
FeatureWords = FeatureSpace.words;

parfor i = 1:size(T,1)
    Train_Input(i,:) = ismember(FeatureWords,Cleaned_Comments{i});
    Test_Input(i,:)  = T{i,model};
end

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

% save feature words:
Feature_Struct.(model{1}) = FeatureSpace;



