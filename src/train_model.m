clc; clear;
addpath('..\data');
addpath('..\requirement\libsvm-mat-3.0-2\source');
addpath('utils')

load(['..\data\cache\train_feature.mat'], 'finalvector', 'finalLabel');
disp 'Training!'
% [coef,score,latent] =  princomp(finalvector);
label = double(finalLabel(:,3));
% normfactor = sqrt(sum(finalvector.^2,1));
% normalvector = finalvector./repmat(sqrt(sum(normfactor.^2,1)),size(finalvector,1),1);
[normalvector, setting] = mapminmax(finalvector');
normalvector = normalvector';
num = 9;
libsvmtrain(label, normalvector(:,1:num), '-c 1 -t 2 -g 0.3 -v 2');
model = libsvmtrain(label, normalvector(:,1:num), '-c 1 -t 2 -g .3 -b 1');
save('..\data\model\model.mat', 'model', 'setting');