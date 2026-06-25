function fitness = fun(x)
% x为输入个体当前位置，维度为[1, dim]
% fitness 为输出的适应度值

fitness = x(1)^2 + x(2)^2;
end
