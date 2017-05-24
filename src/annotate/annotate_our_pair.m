addpath('..\..\requirement\meanshift');
addpath('..\..\requirement\SLIC');
addpath('..\..\data');
for i=1:32
    fn=['..\..\data\train\train_origin\lssd' int2str(i) '.jpg'];
    outfn=['..\..\data\train\train_origin\annt_lssd' int2str(i) '.mat'];
    im= imread(fn);
    org_siz = [size(im, 1) size(im, 2)];
    resiz_ratio = 640/max(org_siz);
    
    annotated = 0;
     
    if exist(outfn, 'file')
       load(outfn,'im','seg','numlabel','alldiff','allsame');
       annotated = 1;
    end
    
    if ~annotated
       im = imread(fn);
       im = (double(im)/255);
    
        try 
            load(['..\..\data\segment\' int2str(i) '_seg.mat']);
        catch exp1
             disp 'Segmenting'
               [dummy seg] = edison_wrapper(im, @RGB2Luv, ...
                   'SpatialBandWidth', 9, 'RangeBandWidth', 15, ...
                   'MinimumRegionArea', 200);
               seg = seg + 1;
              % [l, Am, C] = slic(im, 500, 10, 1, 'median');
              % seg = spdbscan(l, C, Am, 5);
              save(['..\..\data\segment\' int2str(i) '_seg.mat'], 'seg');
        end
    end

    numlabel = length(unique(seg(:)));
    
    % get centers of all segs
    s = regionprops(seg, 'Centroid');
    centroids = cat(1,s.Centroid);
    
    a=edge(double(seg)/numlabel,'canny',1e-7);
    imnew=im;
    
    b =  im(:,:,1);
    b(a)= 255;
    imnew(:,:,1)= b;
    b =  im(:,:,2);
    b(a)= 0;
    imnew(:,:,2)= b;
    b =  im(:,:,3);
    b(a)= 0;
    imnew(:,:,3)= b;
    
%     for i=1:3
%         b=im(:,:,i);
%         b(a)=127;
% 
%         imnew(:,:,i)=b;
%     end
    clf,
    figure(1),
    imshow(imnew);

    if ~annotated
       alldiff = [];
    end
    fprintf(1, 'Different\n');
    
    hold on

    %visualize existing annotation
    if annotated
      for i = 1 : size(alldiff,1)
        pair = alldiff(i,:);	
        plot(centroids(pair,1), centroids(pair,2),'b','LineWidth',1.5);
        plot(centroids(pair(1),1), centroids(pair(1),2), 'bo','LineWidth',1.5);
      end
    end
 
    while 1
        [x1 y1 b] = ginput(1);
        if b=='c'
            break;
        end
        if b=='d'
            alldiff(end,:)=[];
            continue;
        end
        [x2 y2] = ginput(1);
        x1=int32(x1);x2=int32(x2);y1=int32(y1);y2=int32(y2);
        fprintf(1,'%d, %d\n', x1, y1);
        fprintf(1,'%d, %d\n', x2, y2);
        plot([x1 x2], [y1 y2], 'b')
        plot(x1, y1, 'bo');
        i = seg(y1, x1);
        j = seg(y2, x2);
        alldiff = [alldiff; i, j];
        %fprintf(1, '%d: dtext: %.3f, dlab: %.3f, ratio: %.3f, %.3f, %.3f, %.3f\n',...
        %    size(alldiff,1), d_text(i,j), d_lab(i,j), rgbmean(i,:)./rgbmean(j,:), invmean(i)/invmean(j));
    end
    fprintf(1, 'Same\n');
    
    if ~annotated
      allsame = [];
    end
    
    if annotated
      for i = 1 : size(allsame,1)
	pair = allsame(i,:);	
	plot(centroids(pair,1), centroids(pair,2),'r','LineWidth',1.5);
      end
    end

    while 1
        [x1 y1 b] = ginput(1);
        if b=='q'
            break;
        end
        if b=='d'
            allsame(end,:)=[];
            continue;
        end
        [x2 y2] = ginput(1);
        x1=int32(x1);x2=int32(x2);y1=int32(y1);y2=int32(y2);
        hold on, plot([x1 x2], [y1 y2], 'r');
        i = seg(y1, x1);
        j = seg(y2, x2);
        allsame = [allsame; i, j];
        %fprintf(1, '%d: dtext: %.3f, dlab: %.3f, ratio: %.3f, %.3f, %.3f, %.3f\n',...
        %    size(allsame,1), d_text(i,j), d_lab(i,j), rgbmean(i,:)./rgbmean(j,:), invmean(i)/invmean(j));
    end
    fprintf(1, 'saving\n');

    save(outfn, 'im', 'seg', 'numlabel', 'alldiff', 'allsame');
end
