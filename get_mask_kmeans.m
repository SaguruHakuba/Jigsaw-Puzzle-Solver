function [mask] = get_mask_kmeans(img)
    num_colors = 100;
    
    resize_factor = ceil(sqrt(size(img,1)*size(img,2))/600);
    new_img = double(rgb2lab(imresize(img,[size(img,1)/resize_factor,size(img,2)/resize_factor])));
    img_2d = double(reshape(new_img(:,:,2:3),size(new_img,1)*size(new_img,2),2));
    [cluster_idx,cluster_center] = kmeans(img_2d,num_colors, 'distance','sqEuclidean','Replicates',3);
    mask = reshape(cluster_idx,size(new_img,1),size(new_img,2));
    cluster_sizes = [sum(sum(mask==1)),sum(sum(mask==2))];
    background_clusters = [mask(1,:) mask(end,:) mask(:,1)' mask(:,end)'];
    background_clusters = unique(background_clusters);
    edges = edge(rgb2gray(uint8(new_img)));
    for k = 1:size(background_clusters,2)
        mask(find(mask==background_clusters(k)))=0;
    end  
    mask = imresize(mask,[size(img,1),size(img,2)]);
end