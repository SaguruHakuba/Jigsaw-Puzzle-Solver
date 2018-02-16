function [piece1Mask, piece2Mask, fusedMask] = put_pieces_together(puzzlePiece1, puzzlePiece2, mask, edge1, edge2)

%% setting up and initializing data
% create a mask for each piece
piece1Mask = mask == puzzlePiece1.Number;
piece2Mask = mask == puzzlePiece2.Number;

% convert the masks to double
piece1Mask = double(piece1Mask);
piece2Mask = double(piece2Mask);

% get the 4x2 integer array of the coordinates of each corner pixel
piece1Corners = puzzlePiece1.Corners;
piece2Corners = puzzlePiece2.Corners;

%Determine the side from the corners
[side1Corners, edge1Wrap] = getCorners(piece1Corners, edge1);
[side2Corners, edge2Wrap] = getCorners(piece2Corners, edge2);

% plot the mask with the corners of the two pieces that are being matched
figure(1)
imshow(mask)
hold on
plot(side1Corners(:,2), side1Corners(:,1), 'b.', side2Corners(:,2), side2Corners(:,1), 'b.', 'MarkerSize', 50)
title('Corners')

% mark the corners by changing their values to -1
piece1Mask = markCorners(piece1Mask, side1Corners);
piece2Mask = markCorners(piece2Mask, side2Corners);


%% orientation rotation
%Figure out which way Puzzle Piece 1 needs to rotate
orientation1 = getOrientation(side1Corners, edge1, edge1Wrap, piece1Corners);
orientation2 = getOrientation(side2Corners, edge2, edge2Wrap, piece2Corners);

%Cases for rotating piecces
side1 = find(orientation1 == 1);
side2 = find(orientation2 == 1);

% getting mask information needed to rotate ready to rotate
piece1region = regionprops(piece1Mask, 'Orientation', 'BoundingBox');
piece1CroppedMask = imcrop(piece1Mask, piece1region(1).BoundingBox);

piece2region = regionprops(piece2Mask, 'Orientation', 'BoundingBox');
piece2CroppedMask = imcrop(piece2Mask, piece2region(1).BoundingBox);

[piece1CroppedMask, piece2CroppedMask] = rotation(piece1CroppedMask,piece2CroppedMask, side1, side2);

%% alignment rotation

[piece1RotationOffset,piece2RotationOffset] = getAlignmentRotationAngle(side1Corners, side2Corners, piece1region, piece2region);
piece1CroppedMask = imrotate(piece1CroppedMask, piece1RotationOffset);
piece2CroppedMask = imrotate(piece2CroppedMask, piece2RotationOffset);

%% recreate mask

[ht, wd] = size(piece1Mask);
piece1Mask = recreateMask(piece1CroppedMask, piece1region, [ht, wd]);

[ht, wd] = size(piece2Mask);
piece2Mask = recreateMask(piece2CroppedMask, piece2region, [ht, wd]);

[temp1, temp2] = find(piece1Mask == -1);
rowMax = length(temp1);
[side1Corners(1:rowMax,1),side1Corners(1:rowMax,2)] = find(piece1Mask == -1);

[temp1, temp2] = find(piece2Mask == -1);
rowMax = length(temp1);
[side2Corners(1:rowMax,1),side2Corners(1:rowMax,2)] = find(piece2Mask == -1);


figure(2)
imshow(imfuse(piece1Mask, piece2Mask));
hold on
plot(side1Corners(:,2), side1Corners(:,1), 'b.', side2Corners(:,2), side2Corners(:,1), 'b.', 'MarkerSize', 50)
title('Corners')

%% translation
[piece1Mask, piece2Mask] = translation(piece1Mask, piece2Mask, side1Corners, side2Corners);


figure(3)
fusedMask = imfuse(piece1Mask,piece2Mask);
imshow(fusedMask)
title('Fused Mask')


end


%% helper functions 

% get the edge numbers of the corners
function [edgeCorners, edgeWrap] = getCorners(puzzlePieceCorners, edgeNum)

edgeWrap = mod(edgeNum, 4) + 1;
edgeCorners = [[puzzlePieceCorners(edgeNum,:)]; [puzzlePieceCorners(edgeWrap,:)]];

end

% Mark the corners of a piece
function pieceMask = markCorners(pieceMask, corners)
rowInd = corners(1,1);
colInd = corners(1,2);
pieceMask(rowInd:rowInd+1, colInd:colInd+1) = -1;

rowInd = corners(2,1);
colInd = corners(2,2);
pieceMask(rowInd:rowInd+1, colInd:colInd+1) = -1;
    
end

% rotates either piece1 or piece2 by the bounding box
function [piece1, piece2] = rotation(piece1, piece2, side1, side2)

% if 2,4 or 4,2 then no rotation
% if 1,3 or 3,1 then no rotation

%if 1,4 or 4,1 then rotate on 1 by 90 degrees clockwise
if (side1 == 1 && side2 == 4)
    piece1 = imrotate(piece1, 270); 
elseif (side1 == 4 && side2 == 1)
    piece2 = imrotate(piece2, 270); 
end

%if 1,2 or 2,1 then rotate on 1 by 90 degrees counter-clockwise
if (side1 == 1 && side2 == 2)
    piece1 = imrotate(piece1, 90);
elseif (side1 == 2 && side2 == 1)
    piece2 = imrotate(piece2, 90);
end

%if equal then rotate 180 degrees (either direction)
if (side1 == side2)
    piece1 = imrotate(piece1, 180);
