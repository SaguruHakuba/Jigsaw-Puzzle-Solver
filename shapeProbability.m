% convexity is an array in form [puzzlepiece1.side(4),
% puzzlepiece2.side(1)] ~= [1,2]
function [Prob] = shapeProbability( p1Mask, p2Mask, fusedMask, convexity)

% determine which piece is convex, for the side we are putting together.
if sum(convexity) ~= 3
    Prob = 0;
else
    % find the corners of our pieces
    
    piece1region = regionprops(p1Mask, 'Area');
    piece2region = regionprops(p2Mask, 'Area');
    
    if piece1region.Area < piece2region.Area
        smallestArea = piece1region.Area;
    else
        smallestArea = piece2region.Area;
    end
    
    sideArea = smallestArea/4;
    whiteArea = length(find(fusedMask(:,:,1) == 255 & fusedMask(:,:,2) == 255 & fusedMask(:,:,3) == 255));
    
    % no match
    Prob = (sideArea-whiteArea)/sideArea;
end
end