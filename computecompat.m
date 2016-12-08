function [compat] = computecompat(secondmat)

global total_pieces
global cost

compat = zeros(total_pieces,total_pieces, 4);
for i = 1:total_pieces %iterate through every row
    for j = 1:total_pieces
        for k = 1:4
            compat(i,j,k) = 1 - cost(i,j,k)/secondmat(i,k);
        end
    end
end