function features = generate_feature(im, shadow, lit, core_seg_sh, core_seg_lit)
	features = zeros(1,9);
    
	shadow = im2double(shadow);
	sh_R = shadow(:,:,1); sh_G = shadow(:,:,2); sh_B = shadow(:,:,3);
	sh_R = sh_R(sh_R~=0); sh_G = sh_G(sh_G~=0); sh_B = sh_B(sh_B~=0);
    
	lit = im2double(lit);
	lit_R = lit(:,:,1); lit_G = lit(:,:,2); lit_B = lit(:,:,3);
	lit_R = lit_R(lit_R~=0); lit_G = lit_G(lit_G~=0); lit_B = lit_B(lit_B~=0);
    
    
	% RGB color ratios
	tr = mean(sh_R)/mean(lit_R); 
	tg = mean(sh_G)/mean(lit_G); 
	tb = mean(sh_B)/mean(lit_B);
	features(1, 1) = (tr + tg + tb) / 3;
	features(1, 2) = (tr+1) / (tb+1);
	features(1, 3) = (tg+1) /(tb+1);
	
	% EMD between L hist 
	[sh_L, sh_a, sh_b] = RGB2Lab(shadow);
	[lit_L, lit_a, lit_b] = RGB2Lab(lit);
    sh_L = sh_L(sh_L~=0); sh_a = sh_a(sh_a~=0); sh_b = sh_b(sh_b~=0);
    lit_L = lit_L(lit_L~=0); lit_a = lit_a(lit_a~=0); lit_b = lit_b(lit_b~=0);
	features(1, 4) = calcEMD(sh_L, lit_L);
	
	% Median a and b offsets defined by T(Rs, Rl)
    features(1, 5) = median(lit_a) - median(sh_a);
	features(1, 6) = median(lit_b) - median(sh_b);
	
	% EMD between the a and b hist of Ri & reRs
    resh = relight(im, core_seg_sh, core_seg_lit);
	[resh_L, resh_a, resh_b] = RGB2Lab(resh);
    resh_L = resh_L(resh_L~=0); resh_a = resh_a(sh_a~=0); resh_b = resh_b(resh_b~=0);
	features(1, 7) = calcEMD(resh_a, lit_a);
	features(1, 8) = calcEMD(resh_b, lit_b);
    
	
	% X2 distance between the texton histogram
	shdist = calcTextHist(resh);
	litdist = calcTextHist(lit);
	features(1, 9) = dist_chi2(shdist', litdist');
	
end