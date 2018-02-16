function [pieceOneMask, pieceTwoMask] = put_puzzle_pieces_together(puzzlePiece1, puzzlePiece2, mask, edge1, edge2, img)

%     %Add color from image back to mask
%     codeMask = uint8(mask) .* img;
    
    pieceOneMask = mask == puzzlePiece1.Number;
    pieceTwoMask = mask == puzzlePiece2.Number;

    %Get the 4x2 integer array of the coordinates of each corner pixel clockwise
    pieceOneCorners = puzzlePiece1.Corners;
    pieceTwoCorners = puzzlePiece2.Corners;
    
    %Determine edge from corners (example: edge #3 would be between corner
    %3 and corner 4)
    %Getting just the corners of the edges that need to match (conditional
    %check needed due to base-1 indexing)
    [edgeOneCorners, edge1Wrap] = getCorners(pieceOneCorners, edge1);
    [edgeTwoCorners, edge2Wrap] = getCorners(pieceTwoCorners, edge2);
    
    %Figure out which way Puzzle Piece 1 needs to rotate
    orientation1 = getOrientation(edgeOneCorners, edge1, edge1Wrap, pieceOneCorners);
    orientation2 = getOrientation(edgeTwoCorners, edge2, edge2Wrap, pieceTwoCorners);
    
    %Cases for rotating piecces
    side1 = find(orientation1 == 1);
    side2 = find(orientation2 == 1);
    
    % getting the pieces ready to rotate
    piece1region = regionprops(pieceOneMask, 'Orientation', 'BoundingBox');
    piece1CroppedMask = imcrop(pieceOneMask, piece1region.BoundingBox);
    
    piece2region = regionprops(pieceTwoMask, 'Orientation', 'BoundingBox');
    piece2CroppedMask = imcrop(pieceTwoMask, piece2region.BoundingBox);
    
    
    %if 2,4 or 4,2 then no rotation (this check is technically not needed)
%     if ((side1 == 2 && side2 == 4) || (side1 == 4 && side2 == 2))
%         %DO NOTHING
%     end
    %if 1,3 or 3,1 then no rotation
    
    %if 1,4 or 4,1 then rotate on 1 by 90 degrees clockwise
    if (side1 == 1 && side2 == 4)
        piece1CroppedMask = imrotate(piece1CroppedMask, 270);
%         mask = imrotate(mask, 270);
    elseif (side1 == 4 && side2 == 1)
        piece2CroppedMask = imrotate(piece2CroppedMask, 270);
%         mask = imrotate(mask, 270);
    end
    
    %if 1,2 or 2,1 then rotate on 1 by 90 degrees counter-clockwise
    if (side1 == 1 && side2 == 2)
        piece1CroppedMask = imrotate(piece1CroppedMask, 90);
%         mask = imrotate(mask, 90);
    elseif (side1 == 2 && side2 == 1)
        piece2CroppedMask = imrotate(piece2CroppedMask, 90);
%         mask = imrotate(mask, 90);
    end
    
    %if equal then rotate 180 degrees (either direction)
    if (side1 == side2)
        piece1CroppedMask = imrotate(piece1CroppedMask, 180);
%         mask = imrotate(mask, 180);
    end
    
    %if 2,3 or 3,2 then rotate on 2 by 90 degrees counter-clockwise
    if (side1 == 2 && side2 == 3)
        piece1CroppedMask = imrotate(piece1CroppedMask, 90);
%         mask = imrotate(mask, 90);
    elseif (side1 == 3 && side2 == 2)
        piece2CroppedMask = imrotate(piece2CroppedMask, 90);
%         mask = imrotate(mask, 90);
    end
    
    %if 4,3 or 3,4 then rotate on 4 by 90 degrees clockwise
    if (side1 == 3 && side2 == 4)
        piece1CroppedMask = imrotate(piece1CroppedMask, 270);
