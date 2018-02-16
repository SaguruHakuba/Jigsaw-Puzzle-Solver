function [newpiece1Mask, newpiece2Mask, newpiece3Mask, newpiece4Mask, fusedMask] = rotate_piece_4(puzzlePiece1, puzzlePiece2, puzzlePiece3, puzzlePiece4, mask, edge12on1, edge12on2, edge14on1, edge14on4, edge23on2, edge23on3, img)

%% setting up and initializing data
plot_stuff = 1;

% create a mask for each piece
piece1Mask = mask == puzzlePiece1.Number;
piece2Mask = mask == puzzlePiece2.Number;
piece3Mask = mask == puzzlePiece3.Number;
piece4Mask = mask == puzzlePiece4.Number;

% convert the masks to double
piece1Mask = double(uint8(piece1Mask).*img);
piece2Mask = double(uint8(piece2Mask).*img);
piece3Mask = double(uint8(piece3Mask).*img);
piece4Mask = double(uint8(piece4Mask).*img);

% get the 4x2 integer array of the coordinates of each corner pixel
piece1Corners = puzzlePiece1.Corners;
piece2Corners = puzzlePiece2.Corners;
piece3Corners = puzzlePiece3.Corners;
piece4Corners = puzzlePiece4.Corners;

% Determine the side from the corners
[side121Corners, edge1Wrap] = getCorners(piece1Corners, edge12on1);
[side122Corners, edge2Wrap] = getCorners(piece2Corners, edge12on2);

[side141Corners, edge3Wrap] = getCorners(piece1Corners, edge14on1);
[side144Corners, edge4Wrap] = getCorners(piece4Corners, edge14on4);

[side232Corners, edge5Wrap] = getCorners(piece2Corners, edge23on2);
[side233Corners, edge6Wrap] = getCorners(piece3Corners, edge23on3);

% plot the mask with the corners of the two pieces that are being matched
if plot_stuff
    figure(100);
    imshow(mask);
    hold on
    plot(side121Corners(:,2), side121Corners(:,1), 'r.', side122Corners(:,2), side122Corners(:,1), 'b.', side141Corners(:,2), side141Corners(:,1), 'g.', side144Corners(:,2), side144Corners(:,1), 'y.', side232Corners(:,2), side232Corners(:,1), 'm.', side233Corners(:,2), side233Corners(:,1), 'c.', 'MarkerSize', 30);
    title('Corners');
end

% mark the corners by changing their values to -1
newpiece1Mask = markCorners(piece1Mask, side121Corners);
newpiece2Mask = markCorners(piece2Mask, side122Corners);

% newpiece1Mask = markCorners(piece1Mask, side141Corners);
% newpiece4Mask = markCorners(piece4Mask, side144Corners);
% 
% newpiece2Mask = markCorners(piece2Mask, side232Corners);
% newpiece3Mask = markCorners(piece3Mask, side233Corners);

%% orientation rotation12
% determine the angle that piece 2 must rotate.
% First, find the vector perpendicular to the corners of pieces, within the
% direction of the centroid
cent1 = regionprops(piece1Mask(:,:,1)~=0,'centroid');
cent1 = cent1.Centroid;
vect1 = get_vect(side121Corners,cent1);

cent2 = regionprops(piece2Mask(:,:,1)~=0,'centroid');
cent2 = cent2.Centroid;
vect2 = get_vect(side122Corners,cent2);

angle_between_vects = angle_between(vect1,vect2);

angle1 = atan((side121Corners(1,1)-side121Corners(2,1))/(side121Corners(1,2)-side121Corners(2,2)));
angle2 = atan((side122Corners(1,1)-side122Corners(2,1))/(side122Corners(1,2)-side122Corners(2,2)));
angle_to_rotate = angle2-angle1;

% Compare angle to rotation with angle between vectors, to see if we need
% another pi for rotation angle
% epsilon is our tolerance
epsilon = 0.01;
if ~(abs(angle_between_vects+abs(angle_to_rotate)-pi)<epsilon)
    angle_to_rotate = angle_to_rotate+pi;
end
angle_to_rotate = angle_to_rotate*180/pi;

%% alignment rotation12
piece1region = regionprops(piece1Mask(:,:,1)~=0, 'Orientation', 'BoundingBox');
piece1CroppedMask = imcrop(piece1Mask, piece1region.BoundingBox);

piece2region = regionprops(piece2Mask(:,:,1)~=0, 'Orientation', 'BoundingBox');
piece2CroppedMask = imcrop(piece2Mask, piece2region.BoundingBox);

piece2CroppedMask = imrotate(piece2CroppedMask,angle_to_rotate);
figure(201);
imshow(piece1CroppedMask);
figure(202);
imshow(piece2CroppedMask);

%% orientation rotation14
% determine the angle that piece 2 must rotate.
% First, find the vector perpendicular to the corners of pieces, within the
% direction of the centroid
cent1 = regionprops(piece1Mask(:,:,1)~=0,'centroid');
cent1 = cent1.Centroid;
vect1 = get_vect(side141Corners,cent1);

cent2 = regionprops(piece4Mask(:,:,1)~=0,'centroid');
cent2 = cent2.Centroid;
vect2 = get_vect(side144Corners,cent2);

angle_between_vects = angle_between(vect1,vect2);

angle1 = atan((side141Corners(1,1)-side141Corners(2,1))/(side141Corners(1,2)-side141Corners(2,2)));
angle2 = atan((side144Corners(1,1)-side144Corners(2,1))/(side144Corners(1,2)-side144Corners(2,2)));
angle_to_rotate = angle2-angle1;

