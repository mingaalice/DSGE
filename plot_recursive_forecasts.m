%% plot_recursive_forecasts.m
% 
% Author: Yujia Ming
% Date: Sept, 2026
% 
% This file is to plot recursive forecasts for Smets & Wouters (2007)
% DSGE model.
% 
% Inputs:
%   recursive_forecast_dsge.csv
% Outputs:
%   recursive_forecasts_main.png: output growth, inflation, nominal fed
%                                 interest rate
%   recursive_forecasts_other.png: consumption growth, investment growth,
%                                 hours worked, wage growth


clear;
clc;


%% 1. Load Data

% Load recursive forecast results
rec_forecast = 'recursive_forecast_dsge.csv';
T = readtable(rec_forecast);
forecast_origin = T.forecast_origin;
horizon = T.horizon;

% variable names
var_names = { ...
    'Output growth rate', ...
    'Consumption growth rate', ...
    'Investment growth rate', ...
    'log Hours worked', ...
    'Inflation', ...
    'Wage growth rate', ...
    'Federal funds rate'};
nvar = 7;

% Load actual SW2007 data
S = load('usmodel_data.mat');
disp('Variables contained in usmodel_data.mat:'); % Check what variables are contained in the .mat file
disp(fieldnames(S));

actual = NaN(length(S.dy),nvar);

for j = 1:nvar
    
    % variable name used in SW2007
    dynare_name = { ...
        'dy', ...
        'dc', ...
        'dinve', ...
        'labobs', ...
        'pinfobs', ...
        'dw', ...
        'robs'};
    
    name = dynare_name{j};
    
    if isfield(S,name)
        actual(:,j) = S.(name)(:);
    else
        error(['Cannot find variable "', name, ...
               '" in usmodel_data.mat.']);
    end
    
end


%% 2. Construct quarterly time index

% observation 1 = 1947 Q1
start_year = 1947;
start_quarter = 1;

n_actual = size(actual,1);

