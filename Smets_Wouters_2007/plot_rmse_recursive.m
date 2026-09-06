%% plot_rmse_recursive.m
% 
% Author: Yujia Ming
% Date: Sept, 2026
% 
% This file calculates and plots RMSE of recursive DSGE forecasts.
% 
% Inputs:
%   - usmodel_data.mat
%   - recursive_forecast_dsge.csv (output of `recursive_forcasts.m`)
% Outputs:
%   recursive_forecasts_RMSE.png


clear;
clc;


%% 1. Load actual data

S = load('usmodel_data.mat');

% Variable names in Dynare
dynare_name = {'dy','dc','dinve','labobs','pinfobs','dw','robs'};

% Display names
var_names = {'Output growth rate', ...
             'Consumption growth rate', ...
             'Investment growth rate', ...
             'log Hours worked', ...
             'Inflation', ...
             'Wage growth rate', ...
             'Federal fund rate'};

nvar = 7;
H = 16;

% Actual data: 230 observations × 7 variables
actual = NaN(length(S.(dynare_name{1})), nvar);

for j = 1:nvar
    actual(:,j) = S.(dynare_name{j})(:);
end


%% 2. Load forecast results

T = readtable('recursive_forecast_dsge.csv');     

forecast_origin = T{:,1};
horizon         = T{:,2};


%% 3. Calculate RMSE

RMSE = NaN(H,nvar);

for h = 1:H
    
    % select all forecasts with horizon h
    idx = (horizon == h);
    origins_h = forecast_origin(idx);
    
    for j = 1:nvar
        
        % forecast values for variable j
        yforecast = T{idx,j+2};

        % remove observations outside the available actual sample
        valid = (origins_h + h <= size(actual,1));
        valid = valid & ~isnan(yforecast); % also remove NaN forecasts
        
        % actual values corresponding to t+h
        yactual = actual(origins_h(valid) + h,j);
        
        % RMSE
        error = yforecast(valid) - yactual;
        RMSE(h,j) = sqrt(mean(error.^2));
        
    end
    
end


%% 4. Display RMSE table

RMSE_table = array2table(RMSE, ...
    'VariableNames', dynare_name, ...
    'RowNames', strcat('h=',string(1:H)));

disp('RMSE by Forecast Horizon:');
disp(RMSE_table);


%% 5. Plot RMSE

figure('Color','w', ...
       'Position',[200 100 300 4200]);

tiledlayout(7,1, ...
            'TileSpacing','compact', ...
            'Padding','compact');


for j = 1:nvar
    
    nexttile;
    
    plot(1:H, RMSE(:,j), ...
         '-o', ...
         'Color',[0.85 0.40 0.20], ...
         'LineWidth',0.6, ...
         'MarkerSize',2, ...
         'MarkerFaceColor',[0.85 0.40 0.20]);
    
    box on;
    grid off;
    
    xlim([1 H]);
    
    xticks(1:H);
    
    ylabel(var_names{j}, ...
           'FontSize',12);
    
    ax = gca;
    
    ax.XAxis.FontSize = 4;
    ax.YAxis.FontSize = 5;
    
    ax.LineWidth = 0.2;
    
end


%% 6. Common x-axis label

xlabel('Forecast Horizon', ...
       'FontSize',6);


%% 7. Save figure

exportgraphics(gcf, ...
               'recursive_forecasts_RMSE.png', ...
               'Resolution',300);

fprintf('\nRMSE figure saved as:\n');
fprintf('recursive_forecasts_RMSE.png\n');