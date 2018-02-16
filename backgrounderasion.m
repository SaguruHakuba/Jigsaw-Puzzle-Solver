function [newimg]= backgrounderasion(img)

r = img(:,:,1);
g = img(:,:,2);
b = img(:,:,3);
mask = ones(size(img(:,:,1)));
mask(find(r >= 90 & r <= 220 & g >= 80 & g<= 200 & b >= 70 & b <= 190)) = 0;

% structureElt = strel('square', 9);
% % structureElt = strel([0 1 0; 1 1 1; 0 1 0]); 
% dilatedMask =  imdilate(mask, structureElt);
% imtool(dilatedMask);

imshow(mask);
