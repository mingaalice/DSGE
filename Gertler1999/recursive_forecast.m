%% recursive_forecast

clear;
clc;

% Solve steady state
disp('Solving steady state...')
copyfile('gertler_model.mod','gertler_ss.mod');

fid = fopen('gertler_ss.mod','a');

fprintf(fid,'\n\ninitval;\n');
fprintf(fid,'k=3;\n');
fprintf(fid,'lambda=0.2;\n');
fprintf(fid,'pi=0.30;\n');
fprintf(fid,'eps=0.75;\n');
fprintf(fid,'Omega=0.98;\n');
fprintf(fid,'h=1;\n');
fprintf(fid,'c=0.5;\n');
fprintf(fid,'r=1.15;\n');
fprintf(fid,'s=0.2;\n');
fprintf(fid,'sw=0.2;\n');
fprintf(fid,'a=3.5;\n');
fprintf(fid,'tau=0.20;\n');
fprintf(fid,'y=1.5;\n');
fprintf(fid,'b=0.6;\n');
fprintf(fid,'end;\n');

fprintf(fid,'\nsteady(solve_algo=4,maxit=1000);\n');

fclose(fid);

% Run Dynare
dynare gertler_ss noclearall;

% Extract steady state
steady_state = oo_.steady_state;

endo_names = cellstr(M_.endo_names);

k_ss = steady_state(strcmp(endo_names,'k'));
lambda_ss = steady_state(strcmp(endo_names,'lambda'));
b_ss = steady_state(strcmp(endo_names,'b'));
fprintf('k_ss      = %.10f\n',k_ss);
fprintf('lambda_ss = %.10f\n',lambda_ss);
fprintf('b_ss      = %.10f\n',b_ss);

% Save steady state
save('gertler_steady_state.mat', ...
     'steady_state', 'endo_names', ...
     'k_ss', 'lambda_ss', 'b_ss');
disp('Steady state obtained.')


% Load data
data = readtable('initial_states.csv');
forecast_horizon = 20;     % 20 years

start_year = 2013;
end_year   = 2024;

load('gertler_steady_state.mat');
results = struct();


% Recursive forecast
for year = start_year:end_year

    fprintf('Forecast starting from %d\n',year);

    % Current initial conditions
    k = data.k0(data.year==year);
    lambda = data.lambda0(data.year==year);

    % Create temporary mod file
    copyfile('gertler_model.mod','gertler_temp.mod');
    fid=fopen('gertler_temp.mod','a');

    fprintf(fid,'\n\ninitval;\n');
    fprintf(fid,'k=%f;\n',k);
    fprintf(fid,'lambda=%f;\n',lambda);

    for i = 1:length(endo_names)            % other variables = steady state
        varname = strtrim(endo_names{i});

        if ~ismember(varname, {'k','lambda'})
            value = steady_state(i);
            fprintf(fid,'%s = %.15f;\n', varname, value);
        end
    end

    fprintf(fid,'end;\n');

    fprintf(fid,'\nendval;\n');
    for i = 1:length(endo_names)
        varname = strtrim(endo_names{i});
        value = steady_state(i);
        fprintf(fid,'%s=%.15f;\n',varname,value);
    end
    fprintf(fid,'end;\n');

    fprintf(fid,...
        '\nperfect_foresight_setup(periods=%d);\n',...
        forecast_horizon);
    fprintf(fid,...
        'perfect_foresight_solver;\n');
    fprintf(fid,...
        'save forecast_%d.mat oo_ M_ options_;\n',...
        year);


    fclose(fid);

    % Run Dynare
    dynare gertler_temp noclearall;


    disp(M_.endo_names)
    disp(oo_.steady_state)

    endo_names = cellstr(M_.endo_names);

    idx_k = strcmp(endo_names,'k');
    idx_lambda = strcmp(endo_names,'lambda');
    idx_b = strcmp(endo_names,'b');

    k_ss = oo_.steady_state(idx_k);
    lambda_ss = oo_.steady_state(idx_lambda);
    b_ss = oo_.steady_state(idx_b);

    fprintf('k_ss      = %.10f\n', k_ss);
    fprintf('lambda_ss = %.10f\n', lambda_ss);
    fprintf('b_ss      = %.10f\n', b_ss);


    % Save results
    results(year-start_year+1).year=year;
    results(year-start_year+1).path=oo_.endo_simul;
    results(year-start_year+1).endo_names=M_.endo_names;

end


save('recursive_results.mat','results');