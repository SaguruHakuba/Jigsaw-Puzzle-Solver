%Train SVM


%Loop through training, validation and test folders and get their features
%and classes.
folders = {'train';'validation';'test'};
for k = 1:size(folders,1)
    folder = folders{k};
    fprintf(['Starting Feature Extraction for ' folder '\n']);
    files = dir(fullfile([folder '\'],'*.tif'));
    %initialize feature vector:
    features = [];
    classes = [];
    for j=1:size(files)
        img_name = [folder '\' files(j).name];
        img = imread(img_name);
        img = img(:,:,1:3);
        mask = get_mask_edge(img);
        numbered_mask = bwlabel(mask);

        %Load array of truth with each row in the form p1 p2 s1 s2, given that each
        %row contains the sides of 2 pieces that fit together
        load([folder '\' files(j).name(1:end-4) '.mat']); %matrix is called 'match'

        num_pieces = max(max(numbered_mask));
        pieces = [];
        for p = 1:num_pieces
            pieces = [pieces;PuzzlePiece(p,numbered_mask)];        
        end

        %Now loop through pieces to generate features for each fit
        for p1 = 1:num_pieces-1
            fprintf(['Finding Features for Piece ' int2str(p1) '\n']);
            for s1 = 1:4
                for p2 = p1+1:num_pieces
                    for s2 = 1:4
                        %Add a row to the feature vector only if it is a
                        %concave and convex shape.
                        if (pieces(p1).Sides(s1)+pieces(p2).Sides(s2)==3)
                            %Set the class equal to 0 for no match
                            c=-1;

                            %If this combination of pieces and sides is found in
                            %the matching piece array, then set class equal to 1
                            if sum(match(:,1)==p1&match(:,2)==p2&match(:,3)==s1&match(:,4)==s2)|...
                                    sum(match(:,1)==p2&match(:,2)==p1&match(:,3)==s2&match(:,4)==s1)
                                c = 1;
                            end
                            f = get_features(img,numbered_mask,pieces(p1),pieces(p2),s1,s2);
                            if sum(f~=0)
                                features = [features; f];
                                classes = [classes; c];
                            end
                        end
                    end
                end
            end
        end
    end
    save([folder '.mat'], 'features','classes');
end

fprintf('Finding best hyperparameters using training and validation sets');
%Determine best hyperparameters to train with using the validation set
tuning = [];
%loop through bounding boxes and kerner scales
for k = -5:10
    kernelScale = power(2,k);
    for b = -5:10
        boxConstraint = power(2,b);
        
        %Load training set
        load 'train.mat';        
        net = fitcsvm(features,classes, 'KernelFunction', 'rbf', 'KernelScale', kernelScale, 'BoxConstraint', boxConstraint, 'Standardize',true);
        %Load validation set
        load 'validation.mat';
        [label, score] = predict(net,features);
        tp = sum((label>0)&(classes==1));
        fp = sum((label>0)&(classes==-1));
        fn = sum((label<0)&(classes==1));
        tn = sum((label<0)&(classes==-1));
        tpr = tp/(tp+fn);
        fpr = fp/(fp+tn);
        dist = sum(([1,0]-[tpr,fpr]).^2);
        [num_sv, trash] = size(net.SupportVectors);
        tuning = [tuning; kernelScale,boxConstraint, tpr, fpr, dist, num_sv];
    end
end

%Get the hyperparameters associated with the smallest distance from [1 0]
%to [tpr fpr]
best_idx =  find(tuning(:,5) == min(tuning(:,5)));
best_best_idx = find(tuning(best_idx,6) == min(tuning(best_idx,6)));
best_idx = best_idx(best_best_idx(1));
kernelScale = tuning(best_idx,1);
boxConstraint = tuning(best_idx,2);

fprintf('Finding the best threshold');
load 'train.mat';        
net = fitcsvm(features,classes, 'KernelFunction', 'rbf', 'KernelScale', kernelScale, 'BoxConstraint', boxConstraint, 'Standardize',true);

load 'test.mat'
[label,score] = predict(net, features);

ROC = [];
%Sweep through thresholds
for threshold = linspace(-2,2,201)
    tp = sum((score(:,2)>threshold)&(classes==1));
    fp = sum((score(:,2)>threshold)&(classes==-1));
    fn = sum((score(:,2)<threshold)&(classes==1));
    tn = sum((score(:,2)<threshold)&(classes==-1));
    tpr = tp/(tp+fn);
    fpr = fp/(fp+tn);
    dist = sum(([1,0]-[tpr,fpr]).^2);
    ROC = [ROC; threshold, tpr, fpr, dist];
end

threshold = ROC(find(ROC(:,4)==min(ROC(:,4))),1);
threshold = max(threshold);
        
save('SVM.mat','net','kernelScale','boxConstraint','threshold');

function [f] = get_features(img,numbered_mask,p1,p2,s1,s2)
    probs = getColorMatchFeatures([p1,p2],[s1,s2],img);
    c11 = p1.Corners(s1,:);
    c12 = p1.Corners(mod(s1,4)+1,:);
    c21 = p2.Corners(s2,:);
    c22 = p2.Corners(mod(s2,4)+1,:);
    d1 = sum((c11-c12).^2);
    d2 = sum((c21-c22).^2);
    dist_diff = sqrt(abs(d1-d2));
    [piece1mask, piece2mask, fusedMask] = rotate_piece_2(p1,p2,numbered_mask,s1,s2,img);
    piece1mask = abs(piece1mask);
    piece2mask = abs(piece2mask);    
    piece1mask = piece1mask(:,:,1)+piece1mask(:,:,2)+piece1mask(:,:,3)>0;
    piece2mask = piece2mask(:,:,1)+piece2mask(:,:,2)+piece2mask(:,:,3)>0;
    if((max(max(bwlabel(piece1mask)))==1)&(max(max(bwlabel(piece2mask)))==1))        
        prob_shape = shapeProbability(piece1mask, piece2mask, fusedMask, [p1.Sides(s1), p2.Sides(s2)]);
        f = [probs dist_diff prob_shape];
    else
        f=0;
    end
end