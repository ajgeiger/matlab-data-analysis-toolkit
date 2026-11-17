function [documents,lgc] = twitter_url_read(url)

documents = '';
lgc = false;
broken = true;

for k = 1:4
    try
        data = webread(url);
        broken = false;
    catch
        if endsWith(url,'.')
            url = url(1:end-1);
        elseif k > 2
            url = url(1:end-1);
        end
        pause(1*k*.5)
        continue
    end
    break
end

if broken
   return 
end


data = strsplit(data,'<meta  property="og:description" content="“');
if numel(data) == 1
   data = strsplit(data{1},'<meta name="description" content="');
    
    if numel(data) == 1
        return
    end
end

data = strsplit(data{2},'<meta  property="');
if numel(data) == 1
    data = strsplit(data{1},'<meta name="');
    if numel(data) == 1
        return
    end
end

% extract full twitter thread
data = strsplit(data{1},'>');
if numel(data) == 1
    return
end

% join string
data = strjoin(data(1:end-1));

% clean up twitter string
documents = extractHTMLText(data);
lgc = true;
end

