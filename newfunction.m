function [result] = newfunction(img)
% img = imread('Images/IMG_20180204_142602.jpg');
[sizeA, sizeB, sizeC] = size(img);
labIMG = rgb2lab(img);
labMask = get_mask_kmeans(labIMG);
mask = get_mask_kmeans(img);
% YCBCR = rgb2ycbcr(img);
% YCBCRmask = get_mask_kmeans(YCBCR);
% imshowpair(mask,labMask,'montage');
SE = [0,1,0;1,1,1;0,1,0];
edges1 = edge(rgb2gray(imresize(img,[sizeA/10.08,sizeB/10.08])));
edges1 = imclose(edges1,SE);
edges1 = imresize(edges1,[sizeA,sizeB]);
edges2 = edge(rgb2gray(imresize(img,[256,256])));
edges2 = imclose(edges2,SE);
edges2 = imresize(edges2,[sizeA,sizeB]);
edges = edges1 | edges2;

% edges = edge(rgb2gray(imresize(img,[256,256])));
% labMask = imresize(labMask,[256,256]);
% labMask(find(edges == 1)) = 1;
% SEvertical = [0,0,0;1,1,1;0,0,0];
% SEhorizontal = [0,1,0;0,1,0;0,1,0];

% labMask = imerode(imclose(labMask,SEvertical),SEvertical);
% labMask = imerode(imclose(labMask,SEhorizontal),SEhorizontal);

% labMask = imdilate(labMask, SE);
% labMask = imfill(labMask,'holes');
% labMask = imerode(labMask, SE);
% 
% labMask = imresize(labMask,[4032,3024]);
% labMask = imfill(labMask,'holes');
% imtool(labMask);

labMask(find(edges == 1)) = 1;
labMask = imfill(labMask,'holes');
% imshow(labMask);
result = labMask;

% YCBCRmask(find(edges == 1)) = 1;
% YCBCRmask = imfill(YCBCRmask,'holes');
% imshow(YCBCRmask);
% result = YCBCRmask;