%         mask = imrotate(mask, 270);
    elseif (side1 == 4 && side2 == 3)
        piece2CroppedMask = imrotate(piece2CroppedMask, 270);
%         mask = imrotate(mask, 270);
    end
    [ht, wd] = size(pieceOneMask);
    pieceOneMask = recreateMask(piece1CroppedMask, piece1region, [ht, wd]);
    
    [ht, wd] = size(pieceTwoMask);
    pieceTwoMask = recreateMask(piece2CroppedMask, piece2region, [ht, wd]);
 
    
    %translation of puzzle pieces
    rotatedPuzzlePiece1 = PuzzlePiece(puzzlePiece1.Number, mask);
    rotatedPuzzlePiece2 = PuzzlePiece(puzzlePiece2.Number, mask);
    
    %redefine edge corners
    [edgeOneCorners, edge1Wrap] = getCorners(rotatedPuzzlePiece1.Corners, edge1);
    [edgeTwoCorners, edge2Wrap] = getCorners(rotatedPuzzlePiece2.Corners, edge2);
    
%     translateByX = 0;
%     translateByY = 0;
%     if edgeOneCorners(1,1) < edgeTwoCorners(1,1)
%         translateByX = edgeOneCorners(1, 1) - edgeTwoCorners(1,1) + 9;
%         pieceOneMask = imtranslate(pieceOneMask, [translateByX, translateByY]);
%     elseif edgeOneCorners(1,1) > edgeTwoCorners(1,1)
%         translateByX = edgeOneCorners(1,1) - edgeTwoCorners(1,1) + 9;
%         pieceTwoMask = imtranslate(pieceTwoMask, [translateByX, translateByY]);
%     else
%         translateByX = 9;
%         pieceOneMask = imtranslate(pieceOneMask, [translateByX, translateByY]);
%     end
    
%     if edgeOneCorners(1,1) < edgeTwoCorner(1,1)
%         translateByX = edgeOneCorners(1, 1) - edgeTwoCorners(1,1) + 9;
%         pieceOneMask = imtranslate(pieceOneMask, [translateByX, translateByY]);
%     elseif edgeOneCorners(1,1) > edgeTwoCorner(1,1)
%         translateByX = edgeTwoCorners(1,1) - edgeOneCorners(1,1) + 9;
%         pieceTwoMask = imtranslate(pieceTwoMask, [translateByX, translateByY]);
%     else
%         translateByX = 9;
%         pieceOneMask = imtranslate(pieceOneMask, [translateByX, translateByY]);
%     end
    
%     translateByX = edgeOneCorners(1, 1) - edgeTwoCorners(1,1);
%     translateByY = edgeOneCorners(1, 2) - edgeTwoCorners(1,2);
%     pieceOneMask = imtranslate(pieceOneMask, [translateByX, translateByY]);
    
    figure(1)
    imshow(pieceOneMask)
    figure(2)
    imshow(pieceTwoMask)
    figure(3)
    imshow(mask)
end

%% HELPER FUNCTIONS

%Given the cropped Mask and size of the bounding box, returns the uncropped
%(original) version
function uncroppedMask = recreateMask(croppedImg, regionP, sizeBB)
    uncroppedMask = zeros(sizeBB(1), sizeBB(2));
    y = floor(regionP.BoundingBox(1));
    x = floor(regionP.BoundingBox(2));
    [xWidth yWidth] = size(croppedImg); 
    
     uncroppedMask(x: x+xWidth-1, y: y+yWidth-1) = croppedImg;
    
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

%Returns the corners associated with the given edge
function [edgeCorners, edgeWrap] = getCorners(puzzlePieceCorners, edgeNum)
    edgeWrap = mod(edgeNum, 4) + 1;
%     if (edgeWrap == 0) 
%         edgeWrap = 1;
%     end
    edgeCorners = [[puzzlePieceCorners(edgeNum,:)]; [puzzlePieceCorners(edgeWrap,:)]];
end
