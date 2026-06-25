% 种群初始化函数（向量化版）
% POP为种群数量
% dim为变量维度
% ub为变量上边界，维度为[1, dim]
% lb为变量下边界，维度为[1, dim]
% X为输出种群，维度为[POP, dim]
%
% 公式 (9.1): T_{i,j} = L_{j,min} + r_{i,j} * (H_{j,max} - L_{j,min})
% 采用矩阵运算一次性生成所有个体，比逐元素 for 循环快一个数量级

function [X] = initialization(POP, ub, lb, dim)
    X = lb + (ub - lb) .* rand(POP, dim);
end
