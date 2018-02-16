function [prob] = get_prob(img,pieces_mask,p1,p2,s1,s2)
    prob_thresh = 0.8;

    % Find probability that the two edges fit together via shape
    [piece1mask, piece2mask, fusedMask] = rotate_piece_2(p1,p2,pieces_mask,s1,s2,img);
    piece1mask = abs(piece1mask);
    piece2mask = abs(piece2mask);    
    piece1mask = piece1mask(:,:,1)+piece1mask(:,:,2)+piece1mask(:,:,3)>0;
    piece2mask = piece2mask(:,:,1)+piece2mask(:,:,2)+piece2mask(:,:,3)>0;
    shapeProb = shapeProbability(piece1mask, piece2mask, fusedMask, [p1.Sides(s1), p2.Sides(s2)]);
    
    % TODO:  Find probability that the two edges fit together via color
    [colorProb] = getColorMatchFeatures([p1,p2],[s1,s2], img);

    % TODO:  Combine probabilities
    prob = combine_prob(shapeProb,colorProb(1), colorProb(2), colorProb(3));
end

function [prob] = combine_prob(prob1, prob2, prob3, prob4)
    prob = prob1*prob2;
end