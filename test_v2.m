%% demo
% for image construction from similarity matrix. We will assume that we
% already have a similarity matrix. From that we will build 2x2 blocks and
% then using loops of loops approach, we will try to reconstruct the
% origianl image, which has 4x4 blocks in it.

% We will solve for type-1 puzzle (unknown location and known orientation)
% can be extended to type-2 puzzles also

clear all;
clc;

total_pieces = 16;

%% write the similarity matrix. lesser the value, more similar the blocks are
some_max_val = 10000;
for i = 1:total_pieces  % no.of rows
    for j = 1:total_pieces % no.of cols
        for k = 1:4 % no.of boundaries
            simil(i,j,k) = some_max_val;
            flagmat(i,j,k) = 0;
            flagmat2(i,j,k) = 0;
            flagmat3(i,j,k) = 0;
            flagmat4(i,j,k) = 0;
        end
    end
end

for i = 1:total_pieces
    for k = 1:4
        piecemat(i,k) = 0;
        piecemat2(i,k) = 0;
        piecemat3(i,k) = 0;
        piecemat4(i,k) = 0;
    end
end

% edge-1: left-right
% edge-2: top-bottom
% edge-3: right-left
% edge-4: bottom-left

simil(1,2,1) = 0.5;
simil(2,3,1) = 0.5;
simil(3,4,1) = 0.5;
simil(5,6,1) = 0.5;
simil(6,7,1) = 0.5;
simil(7,8,1) = 0.5;
simil(9,10,1) = 0.5;
simil(10,11,1) = 0.5;
simil(11,12,1) = 0.5;
simil(13,14,1) = 0.5;
simil(14,15,1) = 0.5;
simil(15,16,1) = 0.5;

simil(1,5,2) = 0.5;
simil(5,9,2) = 0.5;
simil(9,13,2) = 0.5;
simil(2,6,2) = 0.5;
simil(6,10,2) = 0.5;
simil(10,14,2) = 0.5;
simil(3,7,2) = 0.5;
simil(7,11,2) = 0.5;
simil(11,15,2) = 0.5;
simil(4,8,2) = 0.5;
simil(8,12,2) = 0.5;
simil(12,16,2) = 0.5;

simil(2,1,3) = 0.5;
simil(3,2,3) = 0.5;
simil(4,3,3) = 0.5;
simil(6,5,3) = 0.5;
simil(7,6,3) = 0.5;
simil(8,7,3) = 0.5;
simil(10,9,3) = 0.5;
simil(11,10,3) = 0.5;
simil(12,11,3) = 0.5;
simil(14,13,3) = 0.5;
simil(15,14,3) = 0.5;
simil(16,15,3) = 0.5;

simil(5,1,4) = 0.5;
simil(9,5,4) = 0.5;
simil(13,9,4) = 0.5;
simil(6,2,4) = 0.5;
simil(10,6,4) = 0.5;
simil(14,10,4) = 0.5;
simil(7,3,4) = 0.5;
simil(11,7,4) = 0.5;
simil(15,11,4) = 0.5;
simil(8,4,4) = 0.5;
simil(12,8,4) = 0.5;
simil(16,12,4) = 0.5;

% establish the piece-wise compatibility measure in binary.
for i = 1:total_pieces
    for j = 1:total_pieces
        for k = 1:4
            if(simil(i,j,k) < 1.07) % ratio, as chosen by Son et al
                flagmat(i,j,k) = 1;
            end
        end
    end
end

%% constrcut level-2
count = 0;

for i = total_pieces
    for j = total_pieces
        countmat(i,j) = 0;
    end
end

