function [cost_bt] = cost_bottomtop(i,j)

global pieces;
global block_size;
% g_il = zeros(16,3);
% 
topimg = pieces(i).data;
bottomimg = pieces(j).data;

my_sum = 0;
for k = 1:block_size %iterating over columns in a fixed row
    for d = 1:3
        my_sum = my_sum + 2*bottomimg(block_size,1,d) - topimg(block_size,k,d) - bottomimg(2,k,d);
    end
end
cost_bt = my_sum; 
