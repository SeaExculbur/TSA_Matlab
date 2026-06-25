%% main_plus.m -- 树种优化算法拆分版测试脚本
%%  需同目录下的 TSA_plus.m, initialization.m, BoundaryCheck.m
%%  在三个标准测试函数上对比两种参数配置的 TSA_plus

clc; clear all; close all;

%% ========== 实验参数 ==========
POP     = 30;
maxIter = 200;
nRuns   = 10;

%% ========== 标准测试函数 ==========
funcList = {
    'Sphere',    @(x) sum(x.^2),                              5,   0;
    'Rastrigin', @(x) sum(x.^2 - 10*cos(2*pi*x) + 10),       5,   0;
    'Ackley',    @(x) -20*exp(-0.2*sqrt(mean(x.^2))) ...
                     - exp(mean(cos(2*pi*x))) + 20 + exp(1),  32,  0
};

nFuncs = size(funcList, 1);

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

    %% --- 配置1: 默认参数 ---
    results_cfg1 = zeros(nRuns, maxIter);
    bestFits_cfg1 = zeros(1, nRuns);
    fprintf('\n--- TSA_plus 配置1 (ST=0.3->0.05, Elite=1) ---\n');
    for r = 1:nRuns
        [~, bf, ic] = TSA_plus(POP, dim, ub, lb, fHandle, maxIter, ...
            'ST_high', 0.3, 'ST_low', 0.05, 'Elite', 1);
        results_cfg1(r, :) = ic;
        bestFits_cfg1(r) = bf;
        if mod(r, 2) == 0
            fprintf('  Run %2d/%d, 最优值: %.4e\n', r, nRuns, bf);
        end
    end

    %% --- 配置2: 激进参数 ---
    results_cfg2 = zeros(nRuns, maxIter);
    bestFits_cfg2 = zeros(1, nRuns);
    fprintf('\n--- TSA_plus 配置2 (ST=0.5->0.01, Elite=2) ---\n');
    for r = 1:nRuns
        [~, bf, ic] = TSA_plus(POP, dim, ub, lb, fHandle, maxIter, ...
            'ST_high', 0.5, 'ST_low', 0.01, 'Elite', 2);
        results_cfg2(r, :) = ic;
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

    %% --- 收敛曲线对比图 ---
    figure('Name', ['收敛曲线对比 -- ', fName], 'Position', [100, 100, 800, 550]);

    mean_cfg1 = mean(results_cfg1, 1);
    mean_cfg2 = mean(results_cfg2, 1);
    std_cfg1  = std(results_cfg1, 0, 1);
    std_cfg2  = std(results_cfg2, 0, 1);

    semilogy(1:maxIter, mean_cfg1, 'r-',  'LineWidth', 1.5); hold on;
    semilogy(1:maxIter, mean_cfg2, 'b--', 'LineWidth', 1.5);

    fill([1:maxIter, maxIter:-1:1], ...
         [max(mean_cfg1 - std_cfg1, 1e-300), fliplr(mean_cfg1 + std_cfg1)], ...
         'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
    fill([1:maxIter, maxIter:-1:1], ...
         [max(mean_cfg2 - std_cfg2, 1e-300), fliplr(mean_cfg2 + std_cfg2)], ...
         'b', 'FaceAlpha', 0.1, 'EdgeColor', 'none');

    legend({'TSA\_plus 配置1 (ST=0.3->0.05, Elite=1)', ...
            'TSA\_plus 配置2 (ST=0.5->0.01, Elite=2)'}, ...
            'Location', 'northeast');
    xlabel('迭代次数');
    ylabel('适应度值 (log)');
    title(sprintf('%s 函数 -- 收敛曲线对比 (均值 +/- 1 标准差)', fName));
    grid on;
end

fprintf('\n========== 全部测试完成 ==========\n');
