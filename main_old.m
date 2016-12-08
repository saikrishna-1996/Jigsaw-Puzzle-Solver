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

total_pieces = 16;
puzzle_size = 16;
block_size = 128;
piece_size = 128;

%% load all the pieces
for i = 1:total_pieces
    pieces(i).id = i;
    iname = sprintf('/home/krish/jigsaw/jigsaw-solver/old3_generated_pieces/%d.jpg',i);
    %pieces(i).data = (double(imread(iname)))*255;
    pieces(i).data = imread(iname); %otherwise it will overflow
    %cform = makecform('srgb2lab');
    %pieces(i).data = applycform(pieces(i).data, cform);
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
            newcompat(i,j,1) = -1000;
            newcompat(i,j,2) = -1000;
            newcompat(i,j,3) = -1000;
            newcompat(i,j,4) = -1000;
        end
    end
end

%% reconstruct the image


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
            if(newcompat(i,j,k) > lolmax)
                lolmax = newcompat(i,j,k);
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


newimg = zeros(4*puzzle_size,4*puzzle_size,3);
top_x = 1024; %cols
top_y = 1024; %rows
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
        end
    end
end
end
imshow((newimg))

% newimg = zeros(1024,1024,3);
% top_x = 512; %cols
% top_y = 512; %rows
% for i = 1:piece_size
%     for j = 1:piece_size
%         newimg(i+top_x,j+top_y,:) = pieces(baap).data(i,j,:);
%     end
% end
% 
% top = zeros(16,2);
% top(baap,1) = top_x;
% top(baap,2) = top_y;
% 
% for i = 1:total_pieces
%     convisited(i) = 0;
%     conpool(i) = 0;
%     conunvisit(i) = 1;
% end
% 
% convisited(baap) = 1;
% conunvisit(baap) = 0;
% 
% visitcount = 1;
% currindi = baap;
% for dasd = 1:16
% for i = 1:total_pieces
%     if(convisited(i) == 1)
%         for k = 1:total_pieces
%             for j = 1:4
%                 
%                 if((daddy(k,j) == i) & convisited(k) == 0)
%                    
%                     mydaddy = i;
%                     convisited(k) = 1;
%                     visitcount = visitcount + 1;
%                     if(j == 1)
%                         top(k,1) = top(mydaddy,1) + piece_size;
%                         top(k,2) = top(mydaddy,2);
%                     elseif(j == 2)
%                         top(k,1) = top(mydaddy,1) - piece_size;
%                         top(k,2) = top(mydaddy,2);
%                     elseif(j == 3)
%                         top(k,1) = top(mydaddy,1);
%                         top(k,2) = top(mydaddy,2) + piece_size;
%                     else
%                         top(k,1) = top(mydaddy,1);
%                         top(k,2) = top(mydaddy,2) - piece_size;
%                     end
%                     i,k
%                     top_x = top(k,2)
%                     top_y = top(k,1)
%                     for lool1 = 1:piece_size
%                         for lool2 = 1:piece_size
%                             newimg(top_x+lool1,top_y+lool2,:) = pieces(k).data(lool1,lool2,:);
%                         end
%                     end
%                 end
%             end
            
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
%             
%         end
%     end
% end
% end
% imshow(uint8(newimg))

