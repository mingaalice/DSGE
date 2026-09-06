%% plot_irf.m
%
% Author: Yujia Ming
% Date: Sept, 2026
%
% This file can calculate and plot IRFs for all 7 shocks.
% The output is a 7*7 grid of plots, showing the impulse responses of 7
%   variables to each of the 7 shocks.
%
% The 7 variables are output growth (dy), consumption growth (dc), investment growth (dinve), 
%   hours worked (labobs), inflation (pinfobs), wage growth (dw), and the nominal interest rate (robs).
% The 7 shocks are TFP, investment-specific technology, risk premium, exogenous spending,
%   price mark-up, wage mark-up, and monetary policy shocks.


%% 1. Run Dynare
% forecast horizon, quarterly
H = 16;

dynare('usmodel_irf.mod', 'noclearall');

%% 2. Variable names

var_names = {'Output growth rate', ...
             'Consumption growth rate', ...
             'Investment growth rate', ...
             'log Hours worked', ...
             'Inflation', ...
             'Wage growth rate', ...
             'Federal funds rate'};

var_codes = { ...
    'dy', ...
    'dc', ...
    'dinve', ...
    'labobs', ...
    'pinfobs', ...
    'dw', ...
    'robs'};

%% 3. Shock names

shock_names = { ...
    'TFP', ...
    'Risk Premium', ...
    'Spending', ...
    'Investment Technology', ...
    'Monetary Policy', ...
    'Price Markup', ...
    'Wage Markup'};

shock_codes = { ...
    'ea', ...
    'eb', ...
    'eg', ...
    'eqs', ...
    'em', ...
    'epinf', ...
    'ew'};

%% 4. Plot 7 * 7 IRFs

figure('Color','w', ...
       'Position',[100 100 1600 1200]);

tiledlayout(7,7, ...
    'TileSpacing','compact', ...
    'Padding','compact');

for i = 1:7
    
    for j = 1:7
        
        nexttile;
        
        % IRF field name
        field_name = [var_codes{i} '_' shock_codes{j}];

        irf = oo_.irfs.(field_name); % get IRF
        plot(1:H, irf(1:H), ...
            'LineWidth',1.0, ...
            'Color',[0.85 0.40 0.20]); % plot
        
        hold on;
        
        % Zero line
        yline(0,'k-','LineWidth',0.5);
        
        box on;
        
        % Axis settings
        
        xlim([1 H]);
        
        set(gca, ...
            'FontSize',7, ...
            'LineWidth',0.7);

        % Column titles
        
        if i == 1
            title(shock_names{j}, ...
                'FontSize',9, ...
                'FontWeight','bold');
        end
        
        % Row labels
        
        if j == 1
            ylabel(var_names{i}, ...
                'FontSize',8);
        end
        
        % X-axis
        
        if i < 7
            set(gca,'XTickLabel',[]);
        else
            xlabel('Quarter','FontSize',8);
        end
        
        % Hide unnecessary y-axis labels
        
        if j > 1
            set(gca,'YTickLabel',[]);
        end
        
    end
    
end

%% 5. Save figure

exportgraphics(gcf, ...
    'IRF_all_shocks_7x7.png', ...
    'Resolution',300);

disp('IRF calculation and plotting completed.');






