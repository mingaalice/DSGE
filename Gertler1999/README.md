# Gertler (1999) Dynare 模拟包

本目录将 Gertler (1999) OLG 模型用于两类分析：

1. **预测模块**：从不同年份的观测状态出发，计算模型预测路径，并用实际增长率评估预测误差。
2. **财政政策冲击模块**：改变政府支出、社会保障或政府债务目标，比较稳态差异或完整转轨路径。

这里的“冲击”是**永久性财政政策参数变化的反事实实验**，不是随机外生冲击或脉冲响应分析。

## 运行环境与数据准备

- 使用 MATLAB，并确保 Dynare 已安装且 `dynare` 命令在 MATLAB 路径中。
- 已填好真实数据 `initial_states.csv` 和 `real_value.csv`。
- 所有模型中的实际量均按有效劳动 $X_tN_t$ 归一化。增长率和相对变化以小数保存，例如 `0.01` 表示 `1%`。
- 各脚本会在当前工作目录生成 `.mat`、`.csv` 和临时 `.mod` 文件；请从本目录运行，以便相对路径能找到输入文件。

### 输入数据格式

| 文件 | 必需字段 | 用途 |
|---|---|---|
| `initial_states.csv` | `year`, `k0`, `b0`, `lambda0` | 各年份的模型初始状态。预测需要 2013–2025 年对应状态；政策实验使用 2014 年状态。 |
| `real_value.csv` | `year`, `KN_growth`, `lambda_growth`, `r_growth` | 实际增长率，用于和预测增长率按目标年份匹配并计算 RMSE。 |

**字段名注意：** 

`real_value.csv` 中的三个增长率需要与代码定义一致：`KN_growth` 是资本 `k` 的对数增长再加上技术增长 `x=0.01`；`lambda_growth` 和 `r_growth` 是各自的对数增长。请统一使用小数而不是百分数（例如填 `0.02`，而不是 `2`）。

## 模块一：预测

### 执行顺序

2. 在 MATLAB 中运行 `recursive_forecast.m`，生成各预测起点的 20 年路径。
3. 后运行 `forecast_rmse.m`，得到 1–5 年期 RMSE。

### 代码与输入输出

| 文件 | 用途 | 输入 | 输出 |
|---|---|---|---|
| `gertler_model.mod` | 基准 Gertler (1999) OLG 模型。设置模型参数、财政基准参数和稳态初值，并求解稳态。 | Dynare 模型方程及文件内参数。 | Dynare 内存结果 `M_`, `oo_`；被 `recursive_forecast.m` 调用。 |
| `recursive_forecast.m` | 先求基准稳态，再对 2013–2025 每个起始年份逐年建立 perfect-foresight 预测。每次以该年的 `k,b,lambda` 为初始状态，以基准稳态为终点，预测 20 年。 | `initial_states.csv`；`gertler_model.mod`；MATLAB/Dynare。 | `gertler_steady_state.mat`（`k_ss`, `lambda_ss`, `b_ss`）；每个起点对应 `forecast_年份.mat`；汇总文件 `recursive_results.mat`（结构体 `results`，含起始年份、内生变量名称及模拟路径）。 |
| `forecast_rmse.m` | 把模型预测的状态路径转换为增长率，按预测起点和目标年份匹配实际值，计算每个变量 1–5 年期的 RMSE。 | `recursive_results.mat`; `real_value.csv`。 | `forecast_RMSE_h.csv`，列为 `Variable`, `Horizon`, `RMSE`。 |

预测误差定义为模型预测增长率减去实际增长率；RMSE 为每个预测期误差平方均值的平方根。没有实际观测值的目标年份会被跳过；若某个期限没有可用误差，RMSE 写为 `NaN`。

## 模块二：财政政策冲击与反事实

### 执行顺序

1. 在 MATLAB 中运行 `policy_transition.m`，得到三次反事实实验各变量的变化比例
2. 后运行 `policy_sweeps.m`，得到长期均衡的变化。

三个实验分别改变一个长期财政参数：

| 实验 | 基准值 | 反事实值 | 政策模型 |
|---|---:|---:|---|
| 政府支出占产出比 `gbar` | 0.20 | 0.30 | `gertler_policy_g.mod` |
| 社会保障参数 `ebar` | 0.05 | 0.03 | `gertler_policy_e.mod` |
| 债务占产出目标 `bbar` | 0.60 | 0.80 | `gertler_policy_b.mod` |

### 稳态扫描与动态转轨

