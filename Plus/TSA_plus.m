function [Best_Pos, Best_fitness, IterCurve] = TSA_plus(POP, dim, ub, lb, fobj, maxIter, varargin)
% TSA_PLUS  树种优化算法优化版（自包含，MATLAB R2016b 兼容）
%
% 改进点:
%   1. 同步更新：每轮迭代共享同一个全局最优解，避免 O(POP^2) 次重复排序
%   2. 动态 ST：搜索趋势常数从大线性衰减到小，前期偏向全局探索，后期偏向局部开发
%   3. 向量化：初始化和边界检查采用矩阵/向量运算，无需逐元素循环
%   4. 鲁棒性：修复 POP = 1 时 while 循环死锁的问题
%
% 参考: Kiran et al., "A novel tree seed algorithm for optimization", 2015.
%
% 输入参数:
%   POP     - 种群数量（树的数量），标量
%   dim     - 问题维度，标量
%   ub      - 搜索空间上边界，向量 [1, dim]
%   lb      - 搜索空间下边界，向量 [1, dim]
%   fobj    - 适应度函数句柄，接收 [1, dim] 的行向量，返回标量适应度值
%   maxIter - 最大迭代次数，标量
%
% 可选参数（名值对，均可省略）:
%   'ST_high' - 初始 ST 值，默认 0.3
%   'ST_low'  - 最终 ST 值，默认 0.05
%
% 输出参数:
%   Best_Pos     - 最终最优位置，行向量 [1, dim]
%   Best_fitness - 最终最优适应度值，标量
%   IterCurve    - 迭代收敛曲线，行向量 [1, maxIter]，记录每轮迭代的全局最优适应度值

%% 解析可选参数
p = inputParser;
addParameter(p, 'ST_high', 0.3);
addParameter(p, 'ST_low',  0.05);
parse(p, varargin{:});      % varargin 相当于*kkwargs 解包，parse匹配了相应参数
ST_high = p.Results.ST_high;
ST_low  = p.Results.ST_low;

%% 种群初始化
% 公式 (9.1): T_{i,j} = L_{j,min} + r_{i,j} * (H_{j,max} - L_{j,min})
% 采用矩阵运算一次性生成所有树的位置，避免逐元素循环
trees = lb + (ub - lb) .* rand(POP, dim);  % 一次生成pop个随机数填满矩阵，然后放缩

%% 计算初始适应度值
fitness = zeros(1, POP);
for i = 1:POP
    fitness(i) = fobj(trees(i, :));
end

%% 记录全局最优解
% 公式 (9.2): B = min{f(T_i)}, i = 1, 2, ..., N
[SortFit, SortIdx] = sort(fitness);
gBest     = trees(SortIdx(1), :);      % 全局最优位置
gBestFit  = SortFit(1);                % 全局最优适应度值
IterCurve = zeros(1, maxIter);         % 用于存200轮迭代中的每轮全局最优解

%% 主迭代循环
for t = 1:maxIter
    % 动态 ST：线性衰减
    % 迭代初期 ST 大，偏向全局搜索（以全局最优为基准）；迭代后期 ST 小，偏向局部搜索（以自身为基准）
    ST = ST_high - (ST_high - ST_low) * (t / maxIter);

    for i = 1:POP
        % 随机确定第 i 棵树在本轮产生的种子数量，范围为 [ceil(0.1*POP), ceil(0.25*POP)]
        seedNum = fix((0.25 - 0.10) * POP * rand()) + ceil(0.10 * POP);
        seeds     = zeros(seedNum, dim);
        obj_seeds = zeros(1, seedNum);

        % 第 i 棵树产生种子
        for j = 1:seedNum
            % 随机选择一棵邻居树 komsu，确保 komsu 不等于 i
            % POP = 1 时直接设 komsu = 1，避免 while 循环死锁
            if POP > 1
                komsu = i;
                while komsu == i
                    komsu = fix(rand() * POP) + 1;
                end
            else
                komsu = 1;
            end

            % 公式 (9.3): 逐维度更新种子位置
            %  S_{i,j} = T_i + alpha * (B - T_r)          ,  rand < ST  (全局搜索)
            %  S_{i,j} = T_i + alpha * (T_i - T_r)        ,  rand >= ST (局部搜索)
            for d = 1:dim
                alpha = (rand() - 0.5) * 2;  % 步长因子，范围 [-1, 1]
                if rand() < ST
                    % 全局搜索：以当前最优树 B 为基准，增强探索能力
                    seeds(j, d) = trees(i, d) + alpha * (gBest(d) - trees(komsu, d));
                else
                    % 局部搜索：以自身为基准，增强开发能力
                    seeds(j, d) = trees(i, d) + alpha * (trees(i, d) - trees(komsu, d));
                end
            end

            % 边界检查：向量化写法，将越界值直接钳制到边界上
            seeds(j, :) = max(min(seeds(j, :), ub), lb);

            % 计算该种子的适应度值
            obj_seeds(j) = fobj(seeds(j, :));
        end

        % 在当前树产生的所有种子中找到最优种子
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

    % 记录本轮迭代的全局最优适应度值
    IterCurve(t) = gBestFit;
end

%% 输出
Best_Pos     = gBest;
Best_fitness = gBestFit;
end
