function [score] = get_score(net,img,numbered_mask,p1,p2,s1,s2)
    %This function gathers all the features to pass to the SVM, then passes
    %them to the pre-trained SVM, which returns a score.
    
    if p1.Sides(s1)+p2.Sides(s2)==3
    
        %Get the color matching features
        probs = getColorMatchFeatures([p1,p2],[s1,s2],img);

        %Get the difference in sidelength
        c11 = p1.Corners(s1,:);
        c12 = p1.Corners(mod(s1,4)+1,:);
        c21 = p2.Corners(s2,:);
        c22 = p2.Corners(mod(s2,4)+1,:);
        d1 = sum((c11-c12).^2);
        d2 = sum((c21-c22).^2);
        dist_diff = sqrt(abs(d1-d2));

        %Rotate the pieces and align them
        [piece1mask, piece2mask, fusedMask] = rotate_piece_2(p1,p2,numbered_mask,s1,s2,img);
        piece1mask = abs(piece1mask);
        piece2mask = abs(piece2mask);    
        piece1mask = piece1mask(:,:,1)+piece1mask(:,:,2)+piece1mask(:,:,3)>0;
        piece2mask = piece2mask(:,:,1)+piece2mask(:,:,2)+piece2mask(:,:,3)>0;

        %Get the probability that the shapes match up
        prob_shape = shapeProbability(piece1mask, piece2mask, fusedMask, [p1.Sides(s1), p2.Sides(s2)]);

        %Store them all in the feature vector to pass to the SVM
        f = [probs dist_diff prob_shape];
        score = combine_prob(net,f);
    else
        score = -100;
    end
end

function [score] = combine_prob(net,f)
    [label score] = predict(net,f);
    score = score(2);
end