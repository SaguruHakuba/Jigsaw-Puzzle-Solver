%Put in whatever images you want to use here
folder = 'Full_Images\';
files = dir(fullfile(folder,'*.jpg'));
for j = 1:size(files)
    img_name = [folder files(j).name];
    img = imread(img_name);
    %Check to see if the mask has already been generated
    if ~exist([img_name(1:end-4),'_mask_1.tiff'])    
        %Generate a mask of the puzzle pieces
        mask = get_mask(img);
        imwrite(mask,[img_name(1:end-4),'_mask_1.tiff']);
    else
        mask = imread([img_name(1:end-4),'_mask_1.tiff']);
    end
end