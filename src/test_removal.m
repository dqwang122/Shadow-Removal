clc;clear;
addpath('..\requirement\meanshift');
addpath('..\requirement\libsvm-mat-3.0-2\source');
addpath('..\requirement\FastEMD');
addpath('..\requirement\SLIC');
addpath('..\data');
addpath('utils')

maskdir = dir(fullfile('..\data\test\test_mask\detection_', '*.png'));
masklist = {maskdir.name};
imdir = dir(fullfile('..\data\test\test_origin', '*.jpg'));
imlist = {imdir.name};

% extlist = {'lssd5.jpg'};
imlist = {'lssd24.jpg'};

% For a image
for f = 1 : length(imlist)
    fullfn = imlist{f};
    fn = fullfn(1:end-4);
    mask = imread(['..\data\test\test_mask\' fn '.png']);
    im = imread(['..\data\test\test_origin_first\' fn '.jpg']);
    try
        load(['..\data\segment\' fn '_seg.mat']);
    catch exp1
        disp 'Segmenting'
         [l, Am, C] = slic(im, 500, 10, 1, 'median');
          seg = spdbscan(l, C, Am, 5);
%           imshow(drawregionboundaries(l, im, [255 0 0]))
%             [dummy, seg] = edison_wrapper(im, @RGB2Luv, ...
%            'SpatialBandWidth', 9, 'RangeBandWidth', 15, ...
%            'MinimumRegionArea', 200);
%             seg = seg + 1;
         save(['..\data\segment\' fn  '_seg.mat'], 'seg');
    end

    segnum = length(unique(seg(:)));

    % label each region as shadow ( = 1) or lit ( = 0)
    label = zeros(segnum, 1);
    for i = 1:segnum
        temp = mean(mask(seg == i));
        if temp > max(mask(:))/2
            label(i, 1) = 1;
        else
            label(i, 1) = 0;
        end
    end
    shList = find(label==1);
    
    s = regionprops(seg, 'Centroid');
    centroids = cat(1,s.Centroid);
    
    cnt = 1;
    
    [ pairList, vector, candidate ]= generate_pairList( fn, im, seg, label, shList, centroids, cnt );
    pairNum = size(pairList, 1);
    
    % predict the pairLabel of shList, and choose the largest prob one to be
    % the removal pair.
    load('..\data\model\model.mat');
    disp 'Pair region classification'
%     normalvector = vecter./repmat(sqrt(sum(normfactor.^2,1)),size(vecter,1),1);
    normalvector = mapminmax('apply', vector', setting);
    normalvector = normalvector';
    [pred, accuracy, prob]=libsvmpredict(zeros(pairNum, 1), normalvector, model, '-b 1');
%     [pred, prob] = predict(vecter, candidate);
    removal_pair = zeros(length(shList(:)), 2);
    for i = 1 : length(shList(:))
        shNo = shList(i);
        class = pred((i-1)*candidate + 1: (i-1)*candidate + candidate);
        allpr = prob((i-1)*candidate + 1: (i-1)*candidate + candidate, 1);
        candid = pairList((i-1)*candidate + 1: (i-1)*candidate + candidate, 2);
        positivepr = allpr;
        positivepr(class==0) = 0;
        if isempty(positivepr(positivepr > 0))
            smvecter = vector((i-1)*candidate + 1: (i-1)*candidate + candidate, :);
            [smpred, smprob] = predict(smvecter);
            x = find(smpred == 1);
            removal_pair(i, :) = [shNo, candid(x)];
        else
            maxpr = max(positivepr);
            x = find(positivepr == maxpr, 1);
            removal_pair(i, :) = [shNo, candid(x)];
        end
    end

    disp 'Remove!'
    [reim, reList] = removal(im, seg, removal_pair, shList, mask);
    
    reList_sh = shList(reList==1);
    label(reList_sh) = 0;
    for k  = 1 : length(reList_sh)
        mask(seg == reList_sh(k)) = 0;
    end
    
    imwrite(reim, ['..\data\removal\' fn '_final' int2str(cnt) '_SILC.jpg']);
    
    % iteration
   while ~isempty(label(label==1)) && cnt <= 5              
        cnt = cnt + 1;
        shList = find(label==1);
        
        [ pairList, vector, candidate ]= generate_pairList( fn, reim, seg, label, shList, centroids, cnt );
        pairNum = size(pairList, 1);

        % predict the pairLabel of shList, and choose the largest prob one to be
        % the removal pair.
        load('..\data\model\model.mat');
        disp 'Pair region classification'
        %     normalvector = vecter./repmat(sqrt(sum(normfactor.^2,1)),size(vecter,1),1);
        normalvector = mapminmax('apply', vector', setting);
        normalvector = normalvector';
        [pred, accuracy, prob]=libsvmpredict(zeros(pairNum, 1), normalvector, model, '-b 1');
        %     [pred, prob] = predict(vecter, candidate);
        removal_pair = zeros(length(shList(:)), 2);
        for i = 1 : length(shList(:))
            shNo = shList(i);
            class = pred((i-1)*candidate + 1: (i-1)*candidate + candidate);
            allpr = prob((i-1)*candidate + 1: (i-1)*candidate + candidate, 1);
            candid = pairList((i-1)*candidate + 1: (i-1)*candidate + candidate, 2);
            positivepr = allpr;
            positivepr(class==0) = 0;
            if isempty(positivepr(positivepr > 0))
                smvector = normalvector((i-1)*candidate + 1: (i-1)*candidate + candidate, :);
                [smpred, smprob] = predict(smvector);
                x = find(smpred == 1);
                removal_pair(i, :) = [shNo, candid(x)];
            else
                maxpr = max(positivepr);
                x = find(positivepr == maxpr, 1);
                removal_pair(i, :) = [shNo, candid(x)];
            end
        end
      
        disp 'Remove!'
        [reim, reList] = removal(reim, seg, removal_pair, shList, mask);
        label(shList(reList==1)) = 0;
        for k  = 1 : length(reList_sh)
            mask(seg == reList_sh(k)) = 0;
        end
        imwrite(reim, ['..\data\removal\' fn '_final' int2str(cnt) '_SILC.jpg']);
        
        % no update, choose the nearest
        if isempty(reList(reList==1))
            for k = 1 : length(shList)
                shNo = shList(k);
                boundary = imdilate(uint8(seg == shNo), eye(3)) - uint8(seg==shNo);
                near = seg(boundary==1);
                near = unique(near(:));
                near = near(label(near)==0);
                if isempty(near)
                    break;
                else
                    pairList(k, 2) = near(1);
                end
            end
            
            disp 'No Update Remove!'
            [reim, reList] = removal(reim, seg, pairList, shList, mask);
            imwrite(reim, ['..\data\removal\' fn '_final_extra_SILC' '.jpg']);
            break;
        end
        
   end
   
   disp 'Finish!'
%     imwrite(reim, ['..\data\removal\' fn '_final.jpg']);

end
