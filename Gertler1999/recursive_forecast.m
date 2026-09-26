%% recursive_forecast

clear;
clc;

% Solve steady state
disp('Solving steady state...')
dynare gertler_model noclearall;

endo_names = cellstr(M_.endo_names);
k_ss = oo_.steady_state(strcmp(endo_names,'k'));
lambda_ss = oo_.steady_state(strcmp(endo_names,'lambda'));
b_ss = oo_.steady_state(strcmp(endo_names,'b'));

save('gertler_steady_state.mat','k_ss','lambda_ss','b_ss');
disp('Steady state obtained.')


% Load data
data = readtable('initial_states.csv');
forecast_horizon = 20;     % 20 years

start_year = 2013;
end_year   = 2025;

load('gertler_steady_state.mat');
results = struct();


% Recursive forecast
for year = start_year:end_year

    fprintf('Forecast starting from %d\n',year);

    % Current initial conditions
    k0 = data.k(data.year==year);
    b0 = data.b(data.year==year);
    lambda0 = data.lambda(data.year==year);

    % Create temporary mod file
    copyfile('gertler_model.mod','gertler_temp.mod');
    fid=fopen('gertler_temp.mod','a');

    fprintf(fid,'\n\nhistval;\n');
    fprintf(fid,'k=%f;\n',k0);
    fprintf(fid,'b=%f;\n',b0);
    fprintf(fid,'lambda=%f;\n',lambda0);
    fprintf(fid,'end;\n');

    fprintf(fid,'\nendval;\n');
    fprintf(fid,'k=%f;\n',k_ss);
    fprintf(fid,'b=%f;\n',b_ss);
    fprintf(fid,'lambda=%f;\n',lambda_ss);
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
    dynare gertler_temp noclearall nolog;

    % Save results
    results(year-start_year+1).year=year;
    results(year-start_year+1).path=oo_.endo_simul;
    results(year-start_year+1).endo_names=M_.endo_names;
    delete('gertler_temp.mod');

end


save('recursive_results.mat','results');