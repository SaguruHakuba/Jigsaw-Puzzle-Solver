function [mask] = get_mask_edge(img)
img(:,end-15:end,:) = 0;
hsv_img = rgb2hsv(img);
g = img(:,:,2);

filt_size = 9; %Must be odd number.
hor_edge = fspecial('gaussian',filt_size,2);
hor_edge(ceil(filt_size/2),:) = 0;
hor_edge(1:floor(filt_size/2),:) = -hor_edge(1:floor(filt_size/2),:);

vert_edge = fspecial('gaussian',filt_size,2);
vert_edge(:,ceil(filt_size/2)) = 0;
vert_edge(:,1:floor(filt_size/2)) = -vert_edge(:,1:floor(filt_size/2));

horizontal = filter2(hor_edge,g);
vertical = filter2(vert_edge,g);
mag_grad = sqrt(horizontal.^2+vertical.^2);
mask = mag_grad>5;

mask = bwareaopen(mask,500);
mask = imfill(mask,'holes');
mask = imerode(mask,strel('square',3));
mask = imerode(mask,strel('diamond',3));
mask = bwareaopen(mask,1000);
mask = imfill(mask,'holes');
end