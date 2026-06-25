% 边界检查函数（向量化版）
% dim为数据的维度大小
% x为输入数据，维度为[1, dim]
% ub为数据上边界，维度为[1, dim]
% lb为数据下边界，维度为[1, dim]
%
% 采用 max(min(...)) 向量化钳制，一次处理所有维度

function [X] = BoundaryCheck(x, ub, lb, dim)
    X = max(min(x, ub), lb);
end
