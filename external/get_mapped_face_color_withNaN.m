function [S1_col,S2_col]= get_mapped_face_color_withNaN(S1,S2,map,IFaddcoverage)
if nargin < 4
    IFaddcoverage = 0;
end
col_nan = [0.05,0.05,0.05];


g1 = S2.surface.X;
g2 = S2.surface.Y;
g3 = S2.surface.Z;

g1 = normalize_function(0,1,g1);
g2 = normalize_function(0,1,g2);
g3 = normalize_function(0,1,g3);

ind = find(~isnan(map));

f1 = col_nan(1)*ones(length(map),1);
f2 = col_nan(2)*ones(length(map),1);
f3 = col_nan(3)*ones(length(map),1);

f1(ind) = g1(map(ind));
f2(ind) = g2(map(ind));
f3(ind) = g3(map(ind));
S1_col = [f1,f2,f3]; % S1 face color f
S2_col = [g1,g2,g3]; % S2 face color g

if IFaddcoverage
    n2 = size(S2.surface.X,1);
    mask = zeros(n2,1);
    mask(unique(map)) = 1;
    S2_col = [mask.*g1, mask.*g2, mask.*g3];
end

end


function fnew = normalize_function(min_new,max_new,f)
fnew = f - min(f);
fnew = (max_new-min_new)*fnew/max(fnew) + min_new;
end