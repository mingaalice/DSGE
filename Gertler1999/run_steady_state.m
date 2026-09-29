function result = run_steady_state(modfile,gbar,ebar,bbar)
% Compute steady state under fiscal parameters
%
% modfile:
% gertler_policy_g/e/b
%
% gbar, ebar, bbar:
% fiscal parameters
%
% state:
% real data from initial_states.csv


tempfile='temp_ss.mod';
copyfile([modfile '.mod'],tempfile);
fid=fopen(tempfile,'a');

% Initial
fprintf(fid,'\n\ninitval;\n');

fprintf(fid,'k = 2.1604329969;\n');
fprintf(fid,'lambda = 0.2077472918;\n');
fprintf(fid,'pi = 0.0880453;\n');
fprintf(fid,'eps = 1.83582;\n');
fprintf(fid,'Omega = 1.0287;\n');
fprintf(fid,'h = 3.79413;\n');
fprintf(fid,'c = 0.774464;\n');
fprintf(fid,'r = 1.09921;\n');
fprintf(fid,'s = 0.373443;\n');
fprintf(fid,'sw = 0.528991;\n');
fprintf(fid,'a = 2.93588;\n');
fprintf(fid,'tau = 0.378911;\n');
fprintf(fid,'y = 1.29242;\n');
fprintf(fid,'b = 0.775449;\n');

fprintf(fid,'end;\n');


% Fiscal parameters
fprintf(fid,'\ngbar=%f;\n',gbar);
fprintf(fid,'ebar=%f;\n',ebar);
fprintf(fid,'bbar=%f;\n',bbar);


% Solve steady state
fprintf(fid,'\nsteady(solve_algo=4,maxit=1000);\n');
fprintf(fid,'\nsave temp_ss_result.mat oo_ M_;\n');
fclose(fid);

% Run Dynare
dynare temp_ss noclearall;
load('temp_ss_result.mat');
names=cellstr(M_.endo_names);

idx_k=find(strcmp(names,'k'));
idx_lambda=find(strcmp(names,'lambda'));
idx_r=find(strcmp(names,'r'));

result.k=oo_.steady_state(idx_k);
result.lambda=oo_.steady_state(idx_lambda);
result.r=oo_.steady_state(idx_r);

delete(tempfile);
delete('temp_ss_result.mat');

end