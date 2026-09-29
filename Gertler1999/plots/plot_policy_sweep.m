%% plot_policy_sweep.m
%
% Plot policy sweep results in a 3 x 3 figure.
%
% Rows:
%   1. k_change
%   2. lambda_change
%   3. r_change
%
% Columns:
%   1. Government Spending
%   2. Social Security
%   3. Government Debt
%
% Data:
%   output/policy_sweep_results.csv
%
% Output:
%   plots/policy_sweep_3x3.png

clear;
clc;
close all;


%% Paths

% Current folder = plots
plots_dir = fileparts(mfilename('fullpath'));
project_dir = fileparts(plots_dir);

input_file = fullfile(project_dir, ...
    'output', 'policy_sweep_results.csv');

output_file = fullfile(plots_dir, ...
    'policy_sweep_3x3.png');


%% Read data

T = readtable(input_file);


%% Check required variables

required_vars = { ...
    'PolicyValue', ...
    'PolicyType', ...
    'k_change', ...
    'lambda_change', ...
    'r_change'};

for i = 1:length(required_vars)

    if ~ismember(required_vars{i}, T.Properties.VariableNames)
        error('Missing required column: %s', ...
            required_vars{i});
    end

end


%% Settings

policy_types = { ...
    'Government_Spending', ...
    'Social_Security', ...
    'Debt_Target'};

policy_labels = { ...
    'Government Spending', ...
    'Social Security', ...
    'Government Debt'};

variables = { ...
    'k_change', ...
    'lambda_change', ...
    'r_change'};

ylabels = { ...
    'Capital Stock ($K/N$)', ...
    'Retirees Wealth Share ($\lambda$)', ...
    'Interest Rate $(r)$'};


%% Create figure

fig = figure( ...
    'Color', 'w', ...
    'Units', 'inches', ...
    'Position', [1, 1, 10, 8]);


%% Line settings

% Same grayscale and line width as the previous figure
lineColor = [0.2, 0.2, 0.2];

% Different line styles for policy types
lineStyles = {'-', '--', ':'};


%% 3 x 3 plot

tiledlayout(3, 3, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');


for i = 1:3

    for j = 1:3

        nexttile;
        hold on;


        %% Current policy type

        policy_name = policy_types{j};

        idx = strcmp(T.PolicyType, policy_name);

        temp = T(idx, :);

        % Sort by policy value
        temp = sortrows(temp, 'PolicyValue');

        policy_value = temp.PolicyValue;
        data = temp.(variables{i});


        %% Plot

        plot( ...
            policy_value, ...
            data, ...
            'Color', lineColor, ...
            'LineStyle', lineStyles{j}, ...
            'LineWidth', 1.5);


        %% Zero reference line

        yline(0, ...
            'Color', [0.75 0.75 0.75], ...
            'LineStyle', '-', ...
            'LineWidth', 0.6);


        hold off;


        %% Axes settings

        ax = gca;

        ax.FontName = 'Times New Roman';
        ax.FontSize = 10;
        ax.LineWidth = 0.8;
        ax.Box = 'off';

        ax.XGrid = 'off';
        ax.YGrid = 'off';


        %% X-axis

        xlim([min(policy_value), max(policy_value)]);


        %% Labels

        if i == 3
            xlabel('Policy Value', ...
                'FontName', 'Times New Roman', ...
                'FontSize', 10);
        end

        if j == 1
            ylabel(ylabels{i}, ...
                'Interpreter', 'latex', ...
                'FontName', 'Times New Roman', ...
                'FontSize', 10);
        end


        %% Column titles

        if i == 1
            title(policy_labels{j}, ...
                'FontName', 'Times New Roman', ...
                'FontSize', 11, ...
                'FontWeight', 'normal');
        end

    end

end


%% Save figure

exportgraphics( ...
    fig, ...
    output_file, ...
    'Resolution', 300);

fprintf('Figure saved to:\n%s\n', output_file);