function [X] = initialization(POP, ub, lb, dim)
% POP 为树的数量
% dim 为个体的维度
% ub 为个体维度变量的上边界，维度为 [1, dim]
% lb 为个体维度变量的下边界，维度为 [1, dim]
% X 为输出的种群，维度为 [POP, dim]

X = zeros(POP, dim);
for i = 1:POP
    for j = 1:dim
        X(i, j) = (ub(j) - lb(j)) * rand() + lb(j);
    end
end
end
