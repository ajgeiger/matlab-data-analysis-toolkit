% demonstrates how to find pattern in word with only two letters.
% note this is does not remove repeat leters...

word = {'lol'}; % word to compare to
B = double(word{1});


D = {'lololol','looolololol'};

FtL = B(1);
EtL = B(end);
WN = cellfun(@(x) double(lower(x)),D,'un',0); % convert all to lower
CN = cellfun(@(x) all(x > 96) & all(x < 123),WN,'un',0); % clean
FL = cellfun(@(x) x(1) == FtL,WN,'un',0); % check if first leter is equal
LL = cellfun(@(x) x(end) == EtL,WN,'un',0); % checks second letter.
WC = cellfun(@(x) all(ismember(x,B)),WN,'un',0);
CW = cellfun(@(x) all(ismember(B,x)),WN,'un',0);

disp(CW)