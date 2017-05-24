function [reim ] = boundary_recovery( reim, shNo, seg )
    I = eye(5);

    im = reim;
    Labim = RGB2Lab(im2double(im));
    im_L = Labim(:,:,1); im_a = Labim(:,:,2); im_b = Labim(:,:,3);
    
    core_seg_sh = imerode(uint8(seg == shNo),I);
    co_L = im_L(core_seg_sh==1);
    co_a = im_a(core_seg_sh==1);
    co_b = im_b(core_seg_sh==1);
    
    boundary_seg_sh = imdilate(uint8(seg == shNo), I) - core_seg_sh;
    by_L = im_L(boundary_seg_sh==1);
    by_a = im_a(boundary_seg_sh==1);
    by_b = im_b(boundary_seg_sh==1);
    
%  rejust boundary by core region
    reL = add_diff(by_L(:), co_L(:));
    rea = add_diff(by_a(:), co_a(:));
    reb = add_diff(by_b(:), co_b(:));

    [x, y] = find(boundary_seg_sh==1);
    for j = 1 : length(x)
        Labim(x(j), y(j), :) = [reL(j), rea(j), reb(j)];
    end
    
    % Gussian filter
    RGBim = Lab2RGB(Labim);
    RGBim = im2double(RGBim);
    sigma = 5;
    gausFilter = fspecial('gaussian', [5,5], sigma);
    RGBim= imfilter(RGBim, gausFilter, 'replicate');
    
    for j = 1 : length(x)
        reim(x(j),y(j), :) = RGBim(x(j),y(j), :);
    end
    
end

