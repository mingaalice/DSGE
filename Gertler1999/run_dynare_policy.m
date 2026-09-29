function run_dynare_policy(modfile,parameter,value,state,name)
%
% Run one fiscal policy transition experiment
%
% modfile:
%   gertler_policy_g
%   gertler_policy_e
%   gertler_policy_b
%
% parameter:
%   gbar / ebar / bbar
%
% value:
%   counterfactual value
%
% state:
%   2014 initial condition
%
% name:
%   output name



% Copy mod file
tempfile='temp_policy.mod';
copyfile([modfile '.mod'], tempfile);

fid=fopen(tempfile,'a');

% counterfactual policy parameter
fprintf(fid,'\n\n%s = %.15f;\n', parameter, value);


fprintf(fid,'\n\ninitval;\n');
% initial guess
fprintf(fid,'k=2.160433;\n');
fprintf(fid,'lambda=0.207747;\n');
fprintf(fid,'pi=0.088045;\n');
fprintf(fid,'eps=1.835822;\n');
fprintf(fid,'Omega=1.028700;\n');
fprintf(fid,'h=3.794100;\n');
fprintf(fid,'c=0.774500;\n');
fprintf(fid,'r=1.099200;\n');
fprintf(fid,'s=0.373400;\n');
fprintf(fid,'sw=0.529000;\n');
fprintf(fid,'a=2.935900;\n');
fprintf(fid,'tau=0.378900;\n');
fprintf(fid,'y=1.292400;\n');
fprintf(fid,'b=0.775400;\n');

fprintf(fid,'end;\n');

% Solve counterfactual steady state
fprintf(fid,'\nsteady(solve_algo=4,maxit=1000);\n');

fclose(fid);

evalin('base', ...
    sprintf('dynare(''%s'',''noclearall'');', tempfile(1:end-4)));


% Get counterfactual steady state
cf_steady_state = evalin('base','oo_.steady_state');
cf_endo_names = evalin('base','cellstr(M_.endo_names)');

% Save counterfactual steady state
save(sprintf('steady_%s.mat',name), ...
     'cf_steady_state', ...
     'cf_endo_names');


% Recreate temporary mod file for transition
delete(tempfile);
copyfile([modfile '.mod'], tempfile);
fid = fopen(tempfile,'a');
fprintf(fid,'\n\n%s = %.15f;\n', parameter, value);

% Initial guess
fprintf(fid,'\ninitval;\n');

fprintf(fid,'k = %.15f;\n', state.k0);
fprintf(fid,'lambda = %.15f;\n', state.lambda0);

for i = 1:length(cf_endo_names)

    varname = strtrim(cf_endo_names{i});

    if ~ismember(varname, {'k','lambda'})

        value_ss = cf_steady_state(i);

        fprintf(fid,'%s = %.15f;\n', ...
            varname, value_ss);

    end
end

fprintf(fid,'end;\n');


% Terminal condition
fprintf(fid,'\nendval;\n');

for i = 1:length(cf_endo_names)

    varname = strtrim(cf_endo_names{i});
    value_ss = cf_steady_state(i);

    fprintf(fid,'%s = %.15f;\n',varname,value_ss);

end

fprintf(fid,'end;\n');


% Transition
fprintf(fid,'\nperfect_foresight_setup(periods=100);\n');
fprintf(fid,'perfect_foresight_solver;\n');


% Save
fprintf(fid,'\nsave temp_%s.mat oo_ M_;\n',name);
fclose(fid);

evalin('base', ...
    sprintf('dynare(''%s'',''noclearall'');', tempfile(1:end-4)));
delete(tempfile);



simul = evalin('base','oo_.endo_simul');

disp('===== k path =====');
disp(simul(strcmp(evalin('base','cellstr(M_.endo_names)'),'k'),:));

disp('===== lambda path =====');
disp(simul(strcmp(evalin('base','cellstr(M_.endo_names)'),'lambda'),:));

disp('===== r path =====');
disp(simul(strcmp(evalin('base','cellstr(M_.endo_names)'),'r'),:));




end