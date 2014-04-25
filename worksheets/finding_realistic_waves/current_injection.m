%tmax = 500;
%params = parameters('ml_sahp', 'homog', [0:0.1:tmax], 10, 'none', 1);
%sol = retinal2D_split(params);
%savesol(sol, params, './worksheets/finding_realistic_waves/tmp.mat');

%
params = parameters('./worksheets/finding_realistic_waves/tmp.mat');
tspan = 0:0.1:100;
params.tspan = tspan;
rng default;
params.I_applied = 100;
sol_100 = retinal2D_split(params);

params.I_applied = 150;
sol_150 = retinal2D_split(params);

params.I_applied = 50;
sol_50 = retinal2D_split(params);

params.I_applied = 200;
sol_200 = retinal2D_split(params);

fn = './worksheets/finding_realistic_waves/current_injection.eps';
plotprofile_multi({sol_50, sol_100, sol_150, sol_200}, fn, params);

%Make a shorter version of each solution and plot that...
for j = 1:4
	sol_50{j} = sol_50{j}(1:41,:,:);
end
for j = 1:4
	sol_150{j} = sol_150{j}(1:41,:,:);
end
for j = 1:4
	sol_100{j} = sol_100{j}(1:41,:,:);
end
for j = 1:4
	sol_200{j} = sol_200{j}(1:41,:,:);
end

fn = './worksheets/finding_realistic_waves/current_injection_short.eps';
params.tspan = 0:0.1:4;
plotprofile_multi({sol_50, sol_100, sol_150, sol_200}, fn, params);
