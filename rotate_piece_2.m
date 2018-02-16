function [piece1Mask, piece2Mask, fusedMask] = rotate_piece_2(puzzlePiece1, puzzlePiece2, mask, edge1, edge2, img)
%This function takes in 2 pieces, and rotates the 2nd piece so that its
%edge is aligned with the specified edge of the 1st piece.  It returns the
%colored mask of each piece, as well as a fused mask.

%% setting up and initializing data
plot_stuff = 0;

% create a mask for each piece
piece1Mask = mask == puzzlePiece1.Number;
piece2Mask = mask == puzzlePiece2.Number;

% convert the masks to double
piece1Mask = double(uint8(piece1Mask).*img);
piece2Mask = double(uint8(piece2Mask).*img);

% get the 4x2 integer array of the coordinates of each corner pixel
piece1Corners = puzzlePiece1.Corners;
piece2Corners = puzzlePiece2.Corners;

% Determine the side from the corners
[side1Corners, edge1Wrap] = getCorners(piece1Corners, edge1);
[side2Corners, edge2Wrap] = getCorners(piece2Corners, edge2);

% plot the mask with the corners of the two pieces that are being matched
if plot_stuff
    figure(1);
    imshow(mask);
    hold on
    plot(side1Corners(:,2), side1Corners(:,1), 'r.', side2Corners(:,2), side2Corners(:,1), 'b.', 'MarkerSize', 50);
    title('Corners');
end

% mark the corners by changing their values to -1
piece1Mask = markCorners(piece1Mask, side1Corners);
piece2Mask = markCorners(piece2Mask, side2Corners);

%% orientation rotation
% determine the angle that piece 2 must rotate.
% First, find the vector perpendicular to the corners of pieces, within the
% direction of the centroid
cent1 = regionprops(piece1Mask(:,:,1)~=0,'centroid');
cent1 = cent1.Centroid;
vect1 = get_vect(side1Corners,cent1);

cent2 = regionprops(piece2Mask(:,:,1)~=0,'centroid');
cent2 = cent2.Centroid;
vect2 = get_vect(side2Corners,cent2);

angle_between_vects = angle_between(vect1,vect2);

angle1 = atan((side1Corners(1,1)-side1Corners(2,1))/(side1Corners(1,2)-side1Corners(2,2)));
angle2 = atan((side2Corners(1,1)-side2Corners(2,1))/(side2Corners(1,2)-side2Corners(2,2)));
angle_to_rotate = angle2-angle1;

% Compare angle to rotation with angle between vectors, to see if we need
% another pi for rotation angle
% epsilon is our tolerance
epsilon = 0.01;
if ~(abs(angle_between_vects+abs(angle_to_rotate)-pi)<epsilon)
    angle_to_rotate = angle_to_rotate+pi;
end
angle_to_rotate = angle_to_rotate*180/pi;

%% alignment rotation
piece1region = regionprops(piece1Mask(:,:,1)~=0, 'Orientation', 'BoundingBox');
piece1CroppedMask = imcrop(piece1Mask, piece1region.BoundingBox);

piece2region = regionprops(piece2Mask(:,:,1)~=0, 'Orientation', 'BoundingBox');
piece2CroppedMask = imcrop(piece2Mask, piece2region.BoundingBox);

piece2CroppedMask = imrotate(piece2CroppedMask,angle_to_rotate);
% figure(200);
% imshow(piece2CroppedMask);

%% recreate mask

% % remark the corners by changing their values to -1
% piece1CroppedMask = markCorners(piece1CroppedMask, side1Corners);
% piece2CroppedMask = markCorners(piece2CroppedMask, side2Corners);

[ht, wd] = size(piece1Mask);
piece1Mask = recreateMask(piece1CroppedMask, piece1region, [ht, wd]);

[ht, wd] = size(piece2Mask);
piece2Mask = recreateMask(piece2CroppedMask, piece2region, [ht, wd]);

[temp1, temp2] = find(piece1Mask < 0);
rowMax = length(temp1);
[side1Corners(1:rowMax,1),side1Corners(1:rowMax,2)] = find(piece1Mask < 0);

[temp1, temp2] = find(piece2Mask < 0);
rowMax = length(temp1);
[side2Corners(1:rowMax,1),side2Corners(1:rowMax,2)] = find(piece2Mask < 0);


% figure(2)
% imshow(imfuse(piece1Mask, piece2Mask));
% hold on
% plot(side1Corners(:,2), side1Corners(:,1), 'b.', side2Corners(:,2), side2Corners(:,1), 'b.', 'MarkerSize', 30);
% title('Corners');


%% translation
[piece1Mask, piece2Mask] = translation(piece1Mask, piece2Mask, side1Corners, side2Corners);

fusedMask = imfuse(piece1Mask,piece2Mask);

% figure(3)
% imshow(fusedMask);
% title('Fused Mask');

end


%% helper functions 

% get the edge numbers of the corners
function [edgeCorners, edgeWrap] = getCorners(puzzlePieceCorners, edgeNum)

edgeWrap = mod(edgeNum, 4) + 1;
edgeCorners = [[puzzlePieceCorners(edgeNum,:)]; [puzzlePieceCorners(edgeWrap,:)]];

end

% Mark the corners of a piece
function pieceMask = markCorners(pieceMask, corners)
% pieceMask(corners(1,1),corners(1,2),:) = -pieceMask(corners(1,1),corners(1,2),:);
% pieceMask(corners(2,1),corners(2,2),:) = -pieceMask(corners(2,1),corners(2,2),:);  

rowInd = corners(1,1);
colInd = corners(1,2);
pieceMask(rowInd:rowInd+1, colInd:colInd+1, :) = -pieceMask(rowInd:rowInd+1, colInd:colInd+1, :);

rowInd = corners(2,1);
colInd = corners(2,2);
pieceMask(rowInd:rowInd+1, colInd:colInd+1, :) = -pieceMask(rowInd:rowInd+1, colInd:colInd+1, :);
end

% Find the normal vector for that side, passing in both corners
function [vect] = get_vect(corners,cent)
    cent = fliplr(cent);
    corner_vect = corners(1,:)-corners(2,:);
    vect = fliplr(corner_vect);
    vect(1) = -vect(1);
    ac = cent-corners(1,:);
    bc = cent-corners(2,:);
    vect_est = ac+bc;
    if angle_between(vect,vect_est) >= pi/2
        vect = -vect;
    end
end

% Find the angle between two normal vectors
function [angle] = angle_between(a,b);
    angle = acos(sum(a.*b)/(sqrt(sum(a.^2))*sqrt(sum(b.^2))));
end

% add the cropped mask back into the full sized mask
function uncroppedMask = recreateMask(croppedImg, regionP, sizeOriginal)
uncroppedMask = zeros(sizeOriginal(1), sizeOriginal(2), 3);
y = floor(regionP(1).BoundingBox(2));
x = floor(regionP(1).BoundingBox(1));
[yWidth,xWidth,zWidth] = size(croppedImg);

uncroppedMask(y: y+yWidth-1, x: x+xWidth-1, 1:3) = croppedImg;

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
% yTranslation
if side1Corners(1,1) < side2Corners(1,1)
    translateByY = min(side2Corners(ind2, 1)) - min(side1Corners(ind1,1));
    piece1Mask = imtranslate(piece1Mask, [translateByX, translateByY]);
    
elseif side1Corners(1,1) > side2Corners(1,1)
    translateByY = side1Corners(ind1,1) - side2Corners(ind2,1);
    piece2Mask = imtranslate(piece2Mask, [translateByX, translateByY]);
end

end