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
fprintf(fid,'\n\ninitval;\n');
% observed 2014 state
fprintf(fid,'k=%f;\n',state.k0);
fprintf(fid,'lambda=%f;\n',state.lambda0);
fprintf(fid,'b=%f;\n',state.b0);
% policy parameter
fprintf(fid,'%s=%f;\n',parameter,value);
fprintf(fid,'end;\n');


% Solve initial steady state
fprintf(fid,'\nsteady(solve_algo=4,maxit=1000);\n');


% Terminal steady state
fprintf(fid,'\nendval;\n');
fprintf(fid,'%s=%f;\n',parameter,value);
fprintf(fid,'end;\n');
fprintf(fid,'\nsteady(solve_algo=4,maxit=1000);\n');


% Transition
fprintf(fid,'\nperfect_foresight_setup(periods=40);\n');
fprintf(fid,'perfect_foresight_solver;\n');


% Save
fprintf(fid,'\nsave temp_%s.mat oo_ M_;\n',name);
fclose(fid);


dynare(tempfile(1:end-4),'noclearall');
delete(tempfile);

end