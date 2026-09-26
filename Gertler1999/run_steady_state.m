function result = run_steady_state(modfile,gbar,ebar,bbar,state)
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
fprintf(fid,'k=%f;\n',state.k0);
fprintf(fid,'lambda=%f;\n',state.lambda0);
fprintf(fid,'b=%f;\n',state.b0);
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