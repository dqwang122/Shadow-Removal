function [ reim, reList ] = removal( im, seg ,pairList,  shList, mask)

    pairNum = size(pairList,1);
    I = eye(3,3);
    reim = im2double(im);

    shSum = zeros(size(seg, 1), size(seg, 2));
    shSum = (shSum==1);
     for i =  1 : length(shList)
          shNo = shList(i);
          segsh = (seg == shNo);
          shSum = shSum | segsh;
     end   
    
%      im_L = im2double(im);
%      im_L=im_L+(1-im_L).*im_L;
%      im_L=im_L+(1-im_L).*im_L;
%      [x, y] = find(shSum==1);
%     for j = 1 : length(x)
%         reim(x(j),y(j), :) = im_L(x(j),y(j), :);
%     end
    
    reList = zeros(size(pairNum,1));

    for i = 1 : pairNum
        shNo = pairList(i, 1);
        litNo = pairList(i, 2);
        shadow = reim;
        core_seg_sh = imerode(uint8(seg == shNo),I);
        for ch = 1 : 3
            c = shadow(:, :, ch);
            c(core_seg_sh==0) = 0;
            shadow(:, :, ch) = c;
        end

        lit = reim;
        core_seg_lit = imerode(uint8(seg == litNo),I);
        for ch = 1 : 3
            c = lit(:, :, ch);
            c(core_seg_lit==0) = 0;
            lit(:, :, ch) = c;
        end

        [im_L, im_a, im_b] = RGB2Lab(im);
        sh_L = im_L(core_seg_sh==1); 
        lit_L = im_L(core_seg_lit==1); 
        
       
        if median(sh_L) < median(lit_L)
            reList(i) = 1;
            [reim] = relight(reim, core_seg_sh, core_seg_lit);
        else
            reList(i) = 0;
        end
            
    end

    for i =  1 : length(shList)
          shNo = shList(i);
          reim = boundary_recovery(reim, shNo,seg);
    end
     
    shSum = (mask == 255) - shSum;
    shSum = (shSum == 1);
    
    % Gussian filter
    sigma = 5;
    gausFilter = fspecial('gaussian', [7,7], sigma);
    reim_g= imfilter(reim, gausFilter, 'replicate');
    
    [x, y] = find(shSum==1);
    for j = 1 : length(x)
        reim(x(j),y(j), :) = reim_g(x(j),y(j), :);
    end
    
end


