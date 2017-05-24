function dist = calcEMD(sh, lit)
	binNum = 50;
	[lit_hist, b]=hist(lit, binNum);
	[sh_hist, b]=hist(sh, binNum);
	
	D = zeros(length(sh_hist), length(lit_hist));
	for i = 1 : length(sh_hist)
		for j = 1 : length(lit_hist)
			D(i, j) = abs(i - j);
		end
	end
	
	[dist, F] = emd_hat_mex_nes(sh_hist',lit_hist',D);

end