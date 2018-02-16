%This is a puzzle piece class
classdef PuzzlePiece
    properties
        Number  %This is the integer corresponding to the number representing this piece 
                % in the connected components array
        Corners %Should be a 4x2 integer array of the coordinates of each corner pixel
                % clockwise
        Sides   %Should be a 4x1 integer array specifying the type of each side:
                % Border = 0, convex = 1, concave = 2
        Perimeter
        Centroid
        Side_Matches %Should be 4 by 3 integer array, where row 1 is the 
                     %piece and the side that match side 1 of this piece 
                     %and the probability that they fit
    end
    methods
        function obj = PuzzlePiece(val,pieces_mask)
            if rem(val,1)==0
                obj.Number = val;
            else
                error('PuzzlePiece.Number must be an integer');
            end
            %Initialize Side_Matches with zeros
            obj.Side_Matches = [0 0 -1000; 0 0 -1000; 0 0 -1000; 0 0 -1000];
            
            %Create mask of this specific piece
            mask = pieces_mask == obj.Number;
            
            %Calculate some values regarding the size of the piece.
            square_size = sum(sum(mask)); %area of square
            square_sl = sqrt(square_size); %sidelength of square approximation
            
            %Generate the perimeter
            [val,idx]  = max(mask);
            [val2,idx2] = max(val);
            index = [idx(idx2), idx2];
            perim = bwtraceboundary(mask,index,'N',8,inf,'clockwise');
            
            %Find the centroid of the region
            c = regionprops(mask,'Centroid');
            c = fliplr(double(c.Centroid));
            obj.Centroid = c;
            
            %Find the distance from the perimeter to the centroid
            dist = sum((perim-c).^2,2);
            
            %Rotate the perimeter and distance arrays so the minimum distance is the at the start and
            %end of the array
            [y,idx] = min(dist);           
            perim = circshift(perim,-idx);
            dist = circshift(dist,-idx);
            
            %These are a few factors which should be invariant to size of
            %the puzzle piece
            sm = 10; %Smoothing factor, determines how much the distances should be smoothed. 10 is good
            prom_rej_fact = 50; %prominence rejection factor, higher means prominence threshold is lower. 20 is good, means that peaks w/ prominences<1/20 of the max prominence are rejected
            
            %Smooth the distance
            sm_dist = cconv(dist,ones(1,sm)/sm,size(dist,1));
            
            %Shift to compensate smoothing
            sm_dist = circshift(sm_dist,-floor(sm/2));
            
            %Find peaks from the smoothed distance
            [pks,locs,w,p] = findpeaks(sm_dist);
            
            %Reject peaks with low prominence
            strong_idx = find(p>(max(p)/prom_rej_fact));
            pks = pks(strong_idx);
%             while size(pks)<4
%                 prom_rej_fact = prom_rej_fact*1.1;
%                 strong_idx = find(p>(max(p)/prom_rej_fact));
%                 pks = pks(strong_idx);
%             end
            p = p(strong_idx);
            locs = locs(strong_idx);
            w = w(strong_idx);
            
            %Find absolute peaks on the unsmoothed distance graph.  This
            %also rejects jagged peaks
            peak_search_size = floor(square_sl/10);
            for j=1:size(locs)
                [abs_max,idx_abs_max] = max(dist(locs(j)-peak_search_size:locs(j)+peak_search_size));
                locs(j) = idx_abs_max+locs(j)-peak_search_size;
                pks(j) = abs_max;
            end
            locs = unique(locs,'stable'); %Gets rid of duplicates
            pks = unique(pks,'stable'); %Gets rid of duplicates
            
            %Create a corner prominence filter by making a corner and
            %finding the distance from the corner to the center of a square
            %the same size as the puzzle piece.
            corner_size = floor(.075*square_sl); %size of corner prominence filter
            corner_filter = -corner_size:corner_size;
            corner_filter = [corner_filter; abs(corner_filter)];
            pt = [0; square_sl/sqrt(2)]; %Center point of imaginary square
            corner_filter = sqrt(sum((corner_filter-pt).^2));
            corner_filter = corner_filter-mean(corner_filter);
            
            %Convolve the smoothed distance with corner filter to generate
            %the prominence of corner
            corner = cconv(sm_dist,corner_filter,size(dist,1));
            corner = circshift(corner,-corner_size); %Shift to combat filter
            
