% read the images

clear all;
clc;

% to create a structured cell: 
% http://in.mathworks.com/help/matlab/matlab_prog/create-a-structure-array.html

global total_pieces;
global puzzle_size;
global block_size;
global pieces;
global cost;
global compat;
global secondmat;
global answermat

total_pieces = 16;
puzzle_size = 16;
block_size = 128;

%% load all the pieces
for i = 1:total_pieces
    pieces(i).id = i;
    iname = sprintf('/home/krish/jigsaw/jigsaw-solver/old3_generated_pieces/%d.jpg',i);
    %pieces(i).data = (double(imread(iname)))*255;
    pieces(i).data = imread(iname); %otherwise it will overflow
    cform = makecform('srgb2lab');
    pieces(i).data = applycform(pieces(i).data, cform);
    pieces(i).data = im2double(pieces(i).data);
end

%% The cost matrix will be of size 16x16x4
% [i][j][1]: i is left; j is right
% [i][j][2]: i is right; j is left
% [i][j][3]: i is top; j is bottom
% [i][j][4]: i is bottom; j is top
cost = zeros(puzzle_size,puzzle_size,4);

for i = 1:total_pieces                    
    for j = 1:total_pieces
        if(i ~= j)
            cost(i,j,1) = cost_leftright(i,j);
            cost(i,j,2) = cost_rightleft(i,j);
            cost(i,j,3) = cost_topbottom(i,j);
            cost(i,j,4) = cost_bottomtop(i,j);
        else
            cost(i,j,1) = 10000;
            cost(i,j,2) = 10000;
            cost(i,j,3) = 10000;
            cost(i,j,4) = 10000;
        end
    end
end

secondmat = findsecond();
compat = computecompat(secondmat);

%%compute C_dash: newcompat
newcompat = zeros(total_pieces,total_pieces,2);

for i = 1:total_pieces
    for j = 1:total_pieces
        if(i ~= j)
            newcompat(i,j,1) = (compat(i,j,1) + compat(j,i,2))/2;
            newcompat(j,i,2) = (compat(i,j,1) + compat(j,i,2))/2;
            newcompat(i,j,3) = (compat(i,j,3) + compat(j,i,4))/2;
            newcompat(j,i,4) = (compat(i,j,3) + compat(j,i,4))/2;
        else
            newcompat(i,j,1) = -10000;
            newcompat(i,j,2) = -10000;
            newcompat(i,j,3) = -10000;
            newcompat(i,j,4) = -10000;
        end
    end
end

%% reconstruct the image

maxmat = zeros(total_pieces,4,2); %one is for value and one is for ID
placedmat = zeros(total_pieces,4);
for i = 1:total_pieces
    poolarr(i) = 0;
    placedarr(i) = 0;
    unplacedarr(i) = 1;
end
daddy = zeros(total_pieces,4);
answermat = zeros(total_pieces,total_pieces,4);
poolcount = 0;

% first, we will compute the maxmat, which is the  maximum in every row.
% This is to say that, we will compute the best match for every patch in
% it's every possible position (left/right/bottom/top)
% intuition:
% We will also store the patch ID with which the max is formed for that
% patch, so that we can add those patches to pool patches (poolmat) when their
% boss is added to the answermat or poolmat

for i = 1:total_pieces
    for j = 1:4
        lolmax = -100;
        for k = 1:total_pieces
            if(newcompat(i,k,j) > lolmax)
                lolmax = newcompat(i,k,j);
                maxid = k;
            end
        end
        lolmax;
        maxmat(i,j,1) = lolmax;     % max value
        maxmat(i,j,2) = maxid;      % piece ID of that max value
    end
end


% pick the first piece
lol_max = -10000;
for i = 1:total_pieces-1
    four_sum = 0;
    %i
    for j = 1:4
        %j
        four_sum = four_sum + maxmat(i,j,1);
    end
    if(four_sum > lol_max)
        
        lol_max
        maxindi = i;
        lol_max = four_sum;
    end
end

placedarr(maxindi) = 1;
unplaced(maxindi) = 0;
% put the neighbours of best buddy in the pool
poolarr(maxmat(maxindi,1,2)) = 1;
daddy(maxmat(maxindi,1,2),1) = maxindi; 
poolarr(maxmat(maxindi,2,2)) = 1;
daddy(maxmat(maxindi,2,2),2) = maxindi;
poolarr(maxmat(maxindi,3,2)) = 1;
daddy(maxmat(maxindi,3,2),3) = maxindi;
poolarr(maxmat(maxindi,4,2)) = 1;
daddy(maxmat(maxindi,4,2),4) = maxindi;
count = 4;
poolcount = 4;