% decimal quarterly time
actual_time = start_year + ...
              ((0:n_actual-1)' + (start_quarter-1))/4;


%% 3. Figure 1: dy, pinfobs, robs

% 3.1 Figure settings

figure('Color','w', ...
       'Position',[200 100 400 1800]); % [left bottom width height]

tiledlayout(3,1, ...
            'TileSpacing','compact', ...
            'Padding','compact');


% 3.2 Plot each variable

vars1 = [1 5 7];

for k = 1:length(vars1)

    j = vars1(k);

    nexttile;
    hold on;

    % actual data
    plot(actual_time, actual(:,j), ...
         'k-', ...
         'LineWidth',0.35);

    % SW2007 forecasts
    origins = unique(forecast_origin);

    for i = 1:length(origins)

        origin = origins(i);

        idx = forecast_origin == origin;

        h = horizon(idx);

        yforecast = T{idx, j+2};

        % convert observation number to calendar time
        forecast_time = start_year + ((origin + h - 1) + (start_quarter-1))/4;

        % actual value at the forecast origin
        origin_time = start_year + ... 
        ((origin - 1) + ... 
         (start_quarter-1))/4;

        origin_value = actual(origin,j);

        plot([origin_time; forecast_time], ... 
            [origin_value; yforecast], ... 
            '-', ... 
            'Color',[0.85 0.40 0.20], ... 
            'LineWidth',0.15);
    
        plot(origin_time, ... 
            origin_value, ... 
            'o', ... 
            'Color',[0.85 0.40 0.20], ... 
            'MarkerFaceColor',[0.85 0.40 0.20], ... 
            'MarkerSize',2);

    end

    grid off;
    box on;

    % x-axis
    xlim([actual_time(1), ...
          max(start_year + ...
          ((forecast_origin + horizon - 1) + ...
          (start_quarter-1))/4)]);

    % display years rather than decimal quarters
    ax = gca;

    ax.XTick = ceil(actual_time(1)):2: ...
               floor(max(start_year + ...
               ((forecast_origin + horizon - 1) + ...
               (start_quarter-1))/4));

    ax.XTickLabel = string(ax.XTick);

    % Y-axis label
    ylabel(var_names{j}, ...
           'FontSize',12);

    % tick labels
    set(gca, ...
        'FontSize',6, ...
        'LineWidth',0.2);

    hold off;

end


% 3.3 Add common legend

ax_legend = axes('Position',[0 0 1 1], ...
                 'Visible','off');

hold(ax_legend,'on');

h1 = plot(ax_legend,NaN,NaN, ...
          'k-', ...
          'LineWidth',0.35);

h2 = plot(ax_legend,NaN,NaN, ...
          '-', ...
          'Color',[0.85 0.40 0.20], ...
          'LineWidth',0.15);

legend(ax_legend, ...
       [h1 h2], ...
       {'Actual Data','SW2007 Forecasts'}, ...
       'Location','southoutside', ...
       'Orientation','horizontal', ...
       'Box','off', ...
       'FontSize',6);


% 3.4 Save Figure 1

exportgraphics(gcf, ...
               'recursive_forecasts_main.png', ...
               'Resolution',300);

fprintf('\nFigure 1 saved as:\n');
fprintf('recursive_forecasts_main.png\n');


%% 4. Figure 2: dc, dinve, labobs, dw

figure('Color','w', ...
       'Position',[200 100 400 2200]);

tiledlayout(4,1, ...
            'TileSpacing','compact', ...
            'Padding','compact');

% Variables to plot
vars2 = [2 3 4 6];

for k = 1:length(vars2)

    j = vars2(k);

    nexttile;

    hold on;

    % Actual data
    plot(actual_time, actual(:,j), ...
         'k-', ...
         'LineWidth',0.35);

    % DSGE forecasts: time = forecast_origin + h
    origins = unique(forecast_origin);

    for i = 1:length(origins)

        origin = origins(i);

        idx = forecast_origin == origin;

        h = horizon(idx);

        yforecast = T{idx, j+2};

        % Convert observation number to calendar time
        forecast_time = start_year + ...
            ((origin + h - 1) + ...
             (start_quarter-1))/4;

        % actual value at the forecast origin
        origin_time = start_year + ... 
        ((origin - 1) + ... 
         (start_quarter-1))/4;

        origin_value = actual(origin,j);

        plot([origin_time; forecast_time], ... 
            [origin_value; yforecast], ... 
            '-', ... 
            'Color',[0.85 0.40 0.20], ... 
            'LineWidth',0.15);
    
        plot(origin_time, ... 
            origin_value, ... 
            'o', ... 
            'Color',[0.85 0.40 0.20], ... 
            'MarkerFaceColor',[0.85 0.40 0.20], ... 
            'MarkerSize',2);

    end

    % axes
    grid off;
    box on;

    % x-axis
    xlim([actual_time(1), ...
          max(start_year + ...
          ((forecast_origin + horizon - 1) + ...
          (start_quarter-1))/4)]);

    % display years rather than decimal quarters
    ax = gca;

    ax.XTick = ceil(actual_time(1)):2: ...
               floor(max(start_year + ...
               ((forecast_origin + horizon - 1) + ...
               (start_quarter-1))/4));

    ax.XTickLabel = string(ax.XTick);

    % Y-axis label
    ylabel(var_names{j}, ...
           'FontSize',12);

    % tick labels
    set(gca, ...
        'FontSize',6, ...
        'LineWidth',0.2);

    hold off;

end


% Add common legend

ax_legend = axes('Position',[0 0 1 1], ...
                 'Visible','off');

hold(ax_legend,'on');

h1 = plot(ax_legend,NaN,NaN, ...
          'k-', ...
          'LineWidth',0.35);

h2 = plot(ax_legend,NaN,NaN, ...
          '-', ...
          'Color',[0.85 0.40 0.20], ...
          'LineWidth',0.15);

legend(ax_legend, ...
       [h1 h2], ...
       {'Actual Data','SW2007 Forecasts'}, ...
       'Location','southoutside', ...
       'Orientation','horizontal', ...
       'Box','off', ...
       'FontSize',6);


% Save Figure 2

exportgraphics(gcf, ...
               'recursive_forecasts_other.png', ...
               'Resolution',300);

fprintf('\nFigure 2 saved as:\n');
fprintf('recursive_forecasts_other.png\n');








