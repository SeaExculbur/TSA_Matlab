function [Best_Pos, Best_fitness, IterCurve] = TSA(POP, dim, ub, lb, fobj, maxIter)
% 输入:
% POP 为种群数量
% dim 为单个个体的维度
% ub 为上边界信息，维度为 [1, dim]
% lb 为下边界信息，维度为 [1, dim]
% fobj 为适应度函数接口
% maxIter 为算法的最大迭代次数，用于控制算法的停止
% 输出:
% Best_Pos 为利用树种优化算法找到的最优位置
% Best_fitness 为最优位置对应的适应度值
% IterCurve 用于记录每次迭代的最优适应度值，即后续用来绘制迭代曲线

% 树能产生种子的数量范围
low = ceil(0.1 * POP);
high = ceil(0.25 * POP);
ST = 0.1;  % 概率阈值

% 初始化种群位置
trees = initialization(POP, ub, lb, dim);

% 计算适应度值
fitness = zeros(1, POP);
for i = 1:POP
    fitness(i) = fobj(trees(i, :));
end

% 寻找适应度最小的位置，记录全局最优位置
[SortFitness, indexSort] = sort(fitness);
gBest = trees(indexSort(1), :);      % 全局最优位置
gBestFitness = SortFitness(1);        % 全局最优位置对应的适应度值

% 开始迭代
for t = 1:maxIter
    for i = 1:POP
        % 在种子数量范围内，随机生成产生种子的数目
        seedNum = fix((high - low) * rand()) + low;
        seeds = zeros(seedNum, dim);
        obj_seeds = zeros(1, seedNum);

        % 寻找最优树木
        [minimum, min_indis] = min(fitness);
        bestParams = trees(min_indis, :);

        % 树木产生种子
        for j = 1:seedNum
            komsu = fix(rand() * POP) + 1;  % 随机选择一棵树
            while (i == komsu)              % 保证 komsu 不等于 i
                komsu = fix(rand() * POP) + 1;
            end
            seeds(j, :) = trees(i, :);

            % 树产生种子
            for d = 1:dim
                if (rand() < ST)
                    seeds(j, d) = trees(i, d) + (bestParams(d) - trees(komsu, d)) * (rand() - 0.5) * 2;
                else
                    seeds(j, d) = trees(i, d) + (trees(i, d) - trees(komsu, d)) * (rand() - 0.5) * 2;
                end
            end

            % 边界检查
            seeds(j, :) = BoundaryCheck(seeds(j, :), ub, lb, dim);

            % 计算适应度值
            obj_seeds(j) = fobj(seeds(j, :));
        end

        % 在种子中寻找适应度值最优的种子
        [mintohum, mintohum_indis] = min(obj_seeds);

        % 若种子更优，则替换原始树
        if (mintohum < fitness(i))
            trees(i, :) = seeds(mintohum_indis, :);
            fitness(i) = mintohum;
        end
    end

    % 寻找最优树
    [min_tree, min_tree_index] = min(fitness);

    % 更新全局最优树
    if (min_tree < gBestFitness)
        gBestFitness = min_tree;
        gBest = trees(min_tree_index, :);
    end

    IterCurve(t) = gBestFitness;
end

% 输出最优位置和对应的适应度值
Best_Pos = gBest;
Best_fitness = gBestFitness;
end
