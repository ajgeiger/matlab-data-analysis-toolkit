function output = google(q)

q(q == ' ') = '+';
if isempty(q),return;end

url=['https://www.google.com/search?q=' q ]; 
txt = urlread(url);

try
    Info = getInfo(txt);
catch
    Info = [];
end

urls=regexp(txt,'<a href=".*?q=(http://.*?)&amp.*?>(.*?)</a>.*?<cite>(.*?)</cite>.*?<span class="st">(.*?)</span>','tokens')';
data = getlink(urls);

output.answer = Info; output.links = data;


end
% bing search
% 1. <h2><a href="http://
% 2. <cite>
% 3. h="ID=SERP
% deletes:
% 1.class="b_attribution" u=
% 2. <strong>
% 3. <strong>BHM</strong>

function data = getInfo(txt)

Info = strsplit(txt,'<br>'); Info = Info{1};
Info = strsplit(Info,'class="_sPg">'); Info = Info{2};
Info = strsplit(Info,'<b>');


p1 = Info{1}; p2 = Info{2};
Answer = strsplit(p2,'</b>'); p2 = Answer{2}; Answer = Answer{1};

p1(p1 == ',' | p1 == '.' | p1 == ';') = [];
p2(p2 == ',' | p2 == '.' | p2 == ';') = [];

p1 = strsplit(p1,' '); p2 = strsplit(p2,' ');

if strcmpi(p1{end},''), p1(end) = []; end
if strcmpi(p2{1},''), p2(1) = []; end



if strcmpi(p1{end},{'was'})
    if strcmpi(p2{1},{'in'}) && length(p2{2}) == 4
        data.date = str2double(p2{2});
    end, p1(end) = []; data.description = strjoin(p1);
    
elseif strcmpi(p1{1},{'in'})
    if strcmpi(p1{2},{'the'})
        if isnan(str2double(p1{3})) == 0, data.date = str2double(p1{3});
        end, else
        if isnan(str2double(p1{2})) == 0
            data.date = str2double(p1{2});
        end
    end, else, data.description = strjoin(p1);
end

if ismember('$',Answer)
    data.type = 'USD'; data.answer = str2double(Answer(Answer ~='$'));
elseif ismember('%',Answer)
    data.type = 'percent'; data.answer = str2double(Answer(Answer ~='%'));
elseif isnan(str2double(Answer)) == 0
    data.type = 'double'; data.answer = str2double(Answer); else
    data.type = 'string'; data.answer = Answer;
end


end


function data = getlink(urls)

num=0; data = [];
for k=1:numel(urls), url=urls{k};
    link=url{1};string=url{2};cite=url{3};description=url{4}; num=num+1;

    string=regexprep(string,'</?br?>','');
    cite=regexprep(cite,'</?br?>','');
    description=regexprep(description,'</?br?>','');
    view=['<a href="matlab:web(''' link ''',''-browser'')">' string '</a>'];
    
    temp.link = link; temp.cite = cite;
    temp.description = description; temp.view = view;
    data = joinRows(data,temp); temp = [];
    
end

end