| 文件 | 用途 | 输入 | 输出 |
|---|---|---|---|
| `gertler_policy_g.mod` | 政府支出政策模型模板；固定 `ebar=0.05`, `bbar=0.60`，由调用脚本指定 `gbar`。 | 模型方程；运行时附加的 `gbar`。 | Dynare 模型，供稳态扫描和转轨实验使用。 |
| `gertler_policy_e.mod` | 社会保障政策模型模板；固定 `gbar=0.20`, `bbar=0.60`，由调用脚本指定 `ebar`。 | 模型方程；运行时附加的 `ebar`。 | Dynare 模型，供稳态扫描和转轨实验使用。 |
| `gertler_policy_b.mod` | 债务目标政策模型模板；固定 `gbar=0.20`, `ebar=0.05`，由调用脚本指定 `bbar`。 | 模型方程；运行时附加的 `bbar`。 | Dynare 模型，供稳态扫描和转轨实验使用。 |
| `policy_sweeps.m` | 分别扫描三类政策参数，计算每个设定相对基准政策稳态的变化。扫描范围：`gbar=0.10:0.10:0.60`、`ebar=0.01:0.01:0.07`、`bbar=0.40:0.05:1.00`。 | `initial_states.csv` 的 2014 年状态；三个政策模型；`run_steady_state.m`。 | `policy_sweep_results.csv` 和 `policy_sweep_results.mat`。变化列为 `k_change`, `lambda_change`, `r_change`，定义为 `(反事实稳态-基准稳态)/基准稳态`。 |
| `policy_transition.m` | 对三项政策分别进行基准与反事实的 100 期 perfect-foresight 转轨模拟，比较逐期路径。 | `initial_states.csv` 的 2014 年状态；三个政策模型；`run_dynare_policy.m`。 | 中间文件 `temp_g_baseline.mat` 等 6 个基准/反事实结果文件；汇总 `policy_transition_results.csv` 和 `policy_transition_results.mat`。变化列同样是 `(反事实-基准)/基准`。 |
| `run_steady_state.m` | 被 `policy_sweeps.m` 调用的辅助函数：复制指定模型模板，写入初始状态和三个财政参数，求解稳态。 | `modfile`, `gbar`, `ebar`, `bbar`, `state`（含 `k0`, `lambda0`, `b0`）。 | 结构体 `result`，含稳态 `k`, `lambda`, `r`。运行时生成并删除 `temp_ss.mod` 和 `temp_ss_result.mat`。 |
| `run_dynare_policy.m` | 被 `policy_transition.m` 调用的辅助函数：写入初始状态及政策值，求解初始/终端稳态，再运行 40 期转轨。 | `modfile`, `parameter`, `value`, `state`, `name`。`parameter` 为 `gbar`/`ebar`/`bbar`；`state` 含 `k0`, `lambda0`, `b0`。 | 保存 `temp_<name>.mat`，其中含 Dynare 结果 `oo_`, `M_`；临时模型文件 `temp_policy.mod` 随后删除。 |

政策结果中的变化量是比例，不是已经乘以 100 的百分数；需要百分数展示时再乘以 100。`policy_transition.m` 的结果按年份和实验标识记录。扫描实验和转轨实验都从 `initial_states.csv` 的 2014 年行读取初始状态。

## 模型变量与参数

模型代码将所有实际量按有效劳动归一化。下表按变量在方程中的含义说明；`pi`, `eps`, `Omega`, `lambda` 是模型内部的状态/权重变量，代码没有另行提供面向数据的观测定义，不能直接把它们当作 CSV 中的增长率变量。

### 内生变量

| 变量 | 含义 |
|---|---|
| `k` | 每单位有效劳动的资本存量。预测中由 `k` 的对数差分构造资本增长。 |
| `lambda` | OLG 人口/生命周期结构中的状态权重，按模型方程递推；本项目把它作为初始状态及关注的模型结果。 |
| `pi` | 模型中的概率/权重项，进入消费与生命周期方程。 |
| `eps` | 模型中的人口转移/权重项，和 `pi` 一起进入生命周期方程。 |
| `Omega` | 由 `eps` 与参数 `omega`, `sigma` 决定的未来权重调整项。 |
| `h` | 人力财富的递归现值项，由劳动收入、税收和未来人力财富构成。 |
| `c` | 总消费。 |
| `r` | 资本的总回报因子；方程为资本边际产出加未折旧部分。此处为总回报因子，不是净利率。 |
| `s` | 社会保障给付/权益的递归价值项。 |
| `sw` | 社会保障财富相关的递归价值项，进入消费方程。 |
| `a` | 总资产，模型设为 `k+b`。 |
| `tau` | 税收/税收收入变量；政府预算关系中调整以支持债务路径。 |
| `y` | 产出，生产函数为 `y=k^(1-alpha)`。 |
| `b` | 政府债务存量，满足 `b=bbar*y`。 |

### 参数

| 参数 | 含义及模型设定 |
|---|---|
| `beta` | 偏好/贴现方程使用的参数，设为 `1`。 |
| `sigma` | 偏好方程的曲率参数，设为 `0.25`。 |
| `omega` | 生命周期结构参数，设为 `0.977`。 |
| `gamma` | 生命周期/人口结构参数，设为 `0.9`。 |
| `alpha` | 生产函数资本份额，设为 `0.667`。 |
| `delta` | 折旧率，设为 `0.1`。 |
| `n` | 人口增长率，设为 `0.01`。 |
| `x` | 劳动增进型技术增长率，设为 `0.01`。 |
| `q` | 有效劳动的总增长因子，定义为 `(1+n)*(1+x)`。 |
| `psi` | 由 `omega`, `n`, `gamma` 派生的辅助参数，定义为 `(1-omega)/(1+n-gamma)`。 |
| `gbar` | 政府支出占产出比；基准 `0.20`。 |
| `ebar` | 社会保障政策参数；基准 `0.05`。 |
| `bbar` | 政府债务占产出目标；基准 `0.60`。 |

## 输出文件速查

| 输出文件 | 由谁生成 | 内容 |
|---|---|---|
| `gertler_steady_state.mat` | `recursive_forecast.m` | 基准模型稳态的 `k_ss`, `lambda_ss`, `b_ss`。 |
| `forecast_年份.mat` | `recursive_forecast.m` | Dynare 保存的对应预测起点模拟对象。 |
| `recursive_results.mat` | `recursive_forecast.m` | 全部预测起点的年份、变量名及模拟路径。 |
| `forecast_RMSE_h.csv` | `forecast_rmse.m` | 各预测变量在 1–5 年期限的 RMSE。 |
| `policy_sweep_results.csv`, `policy_sweep_results.mat` | `policy_sweeps.m` | 政策参数扫描及稳态相对变化。 |
| `policy_transition_results.csv`, `policy_transition_results.mat` | `policy_transition.m` | 政策基准与反事实的逐期转轨相对变化。 |
| `temp_*.mat` | 政策实验脚本/辅助函数 | Dynare 中间结果；同名运行会覆盖。 |