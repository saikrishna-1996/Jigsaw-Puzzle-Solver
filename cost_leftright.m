
function [cost_lr] = cost_leftright(i,j)

global pieces;
global block_size;
% g_il = zeros(16,3);
% 
leftimg = pieces(i).data;
rightimg = pieces(j).data;

my_sum = 0;
for k = 1:block_size %iterating over rows in a fixed column
    for d = 1:3
        my_sum = my_sum + abs(2*leftimg(k,block_size,d) - leftimg(k,block_size-1,d) - rightimg(k,1,d));
    end
end
cost_lr = my_sum; 

% 
% for k = 1:block_size
% piece
%     % compute g_iL
%     g_il(k,1) = double(leftimg(k,16,1) - leftimg(k,15,1));
%     g_il(k,2) = double(leftimg(k,16,2) - leftimg(k,15,2));
%     g_il(k,3) = double(leftimg(k,16,3) - leftimg(k,15,3));
%     
%     % compute g_ij_LR
%     g_ij_lr(k,1) = double(rightimg(k,1,1) - leftimg(k,16,1));
%     g_ij_lr(k,2) = double(rightimg(k,1,2) - leftimg(k,16,2));
%     g_ij_lr(k,3) = double(rightimg(k,1,3) - leftimg(k,16,3));
%   
% end
% 
% % compute mean and covariance
% % https://in.mathworks.com/help/matlab/ref/cov.html
% mean_g_il = mean(g_il);
% s_il = cov(double(g_il));
% inv_s_il = inv(s_il);
% 
% %size(mean_g_il)
% %size(s_il)
% %size(g_ij_lr)
% 
% mysum = 0;
% for k = 1:block_size
%     mysum = mysum + (g_ij_lr(k) - mean_g_il)*inv_s_il*((g_ij_lr(k) - mean_g_il)');
% end
% cost_lr = mysum;