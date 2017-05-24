addpath('../meanshift');
addpath('../used_desc');
addpath('../SLIC');
addpath('../data');

for i = 1 : 32
    fn=['../data/UCB_train/origin/' int2str(i) '.png'];
    outfn=['../data/UCB_train/origin/annt_' int2str(i) '.mat'];
    im= imread(fn);
    
    annotated = 0;
     
    if exist(outfn, 'file')
       load(outfn,'im','seg','numlabel','allshadow');
       annotated = 1;
    end
	

	mask = im;
	shSum = zeros(size(im, 1), size(im, 2));
    shSum = (shSum==1);
	for j = 1 : length(allshadow(:))
		shNo = allshadow(j);
		segsh = (seg == shNo);
		shSum = shSum | segsh;
	end
	
	mask = zeros(size(seg, 1), size(seg, 2));
	mask = uint8(mask);
	mask(shSum) = 255;
	
	imwrite(mask, ['../data/UCB_train/mask/' int2str(i) '.png']);
end