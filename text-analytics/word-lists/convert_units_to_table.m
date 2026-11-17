

temp = struct2table(s.unit_cv);

unit = temp.Properties.VariableNames;
names = table2cell(temp);
unit = unit';
names = names';


unit_cv = table(unit);
unit_cv.names = names;
