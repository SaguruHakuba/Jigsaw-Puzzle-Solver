function [mask] = get_mask_test(img)
    edges_stuff = edge(rgb2gray(img),'canny');
    grad = get_gradient(rgb2gray(img));
    im_size = size(img);
    img_2d = double(reshape(img,im_size(1)*im_size(2),3));
    
    num_colors = 2;
    [cluster_idx,cluster_center] = kmeans(img_2d,num_colors, 'distance','sqEuclidean','Replicates',3);
    pixel_labels = reshape(cluster_idx,im_size(1),im_size(2));
    cluster_sizes = [sum(sum(pixel_labels==1)),sum(sum(pixel_labels==2))];
    mask = pixel_labels==find(cluster_sizes==min(cluster_sizes));
    
    cc=bwlabel(mask);
    for i = 1:max(max(cc))
        if sum(sum(cc==i))<100
            mask(find(cc==i))=0;
        end
    end