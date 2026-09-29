%% plot_forecast_rms.m
%
% Plot forecast RMSE by horizon.
%
% Data:
%   output/forecast_RMSE_h.csv
%
% Variables:
%   KN_growth
%   lambda_growth
%   r_growth
%
% X-axis: Forecast Horizon
% Y-axis: RMSE

clear;
clc;
close all;


%% Paths

% Current folder = plots
plots_dir = fileparts(mfilename('fullpath'));
project_dir = fileparts(plots_dir);

input_file = fullfile(project_dir, 'output', 'forecast_RMSE_h.csv');
output_file = fullfile(plots_dir, 'forecast_RMSE_h.png');


%% Read data

T = readtable(input_file);

% Check required variables
required_vars = {'Variable', 'Horizon', 'RMSE'};

for i = 1:length(required_vars)
    if ~ismember(required_vars{i}, T.Properties.VariableNames)
        error('Missing required column: %s', required_vars{i});
    end
end


%% Variables to plot

variables = {'KN_growth', 'lambda_growth', 'r_growth'};

labels = { ...
    'KN growth', ...
    'lambda growth', ...
    'r growth'};


%% Construct data matrix

horizon = unique(T.Horizon);
horizon = sort(horizon);

data = NaN(length(horizon), length(variables));

for i = 1:length(variables)

    idx = strcmp(T.Variable, variables{i});

    temp = T(idx, :);

    for j = 1:length(horizon)

        h = horizon(j);

        idx_h = temp.Horizon == h;

        if any(idx_h)
            data(j, i) = temp.RMSE(find(idx_h, 1));
        end

    end

end


%% Plot

fig = plot_line_chart( ...
    horizon, ...
    data, ...
    labels, ...
    'Forecast RMSE by Horizon', ...
    'RMSE', ...
    output_file);


%% Display

disp('Figure saved to:');
disp(output_file);