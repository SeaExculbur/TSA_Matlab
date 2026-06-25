% 适应度函数
% x为输入个体当前位置，维度为[1, dim]
% fitness为输出的适应度值

function fitness = fun(x)
    fitness = sum(x.^2);
end
