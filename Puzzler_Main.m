%Put in whatever images you want to use here
close all;
folder = 'Puzzle_1_Scans\';
files = dir(fullfile(folder,'*.tif'));
show_corners_and_edges=1;
set(groot,'defaultLineLineWidth',2);

for j = 1:size(files)


    img_name = [folder files(j).name];
    img = imread(img_name);
    if ~contains(img_name,'mask')        
        %Check to see if the mask has already been generated
        if ~exist([img_name(1:end-4),'_mask.tiff'])    
            %Generate a mask of the puzzle pieces
            mask = get_mask_edge(img);
            imwrite(mask,[img_name(1:end-4),'_mask.tiff']);
        else
            mask = imread([img_name(1:end-4),'_mask.tiff']);
        end
        %Find all the connected components in the mask to separate each piece
        pieces_mask = bwlabel(mask);

        %Create an array of piece objects
        pieces = [];
        figure(3);
        imshow(mask);
        
        for i = 1:max(max(pieces_mask))            
            pieces = [pieces;PuzzlePiece(i,pieces_mask)]; 
            
            if show_corners_and_edges==1
                figure(3);
                hold on;
                for j = 1:4 %Step through each side
                    perim = pieces(i).Perimeter;
                    c1_loc = perim==pieces(i).Corners(j,:);
                    c2_loc = perim==pieces(i).Corners(mod(j,4)+1,:);
                    c1_loc = find(c1_loc(:,1)&c1_loc(:,2)==1);
                    c2_loc = find(c2_loc(:,1)&c2_loc(:,2)==1);
                    color = 'y';
                    switch pieces(i).Sides(j)
                        case 0
                            color = 'r';
                        case 1
                            color = 'g';
                        case 2
                            color = 'b';
                    end
                    if j==4
                        plot([perim(c1_loc:end,2);perim(1:c2_loc,2)],[perim(c1_loc:end,1);perim(1:c2_loc,1)],color);
                    else
                        plot(perim(c1_loc:c2_loc,2),perim(c1_loc:c2_loc,1),color);
                    end
                    midpoint = (perim(c1_loc,:)+perim(c2_loc,:))./2;
                    tx = text(midpoint(2),midpoint(1),int2str(j));
                    tx.Color = [1,0,0];tx.FontWeight='bold';
                end
                plot(pieces(i).Corners(:,2),pieces(i).Corners(:,1),'yo');
                title(['Piece with corners circled in yellow, and sides colored: red = edge, green = convex, blue = concave, ' files(j).name]);
                tx = text(pieces(i).Centroid(2),pieces(i).Centroid(1),int2str(i));
                tx.Color = [1,0,1];tx.FontWeight='bold';
                hold off;                
            end
        end
    end
    
    

end
