img = imread('original.jpg');
% grayimg = rgb2gray(img);
% [Gmag,Gdir] = imgradient(grayimg,'prewitt');
% figure(151);
% imshowpair(Gmag, Gdir, 'montage');
% newimg = Gdir.*double(Gmag>50);
% imtool(uint8(newimg));

rgb = imread('Images/IMG_20180124_000255.jpg');
lab = rgb2lab(rgb);
% imshow(lab(:,:,1),[0 100]);
imshowpair(lab, rgb, 'montage');