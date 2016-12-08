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
piece_size = 128;
puzzle_size = 512;


%% load the pieces
for i = 1:total_pieces
    pieces(i).id = i;
    iname = sprintf('/home/krish/jigsaw/jigsaw-solver/old3_generated_pieces/%d.jpg',i);
    %pieces(i).data = (double(imread(iname)))*255;
    pieces(i).data = imread(iname); %otherwise it will overflow
end


%% write the similarity matrix. lesser the value, more similar the blocks are
some_min_val = -100;
for i = 1:total_pieces  % no.of rows
    for j = 1:total_pieces % no.of cols
        for k = 1:4 % no.of boundaries
            simil(i,j,k) = some_min_val;
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
% edge-2: right-left
% edge-3: top-bottom
% edge-4: bottom-top

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

simil(1,5,3) = 0.5;
simil(5,9,3) = 0.5;
simil(9,13,3) = 0.5;
simil(2,6,3) = 0.5;
simil(6,10,3) = 0.5;
simil(10,14,3) = 0.5;
simil(3,7,3) = 0.5;
simil(7,11,3) = 0.5;
simil(11,15,3) = 0.5;
simil(4,8,3) = 0.5;
simil(8,12,3) = 0.5;
simil(12,16,3) = 0.5;

simil(2,1,2) = 0.5;
simil(3,2,2) = 0.5;
simil(4,3,2) = 0.5;
simil(6,5,2) = 0.5;
simil(7,6,2) = 0.5;
simil(8,7,2) = 0.5;
simil(10,9,2) = 0.5;
simil(11,10,2) = 0.5;
simil(12,11,2) = 0.5;
simil(14,13,2) = 0.5;
simil(15,14,2) = 0.5;
simil(16,15,2) = 0.5;

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

%% start solving using best buddies method
answermat = zeros(total_pieces,total_pieces,4);
placedarr = zeros(total_pieces,1);
poolarr = zeros(total_pieces,1);
unplacedarr = ones(total_pieces,1);
daddy = zeros(total_pieces,4);

poolcount = 0;

%compute the maxmat
for i = 1:total_pieces
    for k = 1:4
        lolmax = -1000;
        for j = 1:total_pieces
            if(simil(i,j,k) > lolmax)
                lolmax = simil(i,j,k);
                maxindi = j;
            end
        end
        maxmat(i,k,1) = lolmax;
        maxmat(i,k,2) = maxindi;
    end
end

%find the first best buddy
lolmax = -1000;
for i = 1:total_pieces
    four_sum = maxmat(i,1,1) + maxmat(i,2,1) + maxmat(i,3,1) + maxmat(i,4,1);
    if(four_sum > lolmax)
        lolmax = four_sum;
        maxindi = i;
    end
end
baap = maxindi

placedarr(maxindi) = 1;
unplacedarr(maxindi) = 0;

poolarr(maxmat(maxindi,1,2)) = 1;
unplacedarr(maxmat(maxindi,1,2)) = 0;
daddy(maxmat(maxindi,1,2),1) = maxindi; 

poolarr(maxmat(maxindi,2,2)) = 1;
unplacedarr(maxmat(maxindi,2,2)) = 0;
daddy(maxmat(maxindi,2,2),2) = maxindi;

poolarr(maxmat(maxindi,3,2)) = 1;
unplacedarr(maxmat(maxindi,3,2)) = 0;
daddy(maxmat(maxindi,3,2),3) = maxindi;

poolarr(maxmat(maxindi,4,2)) = 1;
daddy(maxmat(maxindi,4,2),4) = maxindi;
unplacedarr(maxmat(maxindi,4,2)) = 0;

poolcount = 4;

while(poolcount > 0)
    
    maxindi
    placedarr'
    poolarr'
    unplacedarr'
    
    lolmax = -1000;
    for i = 1:total_pieces
        if(poolarr(i) == 1)
            four_sum = maxmat(i,1,1) + maxmat(i,2,1) + maxmat(i,3,1) + maxmat(i,4,1);
            if(four_sum > lolmax)
                lolmax = four_sum;
                maxindi = i;
            end
        end
    end
    
 
    poolarr(maxindi) = 0;
    poolcount = poolcount - 1;
    placedarr(maxindi) = 1;
    for j = 1:4
        if(daddy(maxindi,j) ~= 0)
            answermat(daddy(maxindi,j),maxindi,j) = 1;
        end
    end
    for j = 1:4
        currindi = maxmat(maxindi,j,2);
        if(unplacedarr(currindi) == 1)
            unplacedarr(currindi) = 0;
            poolarr(currindi) = 1;
            poolcount = poolcount + 1;
            daddy(currindi,j) = maxindi;
        end
    end
end


newimg = zeros(2*puzzle_size,2*puzzle_size,3);
top_x = puzzle_size/2; %cols
top_y = puzzle_size/2; %rows
for i = 1:piece_size
    for j = 1:piece_size
        newimg(i+top_x,j+top_y,:) = pieces(baap).data(i,j,:);
    end
end

top = zeros(16,2);
top(baap,1) = top_x;
top(baap,2) = top_y;

for i = 1:total_pieces
    convisited(i) = 0;
    conpool(i) = 0;
    conunvisit(i) = 1;
end

convisited(baap) = 1;
conunvisit(baap) = 0;

visitcount = 1;
currindi = baap;
for dasd = 1:16
for i = 1:total_pieces
    if(convisited(i) == 1)
        for k = 1:total_pieces
            for j = 1:4
                
                if((daddy(k,j) == i) & convisited(k) == 0)
                   
                    mydaddy = i;
                    convisited(k) = 1;
                    visitcount = visitcount + 1;
                    if(j == 1)
                        top(k,1) = top(mydaddy,1) + piece_size;
                        top(k,2) = top(mydaddy,2);
                    elseif(j == 2)
                        top(k,1) = top(mydaddy,1) - piece_size;
                        top(k,2) = top(mydaddy,2);
                    elseif(j == 3)
                        top(k,1) = top(mydaddy,1);
                        top(k,2) = top(mydaddy,2) + piece_size;
                    else
                        top(k,1) = top(mydaddy,1);
                        top(k,2) = top(mydaddy,2) - piece_size;
                    end
                    i,k
                    top_x = top(k,2)
                    top_y = top(k,1)
                    for lool1 = 1:piece_size
                        for lool2 = 1:piece_size
                            newimg(top_x+lool1,top_y+lool2,:) = pieces(k).data(lool1,lool2,:);
                        end
                    end
                end
            end
            
%         else
%             lolcount = lolcount + 1;
%         end
%     end
%     if(lolcount == 4)
%         for hmm = 1:total_pieces
%             if(convisited(hmm) == 0)
%                 currindi = hmm;
%                 break;
%             end
%         end
%     else
%         mydaddy
            
        end
    end
end
end
imshow(uint8(newimg))