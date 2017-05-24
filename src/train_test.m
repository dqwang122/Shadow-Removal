clc;clear;
addpath('..\requirement\meanshift');
addpath('..\requirement\libsvm-mat-3.0-2\source');
addpath('..\requirement\FastEMD');
addpath('..\requirement\SLIC');
addpath('..\data');
addpath('utils')

% maskdir = dir('data\test\test_mask', '*.png');
% masklist = {maskdir.name};
% imdir = dir(fullfile('data\test\test_origin', '*.jpg'));
% imlist = {imdir.name};

fn = 'lssd9';
mask = imread(['..\data\train\train_mask\' fn '.png']);
im = imread(['..\data\train\train_origin\' fn '.jpg']);

% For a image
% fullfn = imlist{1};
% fn = fullfn(1:end-4);
% mask = imread(['data\test\test_mask\' fn '.png']);
% im = imread(['data\test\test_origin\' fn '.jpg']);
try
	load(['..\data\segment\' fn '_seg.mat']);
catch exp1
	disp 'Segmenting'
     [l, Am, C] = slic(im, 500, 10, 1, 'median');
      seg = spdbscan(l, C, Am, 5);
     imshow(drawregionboundaries(seg, im, [255 255 255]));
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

load(['..\data\train\train_origin\annt_' fn '.mat']);
    
pairLabel = [];
% for i = 1 : length(alldiff)
%     startNo = alldiff(i, 1);
%     endNo = alldiff(i, 2);
%     if startNo == endNo || label(startNo, 1) ~= 1 || label(endNo, 1) ~= 0
%         continue;
%     end
%     pairLabel = [pairLabel; [startNo, endNo, 0]];
% end
for i = 1 : length(allsame)
    startNo = allsame(i, 1);
    endNo = allsame(i,2);
    if startNo == endNo || label(startNo, 1) ~= 1 || label(endNo, 1) ~= 0
        continue;
    end
    pairLabel = [pairLabel; [startNo, endNo, 1]];
end


pairNum = length(pairLabel);

reim = removal(im, seg, pairLabel, shList, mask);
imwrite(reim, ['..\data\removal\' fn '_nolight.jpg']);

% 
% candidate = 10;
% pairNum = length(shList) * candidate;
% pairList = zeros(pairNum, 2);
% for i = 1 : length(shList):
% % Todo: the 10th nearest region num, shList * 10
%     
% end
% 
% I = eye(3,3);
% % features for classifier of sh-lit pairs
% vecter = zeros(pairNum, 9);
% size = [size(im, 1), size(im, 2)];
% for i = 1 : pairNum
%     shNo = pairList(i, 1);
%     shadow = im;
%     core_seg_sh = imerode(uint8(seg == shNo),I);
%     for ch = 1 : 3
%         c = shadow(:, :, ch);
%         c(core_seg_sh==0) = 0;
%         shadow(:, :, ch) = c;
%     end
% 
%     litNo = pairList(i, 2);
%     lit = im;
%     core_seg_lit = imerode(uint8(seg == litNo),I);
%     for ch = 1 : 3
%         c = lit(:, :, ch);
%         c(core_seg_lit==0) = 0;
%         lit(:, :, ch) = c;
%     end
%     
%     vecter(i, :) = generate_feature(im, shadow, lit, core_seg_sh, core_seg_lit);
%     
% end

% Todo: predict the pairLabel of shList, and choose the largest prob one to be
% the removal pair.


% reim = removal(im, seg, removal_pair, shList, mask);
% imwrite(reim, ['..\data\removal\' fn '_light2.jpg']);

