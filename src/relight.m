function [reshadow] = relight(im, core_seg_sh, core_seg_lit)
% 	relight a region pair of shadow and lit
	
    [im_L, im_a, im_b] = RGB2Lab(im);
    sh_L = im_L(core_seg_sh==1); 
    sh_a = im_a(core_seg_sh==1);
    sh_b = im_b(core_seg_sh==1);
    lit_L = im_L(core_seg_lit==1); 
    lit_a = im_a(core_seg_lit==1); 
    lit_b = im_b(core_seg_lit==1); 
	
%     reL = add_diff(sh_L(:), lit_L(:));
    reL = LHistMatching(sh_L(:),  lit_L(:));
	rea = add_diff(sh_a(:), lit_a(:));
	reb = add_diff(sh_b(:), lit_b(:));
%     rea = sh_a;
%     reb = sh_b;
    
    reshadow = RGB2Lab(im);
    [x, y] = find(core_seg_sh==1);
    for j = 1 : length(x)
        reshadow(x(j), y(j), :) = [reL(j), rea(j), reb(j)];
    end
    
    % RGBreshadow
	reshadow_rgb = Lab2RGB(reshadow);
    reshadow = im2double(reshadow_rgb);
% 	imshow(reshadow);
	
end