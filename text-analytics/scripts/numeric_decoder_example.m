% the following code should allow for mistakes however would not show flags
% for the comma if the placement location was wrong. Minimum placement
% error will be set to one. For example.
%
% 120,50,200 note two numbers are between spaces

str = '.45';

% decode string
p = numericDecoder(str);