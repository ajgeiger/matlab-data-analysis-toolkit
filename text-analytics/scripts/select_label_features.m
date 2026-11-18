% The function is used to derive an optimal set of features for your
% predictive model. The two  tuning parameter are the freqency of words 
% can appear in your dataset and the threshold which words must be above to
% determine weather or not the word is a good indicator.

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------


new_col = 'comment_text_clean'; % new column name
col_id = 'idx'; % column id name

Var_1 = 'toxic'; % variable 1
Var_2 = 'severe_toxic'; % variable 2

% -------------------------------------------------------------------------
% -------------------------------------------------------------------------

Word_Count = 20;    % function for simulated anealing
Feature_perf = 15;  % feature performance
No_Features = 1000; % number of features

while No_Features > 50
    
    Word_Count = Word_Count + rand*-1;
    I = (sum(tbl_fz{:,name} > Word_Count,2)) ~= 0;
    build_tbl = tbl_fz(tbl_fz.freq > Feature_perf & I,:);
    
    
    TT = T;
    try
        TT(K==1,:) = []; 
    catch
        TT(K==1,:) = [];
        K = getBadRows(TT);
    end
    
    
    % to improve parfor perfomance:
    Cleaned_Comments = TT.comment_text_clean;
    FeatureWords = build_tbl.words;
    Test_Output = [TT{:,Var_1}==1&TT{:,Var_2}==1,...
        TT{:,Var_1}==1&TT{:,Var_2}==0,...
        TT{:,Var_1}==0&TT{:,Var_2}==0];
    
    Train_Input = zeros(size(TT,1),length(FeatureWords));
    parfor i = 1:size(TT,1)
        Train_Input(i,:) = ismember(FeatureWords,Cleaned_Comments{i});
    end
    
    Train_Iso = Train_Input(sum(Test_Output(:,[1,2]),2)~=0,:);
    No_Features = sum(0==sum(Train_Iso,2));
    fprintf('Feature Space Deficate: %0.0f\n',No_Features)
end


function K = getBadRows(TT)

K = zeros(size(TT,1),1);
for i = 1:size(TT,1)
    K(i) = isempty(TT.comment_text_clean{i}); 
end

end


