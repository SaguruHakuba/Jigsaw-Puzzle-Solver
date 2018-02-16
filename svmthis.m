mask = imread('mask.tiff');
img = imread('original.jpg');
r = img(:,:,1);
g = img(:,:,2);
b = img(:,:,3);

if(size(img) ~= size(img))
    fprintf('They are not the same size.');
end

[maskA,maskB] = size(mask);
newR = reshape(r,[maskA*maskB,1]);
newG = reshape(g,[maskA*maskB,1]);
newB = reshape(b,[maskA*maskB,1]);

xTrain = double([newR,newG,newB]);
yTrain = double(reshape(mask,[maskA*maskB,1]));
yTrain(find(yTrain(:) == 0)) = -1;


kernelScale=10;
boxConstraint=100;
net = fitcsvm(xTrain, yTrain, 'KernelFunction', 'rbf', 'KernelScale', kernelScale, 'BoxConstraint', boxConstraint);
save('importantbackgroundnet.mat',net);