for i = 1:total_pieces
    for j = 1:total_pieces
        if(flagmat(i,j,1) >= 1)
            for k = 1:total_pieces
                if(flagmat(j,k,2) >= 1)
                    for l = 1:total_pieces
                        if((flagmat(k,l,3) >= 1) & (flagmat(l,i,4) >= 1))
                            count = count + 1;
                            
                            seq(count).arr(1) = i;
                            seq(count).arr(2) = j;
                            seq(count).arr(3) = k;
                            seq(count).arr(4) = l;
                            
                            countmat(i,j) = countmat(i,j) + 1;
                            countmat(j,i) = countmat(j,i) + 1;
                            countmat(j,k) = countmat(j,k) + 1;
                            countmat(k,j) = countmat(k,j) + 1;
                            countmat(k,l) = countmat(k,l) + 1;
                            countmat(l,k) = countmat(l,k) + 1;
                            countmat(l,i) = countmat(l,i) + 1;
                            countmat(i,l) = countmat(i,l) + 1;
                            
                            lev2mat(i,j).arr(countmat(i,j)) = count;
                            lev2mat(j,k).arr(countmat(j,k)) = count;
                            lev2mat(k,l).arr(countmat(k,l)) = count;
                            lev2mat(l,i).arr(countmat(l,i)) = count;
                        end
                    end
                end
            end
        end
    end
end



%% construct level-3
for i = total_pieces
    for j = 1:total_pieces
        if(countmat(i,j) == 2)
            %combine the two
        end
    end
end

% nextcount = 0;
% for i = 1:total_pieces
%     seq =   [0,0,0,0];
%     mincost = some_max_val;
%     countj = 1;
%     for j = 1:total_pieces
%         if(flagmat(i,j,1) >= 1)
%             seq(2) = j;
%             countj = countj + 1;
%             countk = 1;
%             countl = 1;
%             for k = 1:total_pieces
%                 if(flagmat(i,k,2) >= 1)
%                     k
%                     rememk(countk) = k;
%                     countk = countk + 1;
%                     if(countk == 11)
%                         break;
%                     end
%                 end
%             end
%             for l = 1:total_pieces
%                 if(flagmat(j,l,2) >= 1)
%                     rememl(countl) = l;
%                     countl = countl + 1;
%                     if(countl == 11)
%                         break;
%                     end
%                 end
%             end
%             countk, countl;
%             mincost = 100000;
%          
%             for k = 1:countk-1
%                 for l = 1:countl-1
%                     
%                     cost = simil(i,j,1) + simil(rememk(k+1),rememl(l+1),1) + simil(i,rememk(k+1),2) + simil(j,rememl(l+1),2);
%                     if(cost < mincost)
%                         i,j,k,l
%                         mincost = cost;
%                         seq(1) = i;
%                         seq(2) = j;
%                         seq(3) = k;
%                         seq(4) = l;
%                     end
%                 end
%             end
%         end
%     end
%     %if(flagmat(seq(1),seq(2),1) == 1 && (flagmat(seq(3),seq(4),1) == 1) && (flagmat(seq(2),seq(4),2) == 1) && (flagmat(seq(1),seq(3),2) == 1))
%      if((countj >= 1) && (countk >= 1) && (countl >= 1))
%          
%         flagmat(seq(1),seq(2),1) = flagmat(seq(1),seq(2),1)+1;
%         flagmat(seq(2),seq(1),3) = flagmat(seq(2),seq(1),3)+1;
%         flagmat(seq(3),seq(4),1) = flagmat(seq(3),seq(4),1)+1;
%         flagmat(seq(4),seq(3),3) = flagmat(seq(4),seq(3),3)+1;
%         flagmat(seq(2),seq(4),2) = flagmat(seq(2),seq(4),2)+1;
%         flagmat(seq(4),seq(2),4) = flagmat(seq(4),seq(2),4)+1;
%         flagmat(seq(1),seq(3),2) = flagmat(seq(1),seq(3),2)+1;
%         flagmat(seq(3),seq(1),4) = flagmat(seq(3),seq(1),4)+1;
%         
%         nextcount = nextcount + 1;
%         lev2(nextcount).arr(1,1) = seq(2);
%         lev2(nextcount).arr(1,2) = seq(4);
%         lev2(nextcount).arr(2,1) = seq(1);
%         lev2(nextcount).arr(2,2) = seq(3);
%     end
% end