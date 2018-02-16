function [puzzlePieces] = get_best_matchings(possibleMatchings, puzzlePieces)

    % possibleMatchings contains all possible matchings for all pieces (in
    % pairs) with each row containing the pieces (and respective sides)
    % being matched and the probability that they fit together. For example
    % [p1, p2, s1, s2, prob] means that the likelihood that side s1 on
    % piece p1 connects with side s2 from piece p2 = prob.
    
    % puzzlePieces contains all of the puzzle pieces (as implied)
    
    %% for each puzzle piece
    for i=1:size(puzzlePieces)
       % get all of the possible matchings for the puzzle piece 
       possibilities = find(possibleMatchings(:,1) == i); 
       currentMatchings = possibleMatchings(possibilities,:);
       
       % remove matchings with probability <= 0
       removeBelowThreshold = find(currentMatchings(:,5) > -99);
       currentMatchings = possibleMatchings(removeBelowThreshold,:);
       
       % loop through all of the possible matchings (with prob > -1000) for the
       % current puzzle piece
       piece = puzzlePieces(i);
       bestProbs = [-1000, -1000, -1000, -1000];
       for j=1:size(currentMatchings)
           
           % check if the probability of the current matching is better
           % than the previously found "bestProb"
           currentSide = currentMatchings(j,3);
           if (bestProbs(currentSide) < currentMatchings(j, 5))
              % get best matching for the other piece
              bestPiece = puzzlePieces(currentMatchings(j, 2));
              bestSide = currentMatchings(j, 4);
              otherBestProb = bestPiece.Side_Matches(bestSide, 3);
              if (otherBestProb < currentMatchings(j, 5))
                bestProbs(currentSide) = currentMatchings(j, 5);
                % update the Side_Matches property for both pieces
                piece.Side_Matches(currentSide,:) = [bestPiece.Number, bestSide, bestProbs(currentSide)];
                bestPiece.Side_Matches(bestSide,:) = [piece.Number, currentSide, bestProbs(currentSide)];
              end 
           end
       end 
       puzzlePieces(piece.Number) = piece;
    end

    %% Double check Side_Matches assignments
    for i=1:size(puzzlePieces)
        piece = puzzlePieces(i);
        % check first index
        first = piece.Side_Matches(1,:);
        if (first(1) > 0 && i ~= first(1))
            puzzlePieces(first(1)).Side_Matches(first(2),:) = [i, 1, first(3)]; 
        end
        
        % check second index
        second = piece.Side_Matches(2,:);
        if (second(1) > 0 && i ~= second(1))
            puzzlePieces(second(1)).Side_Matches(second(2),:) = [i, 2, second(3)];
        end 
        
        % check third index
        third = piece.Side_Matches(3,:);
        if (third(1) > 0 && i ~= third(1))
            puzzlePieces(third(1)).Side_Matches(third(2),:) = [i, 3, third(3)];
        end 
        
        % check fourth index
        fourth = piece.Side_Matches(4,:);
        if (fourth(1) > 0 && i ~= fourth(1))
            puzzlePieces(fourth(1)).Side_Matches(fourth(2),:) = [i, 4, fourth(3)];
        end 
    end 
end