% maxmat = zeros(total_pieces,4,2); %one is for value and one is for ID
% placedmat = zeros(total_pieces,4);
% for i = 1:total_pieces
%     poolarr(i) = 0;
%     placedarr(i) = 0;
%     unplacedarr(i) = 1;
% end
% daddy = zeros(total_pieces,4);
% answermat = zeros(total_pieces,total_pieces,4);
% poolcount = 0;
% 
% % first, we will compute the maxmat, which is the  maximum in every row.
% % This is to say that, we will compute the best match for every patch in
% % it's every possible position (left/right/bottom/top)
% % intuition:
% % We will also store the patch ID with which the max is formed for that
% % patch, so that we can add those patches to pool patches (poolmat) when their
% % boss is added to the answermat or poolmat
% 
% for i = 1:total_pieces
%     for j = 1:4
%         lolmax = -100;
%         for k = 1:total_pieces
%             if(newcompat(i,k,j) > lolmax)
%                 lolmax = newcompat(i,k,j);
%                 maxid = k;
%             end
%         end
%         lolmax
%         maxmat(i,j,1) = lolmax;     % max value
%         maxmat(i,j,2) = maxid;      % piece ID of that max value
%     end
% end
% 
% 
% % pick the first piece
% lolmax = -100;
% for i = total_pieces
%     four_sum = 0;
%     for j = 1:4
%         four_sum = four_sum + maxmat(i,j,1);
%     end
%     if(four_sum > lolmax)
%         maxindi = i;
%         lolmax = four_sum;
%     end
% end
% 
% placedarr(maxindi) = 1;
% unplaced(maxindi) = 0;
% % put the neighbours of best buddy in the pool
% poolarr(maxmat(maxindi,1,2)) = 1;
% daddy(maxmat(maxindi,1,2),1) = maxindi; 
% poolarr(maxmat(maxindi,2,2)) = 1;
% daddy(maxmat(maxindi,2,2),2) = maxindi;
% poolarr(maxmat(maxindi,3,2)) = 1;
% daddy(maxmat(maxindi,3,2),3) = maxindi;
% poolarr(maxmat(maxindi,4,2)) = 1;
% daddy(maxmat(maxindi,4,2),4) = maxindi;
% count = 4;
% poolcount = 4;
% 
% %%
% % completely remove the element from unplacedarr and don't consider it
% % while computing the maxmat again
% %for lol = 1:total_pieces
% while(poolcount > 0)                 % iterating
%     
%     % compute the maxmat (in every iteration)
% %     maxmat = zeros(total_pieces,4,2);
% %     for i = 1:total_pieces
% %         if(placedarr(i) == 0)
% %             for j = 1:4
% %                 maxval = -100;
% %                 for k = 1:total_pieces
% %                     if((newcompat(i,k,j) > maxval) && (placedarr(k) == 0))
% %                         maxval = newcompat(i,k,j);
% %                         maxindi = k;
% %                     end
% %                 end
% %                 maxmat(i,j,1) = maxval;
% %                 maxmat(i,j,2) = maxindi;
% %             end
% %         else
% %             for j = 1:4
% %                 maxmat(i,j,1) = 0;
% %                 %maxmat(i,j,2) = daddy(maxmat(i,j,2),j);
% %             end
% %         end
% %     end
% %     
%     % choose the best element from the pool
%     for i = 1:total_pieces
%         if(poolarr(i) == 1)
%             four_sum = 0;
%             for j = 1:4
%                 four_sum = four_sum + maxmat(i,j,1);
%             end
%             if(four_sum > lolmax)
%                 maxindi = i;
%                 lolmax = four_sum;
%             end
%         end
%     end
%     
%     % put this in placedarr with it's daddy
%     placedarr(maxindi) = 1;
%     poolarr(maxindi) = 0;
%     unplacedarr(maxindi) = 0;
%     poolcount = poolcount - 1;
%     for j = 1:4
%         if(daddy(maxindi,j) ~= 0)
%             answermat(daddy(maxindi,j),maxindi,j) = 1;
%         end
%     end
%     
%     % get the elements to poolmat which are not there already
%     for j = 1:4
%         myindi = maxmat(maxindi,j,2);
%         if((poolarr(myindi) == 0))
%             poolcount = poolcount + 1;
%             poolarr(myindi) = 1;
%             unplacedarr(myindi) = 0;
%         end
%     end
%     poolcount = 0;
%     for i = 1:total_pieces
%         if(poolarr(i) == 1)
%             poolcount = poolcount + 1;
%         end
%     end
% end
% 
%   maxmat = zeros(total_pieces,4,2);
%     for i = 1:total_pieces
%         if(placedarr(i) == 0)
%             for j = 1:4
%                 maxval = -100;
%                 for k = 1:total_pieces
%                     if((newcompat(i,k,j) > maxval) && (placedarr(k) == 0))
%                         maxval = newcompat(i,k,j);
%                         maxindi = k;
%                     end
%                 end
%                 maxmat(i,j,1) = maxval;
%                 maxmat(i,j,2) = maxindi;
%             end
%         else
%             for j = 1:4
%                 maxmat(i,j,1) = 0;
%                 %maxmat(i,j,2) = daddy(maxmat(i,j,2),j);
%             end
%         end
%     end
% 
% %end
% 
% % Now, we need to consider all elements in poolarr to be considered to be
% % pushed to placedarr
% 
% % for i = 1:total_pieces % just the iteration number (like: Bellman-ford algo)
% %     maxsum = -100;
% %     for j = 1:total_pieces
% %         if((poolarr(j) == 1) && (placedarr(j) == 0))
% %            curr_sum = maxmat(j,1,1) + maxmat(j,2,1) + maxmat(j,3,1) + maxmat(j,4,1);
% %             if(curr_sum > maxsum)
% %                 maxsum = curr_sum;
% %                 maxid = j;
% %             end
% %         end
% %     end
% %     placedarr(maxid) = 1;
% %     poolarr(maxid) = 0;
% %     for j = 1:4
% %         if(daddy(maxid,j) ~= 0)
% %             answermat(daddy(maxid,j),maxid,j) = 1;
% %         end
% %     end
% %     poolarr(maxmat(maxid,1,2)) = 1;
% %     daddy(maxmat(maxid,1,2),1) = maxid;
% %     
% %     poolarr(maxmat(maxid,2,2)) = 1;
% %     daddy(maxmat(maxid,2,2),2) = maxid;
% %     
% %     poolarr(maxmat(maxid,3,2)) = 1;
% %     daddy(maxmat(maxid,3,2),3) = maxid;
% %     
% %     poolarr(maxmat(maxid,4,2)) = 1;
% %     daddy(maxmat(maxid,4,2),4) = maxid;
% % 
% % end
%     
% %    max_of_max = -100;
% %     for j = 1:4
% %         %count = count + 1;
% %         %poolarr(count) = maxmat(maxid,j,2);
% %         if(maxmat(maxid,j,1) > max_of_max)
% %             max_of_max = maxmat(maxid,j,1);
% %             his_best_buddy = maxmat(maxid,j,2);
% %             rotnumber = j;
% %         end
% %     end
%     
% %     for j = 1:4
% %         if(j == rotnumber)
% %             if(placedarr(his_best_buddy) == 1) % best buddy is already placed
% %                 placedmat(maxid,his_best_buddy,j) = 1;
% %             else                               % if it's not placed and
% %                 if(poolmat(maxid,j,2) 
% %                 count = count + 1;
% %                 poolmat(count) = his_best_buddy;
% %             end
% %         else
% %             if(poolamt(maxid,j,2) == 0)
% %                 count = count+1;
% %                 poolmat(maxmat(maxid,j,2)) = 1;
% %             end
% %         end
% %     end
%             
%                 
                