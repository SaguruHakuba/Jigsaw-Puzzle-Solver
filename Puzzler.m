%This script puts together a puzzle
load('SVM.mat');
%Load the image
img_name = '4_Piece_Puzzles_Scanned\P_1.tif';
img = imread(img_name);
mask = get_mask_edge(img);

%Generate the labeled mask
numbered_mask = bwlabel(mask);

%Create array of puzzle pieces
pieces = [];
num_pieces = max(max(numbered_mask));
for i = 1:num_pieces
    pieces = [pieces;;PuzzlePiece(i,numbered_mask)];
end


%Big for loops to determine probabilities
%Store in large global matrix where each row is [p1 p2 s1 s2 prob]
%probs does not contain duplicate rows where the pieces are switched
probs = [];
for p1 = 1:num_pieces-1
    for s1 = 1:4
        for p2 = p1+1:num_pieces
            for s2 = 1:4
                prob = get_score(net, img,numbered_mask,pieces(p1),pieces(p2),s1,s2);
                probs = [probs; p1 p2 s1 s2 get_score(net, img, numbered_mask, pieces(p1), pieces(p2), s1, s2)];
            end
        end
    end
end

%Determine best way to fit pieces together

%Put pieces together, and show the completed puzzle piece.
