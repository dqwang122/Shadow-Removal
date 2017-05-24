clc;clear;
addpath('..\requirement\meanshift');
addpath('..\requirement\FastEMD');
addpath('..\requirement\SLIC');

addpath('..\data');
addpath('utils')

maskdir = dir(fullfile('..\data\train\train_mask\', '*.png'));
masklist = {maskdir.name};
imdir = dir(fullfile('..\data\train\train_origin\', '*.jpg'));
imlist = {imdir.name};
% fnlist = {'lssd1', 'lssd2', 'lssd3', 'lssd4', 'lssd5'};

for f = 1 : length(imlist)
    if f == 1 || f ==10
        continue;
    end
    % For a image
    fullfn = imlist{f};
    fn = fullfn(1:end-4);
    mask = imread(['..\data\train\train_mask\' fn '.png']);
    im = imread(['..\data\train\train_origin\' fn '.jpg']);

%     try
%         load(['..\data\segment\' fn '_seg.mat']);
%     catch exp1
%         disp 'Segmenting'
% 		[dummy seg] = edison_wrapper(im, @RGB2Luv, ...
% 			'SpatialBandWidth', 9, 'RangeBandWidth', 15, ...
% 			'MinimumRegionArea', 200);
% 		seg = seg + 1;
%         save(['..\data\segment\' fn  '_seg.mat'], 'seg');
%     end

    load(['..\data\train\train_origin\annt_' fn '.mat'], 'im','seg','alldiff','allsame');
    
    segnum = length(unique(seg(:)));

    % label each region as shadow ( = 1) or lit ( = 0)
    label = zeros(segnum, 1);
    for i = 1:segnum
        temp = mean(mask(seg == i));
        if temp > 0
            label(i, 1) = 1;
        else
            label(i, 1) = 0;
        end
    end
    shList = find(label==1);
    
    pairLabel = [];
    for i = 1 : size(alldiff, 1)
        startNo = alldiff(i, 1);
        endNo = alldiff(i, 2);
        if startNo == endNo || label(startNo, 1) ~= 1 || label(endNo, 1) ~= 0
            continue;
        end
        pairLabel = [pairLabel; [startNo, endNo, 0]];
    end
    for i = 1 : size(allsame, 1)
        startNo = allsame(i, 1);
        endNo = allsame(i,2);
        if startNo == endNo || label(startNo, 1) ~= 1 || label(endNo, 1) ~= 0
            continue;
        end
        pairLabel = [pairLabel; [startNo, endNo, 1]];
    end

    
    pairNum = size(pairLabel, 1);
     % features for classifier of lit pairs
    try 
        load(['..\data\cache\train_feature.mat']);
        disp 'Generate feature!'
        I = eye(3,3);
        vector = zeros(pairNum, 9);
        for i = 1 : pairNum
            shNo = pairLabel(i, 1);
            shadow = im;
            core_seg_sh = imerode(uint8(seg == shNo),I);
            for ch = 1 : 3
                c = shadow(:, :, ch);
                c(core_seg_sh==0) = 0;
                shadow(:, :, ch) = c;
            end

            litNo = pairLabel(i, 2);
            lit = im;
            core_seg_lit = imerode(uint8(seg == litNo),I);
            for ch = 1 : 3
                c = lit(:, :, ch);
                c(core_seg_lit==0) = 0;
                lit(:, :, ch) = c;
            end
            vector(i, :) = generate_feature(im, shadow, lit, core_seg_sh, core_seg_lit);
        end
        finalvector = [finalvector; vector];
        finalLabel = [finalLabel; pairLabel];
        save(['..\data\cache\train_feature.mat'], 'finalvector', 'finalLabel');
    catch exp1
        disp 'Generate the feature of the first picture!'
        I = eye(3,3);
        vector = zeros(pairNum, 9);
        for i = 1 : pairNum
            shNo = pairLabel(i, 1);
            shadow = im;
            core_seg_sh = imerode(uint8(seg == shNo),I);
            for ch = 1 : 3
                c = shadow(:, :, ch);
                c(core_seg_sh==0) = 0;
                shadow(:, :, ch) = c;
            end

            litNo = pairLabel(i, 2);
            lit = im;
            core_seg_lit = imerode(uint8(seg == litNo),I);
            for ch = 1 : 3
                c = lit(:, :, ch);
                c(core_seg_lit==0) = 0;
                lit(:, :, ch) = c;
            end
        %     imshow(lit);
            vector(i, :) = generate_feature(im, shadow, lit, core_seg_sh, core_seg_lit);
        end
        finalvector = vector;
        finalLabel = pairLabel;
        save(['..\data\cache\train_feature.mat'], 'finalvector', 'finalLabel');
    end

end

% train_model
