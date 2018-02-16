img2 = imread('Images/IMG_20180127_123804.jpg');
img2 = rgb2gray(img2);
img2 = imresize(img2,[512,512]);
img1 = (img2(1:100,1:100)+img2(1:100,end-99:end)+img2(end-99:end,1:100)+img2(end-99:end,end-99:end))/4;

c = normxcorr2(img1,img2);
figure, surf(c), shading flat

[ypeak, xpeak] = find(c==max(c(:)));
yoffSet = ypeak-size(img1,1);
xoffSet = xpeak-size(img1,2);

yoffSet = gather(ypeak-size(img1,1));
xoffSet = gather(xpeak-size(img1,2));

figure
imshow(img2);
imrect(gca, [xoffSet+1, yoffSet+1, size(img1,2), size(img1,1)]);