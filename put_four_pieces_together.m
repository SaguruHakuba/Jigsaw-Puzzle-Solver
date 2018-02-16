function [fusedMask] = put_four_pieces_together(piece1Puzzle, piece2Puzzle, piece3Puzzle, piece4Puzzle, piece_mask, img)

puzzlePieces = [piece1Puzzle, piece2Puzzle, piece3Puzzle, piece4Puzzle];
piecesNotUsed = puzzlePieces;

for i = 1:length(puzzlePieces(1).Side_Matches)
    if(piece1Puzzle.Side_Matches(i,1) == 0)
        return
    else
        [piece1Mask, piece2Mask, fusedMask] = rotate_piece_2(puzzlePieces(1), puzzlePieces(piece1Puzzle.Side_Matches(i,1)), piece_mask, i, piece1Puzzle.Side_Matches(i,2), img);
        for j = 1:length(piecesNotUsed)
            if(piecesNotUsed(j).Number == puzzlePieces(piece1Puzzle.Side_Matches(i,1)).Number)
                piecesNotUsed(j) = [];
                break;
            else
                printf('we have a problem here.');
            end
        end
        
end