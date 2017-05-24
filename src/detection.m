clc;clear;
addpath('..\requirement\meanshift');
addpath('..\requirement\libsvm-mat-3.0-2\source');
addpath('..\requirement\FastEMD');
addpath('..\requirement\SLIC');
addpath('..\data');
addpath('utils')

imdir = dir(fullfile('..\data\test\test_origin', '*.png'));
imlist = {imdir.name};
imdir = dir(fullfile('..\data\test\test_origin', '*.png'));
imlist = {imdir.name};

imlist = {'lssd24.jpg'};

for f = 1 : length(imlist)
    fullfn = imlist{f};
    fn = fullfn(1:end-4);
    im = imread(['..\data\test\test_origin_first\' fullfn]);
    
%     gray = rgb2gray(im);
%     light_mask = double(bwareaopen(im2bw(gray, graythresh(gray)),200));
%     h = fspecial('gaussian',20,0.5);
%     light_mask = imfilter(light_mask,h);
%     mask = 1 - light_mask;
%     bim=im2bw(mask);  
    
    J = imadjust(im,[0.3,0.7],[]);
    Labim = RGB2Lab(im2double(J));
    im_L = Labim(:,:,1);
    im_L = im_L ./ 100 * 255;
    threshold = 0.6;
    bw = (im_L > max(im_L(:))*threshold);
    L_light_mask = double(bwareaopen(bw,200));
    h = fspecial('gaussian',20,0.5);
    L_light_mask = imfilter(L_light_mask,h);
    L_mask = 1 - L_light_mask;
    bw_L = im2bw(L_mask);    
    imwrite(bw_L, ['..\data\test\test_mask\origin_' fn '.png'])
    
%     figure(1);
%     imshow(bw_L);
%     figure(2);
%     imshow(bim);
%     pause();
    
%     SE=strel('arbitrary',eye(5)); 
%     mask=imclose(bim,SE); 
%     temp = zeros(size(mask, 1), size(mask, 2));
%     temp(mask==1) = 1;
%     mask = temp;

    SE=strel('arbitrary',eye(5)); 
    mask=imclose(bw_L,SE); 
    temp = zeros(size(mask, 1), size(mask, 2));
    temp(mask==1) = 1;
    mask = temp;
    
    try 
            load(['..\data\segment\' fn '_seg.mat']);
    catch exp1
             disp 'Segmenting'
               [dummy, seg] = edison_wrapper(im, @RGB2Luv, ...
                   'SpatialBandWidth', 9, 'RangeBandWidth', 15, ...
                   'MinimumRegionArea', 200);
               seg = seg + 1;
%               [l, Am, C] = slic(im, 500, 10, 1, 'median');
%               seg = spdbscan(l, C, Am, 5);
              save(['..\data\segment\' fn '_seg.mat'], 'seg');
    end
    
    numlabel = length(unique(seg(:)));
    
    % get centers of all segs
    s = regionprops(seg, 'Centroid');
    centroids = cat(1,s.Centroid);
    
    S = regionprops(seg, 'Area');
    area = [S.Area];
    
%     a=edge(double(seg)/numlabel,'canny',1e-7);
%     imnew=im;
%     for i=1:3
%         b=im(:,:,i);
%         b(a)=127;
% 
%         imnew(:,:,i)=b;
%     end
%     clf,
%     figure(1),
%     imshow(imnew);

    
    
    P = 20;
    
    newmask = zeros(size(mask, 1), size(mask, 2));
    for i = 1 : numlabel
        seg_area = (seg == i);
        if area(i) < P
            newmask(seg_area) = 0;
            continue;
        end
        if mean(mask(seg_area)) > max(mask(:))/2
            newmask(seg_area) = 1;
        else
            newmask(seg_area) = 0;
        end
    end
        
    imwrite(newmask, ['..\data\test\test_mask\detection_' fn '.png'])
end