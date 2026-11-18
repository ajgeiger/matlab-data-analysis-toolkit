function [title,found,broken] = getYoutubeTitle(url)

title = '';
lgc   = false;
found = false;
broken = true;

for k = 1:3
    try
        data = webread(url);
    catch
        if endsWith(url,'.')
            url = url(1:end-1);
        end
        pause(1*k)
        continue
    end
    broken = false;
    lgc = true;
    break
end

if ~lgc
   return 
end

% Extract HTML Text.
[title,found] = extractor(data,'<meta property="og:title" content="','<meta property="og:image" content="');
description = extractor(data,'<meta property="og:description" content="','<meta property="');

% clean up html text.
title       = extractHTMLText(title);
description = extractHTMLText(description);

% clean ending of description
if endsWith(description,'...')
   description = strsplit(description);
   description = strjoin(description(1:end-1));
end

% setup title info
title = [' the youtube video title is ',title,', '];
title = [title,' the video description is ',description,'. '];

% simple clean up
if contains(title,'&quot;')
    title = strrep(title,'&quot;',''); 
end

% generate new word settings
title = strrep(title,'TEDx','TEDx ');
title = strrep(title,'''','');
title = strrep(title,'`','');
title = strrep(title,'#',''); 

end

function [title,found] = extractor(org,split,condence)

found = false;
data = strsplit(org,split);

if numel(data) == 1
    data = strsplit(org,'<h1 id="unavailable-message" class="message">');
    if numel(data) == 1
        title = ' video is unavailable ';
        return
    end
    
    data = strsplit(data{2},'</h1>');
    if numel(data) == 1
        title = ' video is unavailable ';
        return
    end
    
    title = [' ',data{1},' '];
    return
        
end

data = strsplit(data{2},condence);

if numel(data) == 1
    title = ' could not find info ';
    return
end
    
data = strsplit(data{1},'">');
title = strjoin(data(1:end-1),'">');
found = true;



end

