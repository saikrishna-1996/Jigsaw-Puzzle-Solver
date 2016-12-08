function [secondmat] = findsecond()

global total_pieces
global cost

secondmat = zeros(total_pieces,4);
for i = 1:total_pieces %iterate through every row
    for j = 1:4  %iterate thorogh every possible rotation
        first = 10000;
        second = 10000;
        for k = 1:total_pieces
            if(cost(i,k,j) < first)
                second = first;
                first = cost(i,k,j);
            elseif((cost(i,k,j) < second) & (cost(i,k,j) >= first))
                second = cost(i,k,j);
            end
            secondmat(i,j) = second;
        end
    end
end