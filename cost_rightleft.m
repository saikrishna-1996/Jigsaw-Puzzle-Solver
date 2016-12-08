function [cost_rl] = cost_rightleft(i,j)

global pieces;
global block_size;
% g_il = zeros(16,3);
% 
leftimg = pieces(i).data;
rightimg = pieces(j).data;

my_sum = 0;
for k = 1:block_size %iterating over rows in a fixed column
    for d = 1:3
        my_sum = my_sum + 2*rightimg(1,block_size,d) - leftimg(k,block_size,d) - rightimg(k,2,d);
    end
end
cost_rl = my_sum; 
