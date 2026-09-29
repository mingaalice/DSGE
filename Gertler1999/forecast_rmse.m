%% forecast_rmse.m
% RMSE evaluation using growth rates

clear;
clc;


% Load forecast results & real growth rates
load('recursive_results.mat');
real = readtable('real_value.csv');

x = 0.01;     % labor-augmenting technology growth
variables = {'KN_growth','lambda_growth','r_growth'};
n_origin = length(results);
max_horizon = 5;
RMSE = struct();


% Calculate RMSE by forecast horizon
for v = 1:length(variables)

    varname = variables{v};
    horizon_errors = cell(max_horizon,1);

    for i = 1:n_origin

        origin_year = results(i).year;
        endo_names = cellstr(results(i).endo_names);
        
        % Convert forecast to growth
        switch varname

            case 'KN_growth'
                idx = find(strcmp(endo_names,'k'));
                path = results(i).path(idx,:);
                forecast = log(path(2:end))-log(path(1:end-1))+x;

            case 'lambda_growth'
                idx = find(strcmp(endo_names,'lambda'));
                path = results(i).path(idx,:);
                forecast = log(path(2:end))-log(path(1:end-1));

            case 'r_growth'
                idx = find(strcmp(endo_names,'r'));
                path = results(i).path(idx,:);
                forecast = log(path(2:end))-log(path(1:end-1));

        end

        % Match each horizon
        for h = 1:max_horizon

            target_year = origin_year+h;
            forecast_value = forecast(h);

            % actual value
            actual_value = real.(varname)(real.year==target_year);

            % if actual exists
            if ~isempty(actual_value)
                error = forecast_value-actual_value;
                horizon_errors{h} = [horizon_errors{h}; error];
            end

        end

    end


    % Compute RMSE_h
    rmse_vector = nan(max_horizon,1);
    for h = 1:max_horizon

        e = horizon_errors{h};
        if isempty(e)
            rmse_vector(h)=NaN;
        else
            rmse_vector(h)=sqrt(mean(e.^2));
        end

    end
    RMSE_h.(varname)=rmse_vector;

end


% Save RMSE results to CSV
output = table();
for v = 1:length(variables)

    varname = variables{v};
    temp = table(...
        repmat({varname},max_horizon,1),...
        (1:max_horizon)',...
        RMSE_h.(varname),...
        'VariableNames',...
        {'Variable','Horizon','RMSE'});
    output = [output; temp];

end

% Save CSV into output folder
output_file = fullfile('output','forecast_RMSE_h.csv');
writetable(output,output_file);

disp(['RMSE results saved to: ' output_file]);