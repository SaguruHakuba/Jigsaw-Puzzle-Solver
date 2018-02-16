img1 = imread('Images/1_3_B.tif');
img2 = imread('Images/1_4_B.tif');
grayimage1 = rgb2gray(img1);
grayimage2 = rgb2gray(img2);
LABimage1 = rgb2lab(img1);
LABimage2 = rgb2lab(img2);
YCBCRimage1 = rgb2ycbcr(img1);
YCBCRimage2 = rgb2ycbcr(img2);
HSVimage1 = rgb2hsv(img1);
HSVimage2 = rgb2hsv(img2);

doubleimg1 = double(img1);
r1 = doubleimg1(:,:,1);
g1 = doubleimg1(:,:,2);
b1 = doubleimg1(:,:,3);
v1 = double(grayimage1);

r = HSVimage1(:,:,1);
g = HSVimage1(:,:,2);
b = HSVimage1(:,:,3);
HSVmask = imfill((g<0.6) & (b>0.1),'holes');
HSVmask = bwareaopen(HSVmask, 60);
figure(101);imshow(HSVmask);

bgrnd = mean([mean(mean(doubleimg1(1:20,1:20,:))),mean(mean(doubleimg1(1:20,end-19:end,:))),mean(mean(doubleimg1(end-19:end,1:20,:))),mean(mean(doubleimg1(end-19:end,end-19:end,:)))]);
bgrnd_r1 = bgrnd(:,:,1);
bgrnd_g1 = bgrnd(:,:,2);
bgrnd_b1 = bgrnd(:,:,3);
bgrnd_v1 = mean([mean(mean(grayimage1(1:20,1:20))),mean(mean(grayimage1(1:20,end-19:end))),mean(mean(grayimage1(end-19:end,1:20))),mean(mean(grayimage1(end-19:end,end-19:end)))]);

mask_bgrnd = sqrt(((r1-bgrnd_r1).^2 + (g1-bgrnd_g1).^2 + (b1-bgrnd_b1).^2))<105;
mask_graybgrnd = sqrt((v1-bgrnd_v1).^2)<105;

% imshowpair(mask_bgrnd,mask_graybgrnd,'montage');

% anewmask = bwareaopen(mask_bgrnd,50);
% anewmask = imfill(anewmask,'holes');

cc = bwlabel(anewmask,4);
minsize = 500;
for i = 1:max(max(cc))
    if sum(sum(cc==i))<minsize
        anewmask(find(cc==i))=0;
    end
end

cc = bwlabel(~anewmask,4);
minsize = 500;
for i = 1:max(max(cc))
    if sum(sum(cc==i))<minsize
        anewmask(find(cc==i))=1;
    end
end

anewmask = bwareaopen(mask_bgrnd,50);
anewmask = imfill(anewmask,'holes');
    
% imshow(anewmask);
% imshow(uint8(anewmask).*img1);