end

%if 2,3 or 3,2 then rotate on 2 by 90 degrees counter-clockwise
if (side1 == 2 && side2 == 3)
    piece1 = imrotate(piece1, 90);
elseif (side1 == 3 && side2 == 2)
    piece2 = imrotate(piece2, 90);
end

%if 4,3 or 3,4 then rotate on 4 by 90 degrees clockwise
if (side1 == 3 && side2 == 4)
    theta = 90;
    piece1 = imrotate(piece1, theta);
elseif (side1 == 4 && side2 == 3)
    theta = 90;
    piece2 = imrotate(piece2, theta);
end

end

% determines the angle that piece1 and piece2 need to be rotated.
function [piece1RotationOffset,piece2RotationOffset] = getAlignmentRotationAngle(side1Corners, side2Corners, region1, region2)

[~, ind1] = min(side1Corners(:,2));
[~, ind2] = max(side1Corners(:,2));
deltaRow1 = abs(side1Corners(ind1,1) - side1Corners(ind2,1));
deltaColumn1 = abs(side1Corners(ind2,2) - side1Corners(ind1,2));

deltaRow2 = abs(side2Corners(1,1) - side2Corners(2,1));
deltaColumn2 = abs(side2Corners(1,2) - side2Corners(2,2));


    if (abs(region1.Orientation) < 45)
        piece1RotationOffset = region1.Orientation; %atan2d(deltaRow, deltaColumn);
    elseif (region1.Orientation > 0)
        piece1RotationOffset = 90 - region1.Orientation;
    else
        piece1RotationOffset = -(90 + region1.Orientation);
    end
    

   if (abs(region2.Orientation) < 45)
       piece2RotationOffset = region2.Orientation;
   elseif (region2.Orientation > 0)
       piece2RotationOffset = (90 - region2.Orientation);
   else
       piece2RotationOffset = -(90 + region2.Orientation);
   end




end

% translates either piece1 or piece2 in the [x,y] plane to mate them
function [piece1Mask, piece2Mask] = translation(piece1Mask, piece2Mask, side1Corners, side2Corners)

% translate in x
translateByX = 0;
translateByY = 0;

[min1RowR, min1RowIndR] = min(side1Corners(:,1));
min1ColR = side1Corners(min1RowIndR,2);

[max1RowR, max1RowIndR] = max(side1Corners(:,1));
max1ColR = side1Corners(max1RowIndR,2);

[min1ColC, min1ColIndC] = min(side1Corners(:,2));
min1RowC = side1Corners(min1ColIndC,1);

[max1ColC, max1ColIndC] = max(side1Corners(:,2));
max1RowC = side1Corners(max1ColIndC,1);


deltaRow = abs(max1RowR - min1RowR);
deltaColumn = abs(max1ColC - min1ColC);

if (deltaRow > deltaColumn)
    [~, ind1] = min(side1Corners(:,1));
    [~, ind2] = min(side2Corners(:,1));
elseif (deltaRow < deltaColumn)
    [~, ind1] = min(side1Corners(:,2));
    [~, ind2] = min(side2Corners(:,2));
end   
    
if min1ColC < min(side2Corners(:,2))
    translateByX = side2Corners(ind2, 2) - side1Corners(ind1,2);
    piece1Mask = imtranslate(piece1Mask, [translateByX, translateByY]);
elseif min1ColC > min(side2Corners(:,2))
    translateByX = side1Corners(ind1,2) - side2Corners(ind2,2);
    piece2Mask = imtranslate(piece2Mask, [translateByX, translateByY]);    
end

% translate in y
translateByX = 0;
translateByY = 0;
%% yTranslation
if side1Corners(1,1) < side2Corners(1,1)
    translateByY = min(side2Corners(ind2, 1)) - min(side1Corners(ind1,1));
    piece1Mask = imtranslate(piece1Mask, [translateByX, translateByY]);
    
elseif side1Corners(1,1) > side2Corners(1,1)
    translateByY = side1Corners(ind1,1) - side2Corners(ind2,1);
    piece2Mask = imtranslate(piece2Mask, [translateByX, translateByY]);
end

end

%Need to determine current orientation first (will store as array of
%1's and 0's, with top, right, bottom, left)
function orientation = getOrientation(edgeCorners, edge1, edge1Wrap, pieceCorners)
orientation = [0, 0, 0, 0];
if (abs(edgeCorners(1, 1) - edgeCorners(2, 1)) < 100)
    otherPieceCorners = removerows(pieceCorners, 'ind', [edge1, edge1Wrap]);
    if (edgeCorners(1, 1) < otherPieceCorners(1, 1))
        orientation(4) = 1;
    else
        orientation(2) = 1;
    end
elseif (abs(edgeCorners(1, 2) - edgeCorners(2, 2) < 100))
    otherPieceCorners = removerows(pieceCorners, 'ind', [edge1, edge1Wrap]);
    if (edgeCorners(1, 2) < otherPieceCorners(2, 2))
        orientation(3) = 1;
    else
        orientation(1) = 1;
    end
end
end

% addes the cropped mask back into the full sized mask
function uncroppedMask = recreateMask(croppedImg, regionP, sizeOriginal)
uncroppedMask = zeros(sizeOriginal(1), sizeOriginal(2));
y = floor(regionP(1).BoundingBox(2));
x = floor(regionP(1).BoundingBox(1));
[yWidth xWidth] = size(croppedImg);

uncroppedMask(y: y+yWidth-1, x: x+xWidth-1) = croppedImg;

end