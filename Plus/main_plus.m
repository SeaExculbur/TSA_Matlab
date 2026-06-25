%% main_plus.m -- 树种优化算法优化版(TSA_plus)测试脚本
%%  自包含，仅依赖同目录下的 TSA_plus.m
%%  在三个标准测试函数上对比两种参数配置，每种运行 10 次取统计，绘制收敛曲线
%%  MATLAB R2016b 兼容

clc; clear all; close all;

%% ========== 实验参数 ==========
POP     = 30;       % 种群数量
maxIter = 200;      % 最大迭代次数
nRuns   = 10;       % 独立运行次数（取平均值）

%% ========== 定义标准测试函数 ==========
% 每个函数元胞: {名称, 函数句柄, 搜索范围, 理论最优值}
funcList = {
    'Sphere',    @(x) sum(x.^2),                              5,   0;
    'Rastrigin', @(x) sum(x.^2 - 10*cos(2*pi*x) + 10),        5,   0;
    'Ackley',    @(x) -20*exp(-0.2*sqrt(mean(x.^2))) ...
                     - exp(mean(cos(2*pi*x))) + 20 + exp(1),  32,  0
};
% Sphere：测收敛精度，有没有局部陷阱的滑坡；跑不好说明代码有错。
% Rastrigin：测跳出局部最优的能力，能否不被大量假坑欺骗。
% Ackley：测全局探索能力，能否在几乎零梯度的平坦区找到中心针孔。
nFuncs = size(funcList, 1);  % size用于计算矩阵维度，第二个参数决定是计算行1 还是列2。
% Sphere: f(x) = x?? + x?? + ... + x_d?
% Rastrigin: f(x) = (x?? - 10·cos(2π·x?) + 10) + (x?? - 10·cos(2π·x?) + 10) + ... + (x_d? - 10·cos(2π·x_d) + 10)
% Ackley:  f(x) = -20 · exp( -0.2 · √( (x?? + x?? + ... + x_d?) / d ) ) - exp( ( cos(2π·x?) + cos(2π·x?) + ... + cos(2π·x_d) ) / d ) + 20 + e

%% ========== 逐函数测试 ==========
for fIdx = 1:nFuncs
    fName    = funcList{fIdx, 1};
    fHandle  = funcList{fIdx, 2};
    fRange   = funcList{fIdx, 3};
    fOptimum = funcList{fIdx, 4};

    dim = 2;
    ub  = fRange * ones(1, dim);
    lb  = -ub;

    fprintf('\n========== 测试函数: %s ==========\n', fName);
    fprintf('搜索空间: [%d, %d]^%d, 理论最优值: %g\n', -fRange, fRange, dim, fOptimum);

    %% --- 配置1: 默认参数 (ST: 0.3 -> 0.05) ---
    results_cfg1 = zeros(nRuns, maxIter);
    % 10行，200列全零矩阵，每行存一次独立运行的收敛曲线（200 轮迭代的 gBestFit）。
    bestFits_cfg1 = zeros(1, nRuns);
    % 1 行 × 10 列的行向量。存每次独立运行的最终最优值。
    fprintf('\n--- TSA_plus 配置1 (ST=0.3->0.05) ---\n');
    for r = 1:nRuns
        [~, bf, ic] = TSA_plus(POP, dim, ub, lb, fHandle, maxIter, ...
            'ST_high', 0.3, 'ST_low', 0.05);
        results_cfg1(r, :) = ic;    % 对第r行填满所有列  (每行的结果存入矩阵里)
        bestFits_cfg1(r) = bf;      % 把每次运行的最优结果存入
        if mod(r, 2) == 0
            fprintf('  Run %2d/%d, 最优值: %.4e\n', r, nRuns, bf);
        end
    end

    %% --- 配置2: 激进参数 (ST: 0.5 -> 0.01) ---
    results_cfg2 = zeros(nRuns, maxIter);
    bestFits_cfg2 = zeros(1, nRuns);
    fprintf('\n--- TSA_plus 配置2 (ST=0.5->0.01) ---\n');
    for r = 1:nRuns
        [~, bf, ic] = TSA_plus(POP, dim, ub, lb, fHandle, maxIter, ...
            'ST_high', 0.5, 'ST_low', 0.01);
        results_cfg2(r, :) = ic;    % 对第r行填满所有列  (每行的结果存入矩阵里)
        bestFits_cfg2(r) = bf;
        if mod(r, 2) == 0
            fprintf('  Run %2d/%d, 最优值: %.4e\n', r, nRuns, bf);
        end
    end

    %% --- 统计结果 ---
    fprintf('\n===== 统计结果 (%d 次独立运行) =====\n', nRuns);
    fprintf('%-20s %12s %12s %12s\n', '配置', '均值', '标准差', '最小值');
    fprintf('%-20s %12.4e %12.4e %12.4e\n', ...
        '配置1(默认)', mean(bestFits_cfg1), std(bestFits_cfg1), min(bestFits_cfg1));
    fprintf('%-20s %12.4e %12.4e %12.4e\n', ...
        '配置2(激进)', mean(bestFits_cfg2), std(bestFits_cfg2), min(bestFits_cfg2));

    %% --- 绘制收敛曲线对比图 ---
    figure('Name', ['收敛曲线对比 -- ', fName], 'Position', [100, 100, 800, 550]);

    % 计算各配置的均值和标准差
    mean_cfg1 = mean(results_cfg1, 1);   % 求均值
    mean_cfg2 = mean(results_cfg2, 1);
    std_cfg1  = std(results_cfg1, 0, 1); % 求标准差
    std_cfg2  = std(results_cfg2, 0, 1);

    % 绘制均值曲线 (semilogy 对数坐标，更清晰地观察收敛趋势)
    semilogy(1:maxIter, mean_cfg1, 'r-',  'LineWidth', 1.5); hold on;
    semilogy(1:maxIter, mean_cfg2, 'b--', 'LineWidth', 1.5);

    % 绘制 ±1 标准差阴影区域
    fill([1:maxIter, maxIter:-1:1], ...
         [max(mean_cfg1 - std_cfg1, 1e-300), fliplr(mean_cfg1 + std_cfg1)], ...
         'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
    % [1:maxIter, maxIter:-1:1] 构造闭合 X 坐标：1→200→200→1 (fill需要一个封闭的多边形来绘制阴影)
    % [下边界, 上边界反转] 构造闭合 Y 坐标，围出阴影轮廓
    % max(..., 1e-300) 防止下边界为负导致对数坐标报错            （）
    % fliplr 将上边界左右翻转，与 X 坐标的返回路径同步
    % FaceAlpha=0.1 透明度 10%，EdgeColor='none' 不画轮廓线
    fill([1:maxIter, maxIter:-1:1], ...
         [max(mean_cfg2 - std_cfg2, 1e-300), fliplr(mean_cfg2 + std_cfg2)], ...
         'b', 'FaceAlpha', 0.1, 'EdgeColor', 'none');

    legend({'TSA\_plus 配置1 (ST=0.3->0.05)', ...
            'TSA\_plus 配置2 (ST=0.5->0.01)'}, ...
            'Location', 'northeast');
    xlabel('迭代次数');
    ylabel('适应度值 (log)');
    title(sprintf('%s 函数 -- 收敛曲线对比 (均值 +/- 1 标准差)', fName));
    grid on;
end

fprintf('\n========== 全部测试完成 ==========\n');
