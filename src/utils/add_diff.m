function re = add_diff(shadow, lit)
	diff = median(lit(lit~=0)) - median(shadow(shadow~=0));
%     diff = mean(lit(lit~=0)) - mean(shadow(shadow~=0));
	re = shadow + diff;
end