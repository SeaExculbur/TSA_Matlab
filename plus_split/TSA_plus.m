function [Best_Pos, Best_fitness, IterCurve] = TSA_plus(POP, dim, ub, lb, fobj, maxIter, varargin)
% TSA_PLUS  树种优化算法优化版（拆分版，需同目录下的 initialization.m 和 BoundaryCheck.m）
%
% 与原始 TSA 使用相同的文件结构，但内部算法全部改进：
%   1. 同步更新：每轮迭代共享同一个全局最优解
%   2. 动态 ST：搜索趋势常数从大线性衰减到小
%   3. 拆分的 initialization 和 BoundaryCheck 内部已向量化
%   4. 修复 POP=1 死循环
%
% 参考: Kiran et al., "Tree Seed Algorithm", 2015.

%% 解析可选参数
p = inputParser;
addParameter(p, 'ST_high', 0.3);
addParameter(p, 'ST_low',  0.05);
parse(p, varargin{:});
ST_high = p.Results.ST_high;
ST_low  = p.Results.ST_low;

%% 种群初始化（调用外部向量化 initialization.m）
trees = initialization(POP, ub, lb, dim);

%% 计算初始适应度值
fitness = zeros(1, POP);
for i = 1:POP
    fitness(i) = fobj(trees(i, :));
end

%% 记录全局最优解
[SortFit, SortIdx] = sort(fitness);
gBest     = trees(SortIdx(1), :);
gBestFit  = SortFit(1);
IterCurve = zeros(1, maxIter);

%% 主迭代循环
for t = 1:maxIter
    % 动态 ST：线性衰减
    ST = ST_high - (ST_high - ST_low) * (t / maxIter);

    for i = 1:POP
        % 随机确定种子数量
        seedNum = fix((0.25 - 0.10) * POP * rand()) + ceil(0.10 * POP);
        seeds     = zeros(seedNum, dim);
        obj_seeds = zeros(1, seedNum);

        % 第 i 棵树产生种子
        for j = 1:seedNum
            % 选择邻居树（修复 POP=1 死循环）
            if POP > 1
                komsu = i;
                while komsu == i
                    komsu = fix(rand() * POP) + 1;
                end
            else
                komsu = 1;
            end

            % 公式 (9.3): 逐维度更新
            for d = 1:dim
                alpha = (rand() - 0.5) * 2;
                if rand() < ST
                    seeds(j, d) = trees(i, d) + alpha * (gBest(d) - trees(komsu, d));
                else
                    seeds(j, d) = trees(i, d) + alpha * (trees(i, d) - trees(komsu, d));
                end
            end

            % 边界检查（调用外部向量化 BoundaryCheck.m）
            seeds(j, :) = BoundaryCheck(seeds(j, :), ub, lb, dim);

            % 计算种子的适应度值
            obj_seeds(j) = fobj(seeds(j, :));
        end

        % 找最优种子
        [minSeed, minSeedIdx] = min(obj_seeds);

        % 若最好的种子比当前树更优，则替换
        if minSeed < fitness(i)
            trees(i, :) = seeds(minSeedIdx, :);
            fitness(i)  = minSeed;
        end
    end

    % 更新全局最优解
    [iterBestFit, iterBestIdx] = min(fitness);
    if iterBestFit < gBestFit
        gBestFit = iterBestFit;
        gBest    = trees(iterBestIdx, :);
    end

    IterCurve(t) = gBestFit;
end

%% 输出
Best_Pos     = gBest;
Best_fitness = gBestFit;
end
