addpath('../meanshift');
addpath('../used_desc');
for i=1:32
    fn=[int2str(i) '.png'];
    outfn=['../data/Our_train/annt_' int2str(i) '.mat'];
    load(outfn);
   
    annotated = exist('allshadow', 'var');
    % get centers of all segs
    s = regionprops(seg, 'Centroid');
    centroids = cat(1,s.Centroid);

    a=edge(double(seg)/numlabel,'canny');
    imnew=im;
    for i=1:3
        b=im(:,:,i);
        b(a)=0;

        imnew(:,:,i)=b;
    end
    clf,
    figure(1),
    imshow(imnew);

    if ~annotated
        allshadow = [];
    end
    fprintf(1, 'Shadow\n');
    
    hold on

    %visualize existing annotation
    if annotated
      for i = 1 : size(allshadow,1)
        plot(centroids(allshadow(i),1), centroids(allshadow(i),2), 'bo');
      end
    end

    while 1
        [x1 y1 b] = ginput(1);
        if b=='q'
            break;
        end
        if b=='d'
            allshadow(end,:)=[];
            continue;
        end
        x1=int32(x1);y1=int32(y1);
        hold on, plot([x1], [y1], 'bo');
        i = seg(y1, x1);
        allshadow = [allshadow; i];
        fprintf(1,' %d\n', size(allshadow,1));
    end

    if ~annotated
        allnonshadow = [];
    end
    fprintf(1, 'Nonshadow\n');
    
    hold on

    %visualize existing annotation
    if annotated
      for i = 1 : size(allnonshadow,1)
        plot(centroids(allnonshadow(i),1), centroids(allnonshadow(i),2), 'r+');
      end
    end

    hold on
    while 1
        [x1 y1 b] = ginput(1);
        if b=='q'
            break;
        end
        if b=='d'
            allnonshadow(end,:)=[];
            continue;
        end
        x1=int32(x1);y1=int32(y1);
        hold on, plot([x1], [y1], 'r+');
        i = seg(y1, x1);
        allnonshadow = [allnonshadow; i];
        fprintf(1,'%d', size(allnonshadow,1));
    end
    fprintf(1, 'saving\n');
    save(outfn, 'im', 'seg', 'numlabel', 'alldiff', 'allsame', 'allirre', 'allshadow', 'allnonshadow');
end
