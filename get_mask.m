function [mask] = get_mask(img)
%     edges_stuff = edge(rgb2gray(img),'canny');
%     grad = get_gradient(rgb2gray(img));
%     im_size = size(img);
%     img_2d = double(reshape(img,im_size(1)*im_size(2),3));
%     
%     num_colors = 2;
%     [cluster_idx,cluster_center] = kmeans(img_2d,num_colors, 'distance','sqEuclidean','Replicates',3);
%     pixel_labels = reshape(cluster_idx,im_size(1),im_size(2));
%     cluster_sizes = [sum(sum(pixel_labels==1)),sum(sum(pixel_labels==2))];
%     mask = pixel_labels==find(cluster_sizes==min(cluster_sizes));
%     
%     cc=bwlabel(mask);
%     for i = 1:max(max(cc))
%         if sum(sum(cc==i))<100
%             mask(find(cc==i))=0;
%         end
%     end

    img = double(img);
    r = img(:,:,1);
    g = img(:,:,2);
    b = img(:,:,3);

    bgrnd = mean([mean(mean(img(1:100,1:100,:))),mean(mean(img(1:100,end-99:end,:))),mean(mean(img(end-99:end,1:100,:))),mean(mean(img(end-99:end,end-99:end,:)))]);
    bgrnd_r = bgrnd(:,:,1);
    bgrnd_g = bgrnd(:,:,2);
    bgrnd_b = bgrnd(:,:,3);

    mask = sqrt(((r-bgrnd_r).^2 + (g-bgrnd_g).^2 + (b-bgrnd_b).^2))>130;
    cc = bwlabel(mask,4);
    
    minsize = 500;
    for i = 1:max(max(cc))
        if sum(sum(cc==i))<minsize
            mask(find(cc==i))=0;
        end
    end

    cc = bwlabel(~mask,4);
    minsize = 500;
    for i = 1:max(max(cc))
        if sum(sum(cc==i))<minsize
            mask(find(cc==i))=1;
        end
    end

end