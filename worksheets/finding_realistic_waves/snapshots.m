%Script to make snapshots of solution
%Plot solution at t = 1, 2, 3
%params = parameters('ml_sahp', 'homog', [0:1:500], 64, 'bernoulli');
%sol = retinal2D_split(params);
%savesol(sol, params, './worksheets/finding_realistic_waves/tmp3.mat');
params = parameters('./worksheets/finding_realistic_waves/tmp3.mat');
params.tspan = 0:0.1:50;
params.nx = 64;
sol = retinal2D_split(params);
%Truncate solution size

params.nx = 32;
sols{1} = sol{1}(:,33:64,1:32);
sols{2} = sol{2}(:,33:64,1:32);
sols{3} = sol{3}(:,33:64,1:32);
sols{4} = sol{4}(:,33:64,1:32);
plotsnapshots_tiled(sols, './worksheets/finding_realistic_waves/bernoulli_snapshot.eps', params, [10 11 12 13 14 15], {[-90 30],[0 0.3],[0 1]}, {1,3,4}, 0);
plotsnapshots_tiled(sols, './worksheets/finding_realistic_waves/bernoulli_snapshot_tight.eps', params, [10 11 12 13 14 15], {[-90 30],[0 0.3],[0 1]}, {1,3,4}, 1);

%Plot profiles too
plotprofile(sol, './worksheets/finding_realistic_waves/bernoulli_snapshot_profile.eps', params, [0.5 0.51 0.49], [0.5 0.51 0.49]);


%Run for a longer time and collect correlation information