%             corner = normxcorr2(corner_filter,sm_dist');
%             corner = circshift(corner,-corner_size); %Shift to combat filter
%             corner = corner(1:end-corner_size*2);
%             
            
            %Find the corner prominence of the previously found peaks
            corner_pks = corner(locs);
            corner_pks = corner_pks./(dist(locs));
            corner_pks_sorted = sort(corner_pks);
            corner_pks_sorted = corner_pks_sorted(end-4+1:end);
            
            %Get the 4 best corner candidates
            corner_locs = locs(find(corner_pks==corner_pks_sorted(1)|corner_pks==corner_pks_sorted(2)|...
                corner_pks==corner_pks_sorted(3)|corner_pks==corner_pks_sorted(4)));
            [corner_locs tmp_idx] = sort(corner_locs);
            corner_pks = pks(find(corner_pks==corner_pks_sorted(1)|corner_pks==corner_pks_sorted(2)|...
                corner_pks==corner_pks_sorted(3)|corner_pks==corner_pks_sorted(4)));
            corner_pks = corner_pks(tmp_idx);
            %Finally assign the corners and the perimeter
            obj.Corners = perim(corner_locs,:);
            obj.Perimeter = perim; 
            
            %Find if each side is concave, convex, or edge.
            edge_ratio = 1.2; %This tells the max ratio between perimeter:distance to still be considered an edgs
            obj.Sides = [];
            for i = 1:4
                corner_loc_1 = corner_locs(i);
                corner_loc_2 = corner_locs(mod(i,4)+1);
                if sum(locs>corner_loc_1 & locs<corner_loc_2)
                    obj.Sides = [obj.Sides; 1];
                else
                    if(i~=4)
                        if (corner_loc_2-corner_loc_1>edge_ratio*sqrt(sum((perim(corner_loc_2,:)-perim(corner_loc_1,:)).^2)))
                            obj.Sides = [obj.Sides; 2];
                        else
                            obj.Sides = [obj.Sides; 0];
                        end
                    else
                        if (size(perim(:,1))-corner_loc_2+corner_loc_1>edge_ratio*sqrt(sum((perim(corner_loc_2,:)-perim(corner_loc_1,:)).^2)))
                            obj.Sides = [obj.Sides; 2];
                        else
                            obj.Sides = [obj.Sides; 0];
                        end
                    end
                end
            end

            show = 0; % Turn this to 1 if you want to see cool stuff
            if show
                x = [1:size(dist,1)];
                figure(1);
                subplot(2,1,1);
                plot(x,sm_dist,x,dist,corner_locs,corner_pks,'or');
                subplot(2,1,2);
                plot(x,corner,locs,corner(locs),'og');
                figure(2);
                imshow(mask);
                hold on
                for i = 1:3
                    switch obj.Sides(i)
                        case 0
                            plot(obj.Perimeter(corner_locs(i):corner_locs(i+1),2),obj.Perimeter(corner_locs(i):corner_locs(i+1),1),'r');
                        case 1
                            plot(obj.Perimeter(corner_locs(i):corner_locs(i+1),2),obj.Perimeter(corner_locs(i):corner_locs(i+1),1),'g')
                        case 2
                            plot(obj.Perimeter(corner_locs(i):corner_locs(i+1),2),obj.Perimeter(corner_locs(i):corner_locs(i+1),1),'b')
                    end
                end
                switch obj.Sides(4)
                    case 0
                        plot([obj.Perimeter(corner_locs(4):end,2);obj.Perimeter(1:corner_locs(1),2)],[obj.Perimeter(corner_locs(4):end,1);obj.Perimeter(1:corner_locs(1),1)],'r');
                    case 1
                        plot([obj.Perimeter(corner_locs(4):end,2);obj.Perimeter(1:corner_locs(1),2)],[obj.Perimeter(corner_locs(4):end,1);obj.Perimeter(1:corner_locs(1),1)],'g')
                    case 2
                        plot([obj.Perimeter(corner_locs(4):end,2);obj.Perimeter(1:corner_locs(1),2)],[obj.Perimeter(corner_locs(4):end,1);obj.Perimeter(1:corner_locs(1),1)],'b')
                end
                plot(obj.Corners(:,2),obj.Corners(:,1),'ro');
                title('Piece with corners circled in red, and sides colored: red = edge, green = convex, blue = concave');
                hold off
            end            
        end
    end
end