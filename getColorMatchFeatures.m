%% ([piece1, piece2], [side1, side2])

function [prob] = getColorMatchFeatures(pieces, sides, img)
    
    side1Array = getSideArray(pieces(1), sides(1), img);
    side2Array = getSideArray(pieces(2), sides(2), img);
    
    % piece 2 needs to be flipped for direct comparison with piece 1
    side2Array = flipud(side2Array);
    
    % get the means for each segment of a side
    side1Means = getRGBmeans(side1Array);
    side2Means = getRGBmeans(side2Array);
    
    
    
    
    %% find the color distance and normalize value
    prob = RGBDistanceProb(side1Means, side2Means);
    

end

function RGBmeans = getRGBmeans(sideArray)

    step = floor(length(sideArray)/3);
    
    RGBmeans = [];
    for i = 1:3
        tempArray = sideArray((i-1)*step + 1:i*step, :,:);
        Rmean = mean(tempArray(:,1,1));
        Gmean = mean(tempArray(:,1,2));
        Bmean = mean(tempArray(:,1,3));
        
        RGBmeans = cat(1,RGBmeans, [Rmean, Gmean, Bmean]);
    end

end

function sideArray = getSideArray(piece, side, img)
    % create side array for piece
    
    piecePerm = piece.Perimeter;
    
    % find first corner index in perimeter vector
    pieceCorner1 = piece.Corners(side,:);
    [~, pieceIndex1] = ismember(pieceCorner1, piecePerm, 'rows');
    
    % find second corner index in perimeter vector
    pieceCorner2 = piece.Corners(mod(side,4) + 1, :);
    [~, pieceIndex2] = ismember(pieceCorner2, piecePerm, 'rows');
    
    if side==4
        sideIndexArray = [piecePerm(pieceIndex1 : end,:); piecePerm(1 : pieceIndex2,:)];
    else
        sideIndexArray = piecePerm(pieceIndex1 : pieceIndex2,:);
    end
    
    % create array of image data from the side indices
    sideArray = [];
    for i = 1:length(sideIndexArray)
       sideArray = cat(1, sideArray, img(sideIndexArray(i,1), sideIndexArray(i,2), :) );
    end
    
end


function totalProb = RGBDistanceProb(means1, means2)
    totalProb = zeros(1,3);
        
    for i=1:3
        
        RGB1 = means1(i,:);
        RGB2 = means2(i,:);
        
        a1 = (RGB1(1) - RGB2(1))^2;
        a2 = (RGB1(2) - RGB2(2))^2;
        a3 = (RGB1(3) - RGB2(3))^2;
    
        colorDistance = sqrt(a1+a2+a3);
        prob = normalizeProbability(colorDistance);
        totalProb(i) = prob;
    end
    
    
end

function prob = normalizeProbability(colorDistance)

    maxDistance = sqrt(255^2 + 255^2 + 255^2);
    distanceRatio = colorDistance/maxDistance;
    prob = 1-distanceRatio;

end