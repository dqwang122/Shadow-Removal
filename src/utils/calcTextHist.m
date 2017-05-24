function desc = calcTextonHist(im)
	gray_im = rgb2gray(im);
	
	load('bsd300_128.mat');
	fim = fbRun(fb,gray_im);
	im = assignTextons(fim, textons);
	[hgt wid] = size(im);
	
	binNum = 128;
	binVal = 1:binNum;
	desc = zeros(1,binNum);
	
	cnt = 0;
	for bin = 1 : binNum
		I =  (im(:)==binVal(bin));
		desc(1, bin) = sum(I);
	end
	
	tmp = sum(desc, 2);
	desc = desc ./ repmat(tmp(:), [1 size(desc,2)]);
	
end