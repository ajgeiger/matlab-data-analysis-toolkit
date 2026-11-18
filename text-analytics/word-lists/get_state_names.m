

state_tbl = readtable('us_state_abv_names.csv');


for k = 1:size(state_tbl,1)
    
   state_map.(lower(char(state_tbl.abv(k)))) = lower(char(state_tbl.name(k)));
    
end
