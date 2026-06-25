%% 利用树种优化算法求解 x1^2 + x2^2 的最小值
clc; clear all; close all;

% 设定树种优化算法的参数
POP = 50;           % 种群数量
dim = 2;            % 变量维度
ub = [10, 10];      % 树种优化算法的上边界
lb = [-10, -10];    % 树种优化算法的下边界
maxIter = 100;      % 最大迭代次数
fobj = @(x) fun(x); % 设置适应度函数为 fun(x)

% 利用树种优化算法求解问题
[Best_Pos, Best_Fitness, IterCurve] = TSA(POP, dim, ub, lb, fobj, maxIter);

% 绘制迭代曲线
figure
plot(IterCurve, 'r-', 'linewidth', 1.5);
grid on;
title('树种优化迭代曲线');
xlabel('迭代次数');
ylabel('适应度值');
disp(['求解得到的 x1, x2 为: ', num2str(Best_Pos(1)), '  ', num2str(Best_Pos(2))]);
disp(['最优解对应的函数值为: ', num2str(Best_Fitness)]);
