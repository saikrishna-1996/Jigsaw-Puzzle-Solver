function [cost_tb] = cost_topbottom(i,j)

global pieces;
global block_size;
% g_il = zeros(16,3);
% 
topimg = pieces(i).data;
bottomimg = pieces(j).data;

my_sum = 0;
for k = 1:block_size %iterating over columns in a fixed row
    for d = 1:3
        my_sum = my_sum + 2*topimg(block_size,k,d) - topimg(block_size-1,k,d) - bottomimg(1,k,d);
    end
end
cost_tb = my_sum; 
