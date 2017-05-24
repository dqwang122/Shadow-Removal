function [ pairList, vector, candidate ] = generate_pairList( fn, im, seg, label, shList, centroids, cnt )
    try 
        load(['..\data\test\test_origin_first\' fn '_feature' int2str(cnt) '.mat']);
    catch exp1
        candidate = 5;
        pairNum = length(shList) * candidate;
        pairList = zeros(pairNum, 2);

        for i = 1 : length(shList)
        % The candidate th nearest region num, shList * candidate
                shNo = shList(i);
%                 boundary = imdilate(uint8(seg == shNo), eye(3)) - uint8(seg==shNo);
%                 near = seg(boundary==1);
%                 near = unique(near(:));
%                 near = near(label(near)==0);
%                 nearNum = min(length(near), 5);
%                 for j = 1 : nearNum
%                     pairList((i-1)*candidate + j, :) = [shNo, near(j)];
%                 end
                nearNum = 0;
                if nearNum < 5
                    num = 5 - nearNum;
                    core = centroids(shNo, :);
                    C = bsxfun(@minus, centroids, core);
                    D = sum(C.^2, 2);

                    P = 200;
                    MaxD = max(D(:));
                    D(label == 1) = MaxD; %only for lit area
                    S = regionprops(seg, 'Area');
                    D([S.Area] <= P) = MaxD;% only for big area
%                     D(near) = MaxD; %without the near

                    t=sort(D);
                    if(size(t, 1) < num)
                        m = find(D>0);
                        m = [m; -ones(num - size(t, 1), 1)];
                    else
                        m=find(D<=t(num),num);
                    end
                    for j = nearNum + 1 : candidate
                        pairList((i-1)*candidate+j, :) = [shNo, m(j - nearNum)];
                    end
                end
        end
        
        I = eye(3,3);
        % features for classifier of sh-lit pairs
        vector = zeros(pairNum, 9);
        for i = 1 : pairNum
            fprintf(1, 'Generate features: %d/%d\n', i, pairNum);
            shNo = pairList(i, 1);
            shadow = im;
            core_seg_sh = imerode(uint8(seg == shNo),I);
            for ch = 1 : 3
                c = shadow(:, :, ch);
                c(core_seg_sh==0) = 0;
                shadow(:, :, ch) = c;
            end

            if pairList(i, 2) < 0
                vector(i, :) = [0,0,0,0,0,0,0,0,0];
                continue;
            end
            litNo = pairList(i, 2);
            lit = im;
            core_seg_lit = imerode(uint8(seg == litNo),I);
            for ch = 1 : 3
                c = lit(:, :, ch);
                c(core_seg_lit==0) = 0;
                lit(:, :, ch) = c;
            end
            vector(i, :) = generate_feature(im, shadow, lit, core_seg_sh, core_seg_lit);
        end
        disp 'Saving!'
        save(['..\data\test\test_origin\' fn '_feature' int2str(cnt) '.mat'], 'candidate','pairNum', 'pairList', 'vector');
    end
end