% Compare angle to rotation with angle between vectors, to see if we need
% another pi for rotation angle
% epsilon is our tolerance
epsilon = 0.01;
if ~(abs(angle_between_vects+abs(angle_to_rotate)-pi)<epsilon)
    angle_to_rotate = angle_to_rotate+pi;
end
angle_to_rotate = angle_to_rotate*180/pi;

%% alignment rotation14
piece4region = regionprops(piece4Mask(:,:,1)~=0, 'Orientation', 'BoundingBox');
piece4CroppedMask = imcrop(piece4Mask, piece4region.BoundingBox);

piece4CroppedMask = imrotate(piece4CroppedMask,angle_to_rotate);
figure(204);
imshow(piece4CroppedMask);

%% orientation rotation23
% determine the angle that piece 2 must rotate.
% First, find the vector perpendicular to the corners of pieces, within the
% direction of the centroid
cent1 = regionprops(piece2Mask(:,:,1)~=0,'centroid');
cent1 = cent1.Centroid;
vect1 = get_vect(side232Corners,cent1);

cent2 = regionprops(piece3Mask(:,:,1)~=0,'centroid');
cent2 = cent2.Centroid;
vect2 = get_vect(side233Corners,cent2);

angle_between_vects = angle_between(vect1,vect2);

angle1 = atan((side232Corners(1,1)-side232Corners(2,1))/(side232Corners(1,2)-side232Corners(2,2)));
angle2 = atan((side233Corners(1,1)-side233Corners(2,1))/(side233Corners(1,2)-side233Corners(2,2)));
angle_to_rotate = angle2-angle1;

% Compare angle to rotation with angle between vectors, to see if we need
% another pi for rotation angle
% epsilon is our tolerance
epsilon = 0.01;,
if ~(abs(angle_between_vects+abs(angle_to_rotate)-pi)<epsilon)
    angle_to_rotate = angle_to_rotate+pi;
end
angle_to_rotate = angle_to_rotate*180/pi;

%% alignment rotation23
piece3region = regionprops(piece3Mask(:,:,1)~=0, 'Orientation', 'BoundingBox');
piece3CroppedMask = imcrop(piece3Mask, piece3region.BoundingBox);

piece3CroppedMask = imrotate(piece3CroppedMask,angle_to_rotate);
figure(203);
imshow(piece3CroppedMask);

%% recreate mask
%piece1,2
[ht, wd] = size(newpiece1Mask);
newpiece1Mask = recreateMask(piece1CroppedMask, piece1region, [ht, wd]);

[ht, wd] = size(newpiece2Mask);
newpiece2Mask = recreateMask(piece2CroppedMask, piece2region, [ht, wd]);

[temp1, temp2] = find(newpiece1Mask < 0);
rowMax = length(temp1);
[side121Corners(1:rowMax,1),side121Corners(1:rowMax,2)] = find(newpiece1Mask < 0);

[temp1, temp2] = find(newpiece2Mask < 0);
rowMax = length(temp1);
[side122Corners(1:rowMax,1),side122Corners(1:rowMax,2)] = find(newpiece2Mask < 0);

%piece4
newpiece1Mask = markCorners(piece1Mask, side141Corners);
newpiece4Mask = markCorners(piece4Mask, side144Corners);

[temp1, temp2] = find(newpiece1Mask < 0);
rowMax = length(temp1);
[side141Corners(1:rowMax,1),side141Corners(1:rowMax,2)] = find(newpiece1Mask < 0);

[ht, wd] = size(newpiece4Mask);
newpiece4Mask = recreateMask(piece4CroppedMask, piece4region, [ht, wd]);

[temp1, temp2] = find(newpiece4Mask < 0);
rowMax = length(temp1);
[side144Corners(1:rowMax,1),side144Corners(1:rowMax,2)] = find(newpiece4Mask < 0);

%piece3
newpiece2Mask = markCorners(piece2Mask, side232Corners);
newpiece3Mask = markCorners(piece3Mask, side233Corners);

[temp1, temp2] = find(newpiece2Mask < 0);
rowMax = length(temp1);
[side232Corners(1:rowMax,1),side232Corners(1:rowMax,2)] = find(newpiece2Mask < 0);

[ht, wd] = size(newpiece3Mask);
newpiece3Mask = recreateMask(piece3CroppedMask, piece3region, [ht, wd]);

[temp1, temp2] = find(newpiece3Mask < 0);
rowMax = length(temp1);
[side233Corners(1:rowMax,1),side233Corners(1:rowMax,2)] = find(newpiece3Mask < 0);

% figure(300);
% imshow(imfuse(piece1Mask, piece2Mask));
% hold on
% plot(side1Corners(:,2), side1Corners(:,1), 'b.', side2Corners(:,2), side2Corners(:,1), 'b.', 'MarkerSize', 30);
% title('Corners');


%% translation
[newpiece1Mask, newpiece2Mask] = translation(newpiece1Mask, newpiece2Mask, side121Corners, side122Corners);
[newpiece1Mask, newpiece4Mask] = translation(newpiece1Mask, newpiece4Mask, side141Corners, side144Corners);
[newpiece2Mask, newpiece3Mask] = translation(newpiece2Mask, newpiece3Mask, side232Corners, side233Corners);

fusedMask = imfuse(imfuse(newpiece1Mask, newpiece2Mask), imfuse(newpiece3Mask, newpiece4Mask));

% figure(400);
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