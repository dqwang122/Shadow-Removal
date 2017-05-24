function reL = calcLHist(shadow_L, lit_L)
	binNum = 50;
    
    reL = imhistmatch(shadow_L./100, lit_L./100, binNum);
    reL = reL .* 100;
    
    subplot(3,1, 1);
    hist(lit_L, binNum);
    subplot(3,1, 2);
    hist(shadow_L, binNum);
    subplot(3,1, 3);
    hist(reL, binNum);
    
end