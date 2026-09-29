%% plot_policy_transition.m
%
% Plot policy transition results in a 3 x 3 figure.
%
% Rows:
%   1. k_change
%   2. lambda_change
%   3. r_change
%
% Columns:
%   1. g
%   2. e
%   3. b
%
% Data:
%   output/policy_transition_results.csv
%
% Output:
%   plots/policy_transition_3x3.png

clear;
clc;
close all;


%% Paths

% Current folder = plots
plots_dir = fileparts(mfilename('fullpath'));
project_dir = fileparts(plots_dir);

input_file = fullfile(project_dir, ...
    'output', 'policy_transition_results.csv');

output_file = fullfile(plots_dir, ...
    'policy_transition_3x3.png');


%% Read data

T = readtable(input_file);


%% Check required variables

required_vars = { ...
    'year', ...
    'experiment', ...
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

experiments = {'g', 'e', 'b'};

experiment_labels = { ...
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


%% Plotting period

plot_start = 2015;
plot_end   = 2055;


%% Figure

fig = figure( ...
    'Color', 'w', ...
    'Units', 'inches', ...
    'Position', [1, 1, 10, 8]);


%% Line settings

% Same gray for all lines
lineColor = [0.2, 0.2, 0.2];

% Different line styles for different experiments
lineStyles = {'-', '--', ':'};


%% 3 x 3 plot

tiledlayout(3, 3, ...
    'TileSpacing', 'compact', ...
    'Padding', 'compact');


for i = 1:3

    for j = 1:3

        nexttile;
        hold on;


        %% Current experiment

        exp_name = experiments{j};

        idx = strcmp(T.experiment, exp_name);

        temp = T(idx, :);

        % Sort by year
        temp = sortrows(temp, 'year');

        year = temp.year;
        data = temp.(variables{i});


        %% Plot

        plot( ...
            year, ...
            data, ...
            'Color', lineColor, ...
            'LineStyle', lineStyles{j}, ...
            'LineWidth', 1.5);


        %% Zero line

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

        xlim([2015, 2115]);

        xticks([2015 2035 2055 2075 2095 2115]);


        %% Labels

        if i == 3
            xlabel('Year', ...
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
            title(experiment_labels{j}, ...
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