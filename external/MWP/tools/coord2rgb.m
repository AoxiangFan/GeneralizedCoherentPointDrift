function rgb=coord2rgb(V)
min_value=min(V,[],1);
max_value=max(V,[],1);

rgb=(V-min_value)./(max_value-min_value);

