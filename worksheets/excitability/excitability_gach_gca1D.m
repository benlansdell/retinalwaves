%Script to vary parameters and test for excitability with a 1D spatial initial condition
%Set parameter combinations to vary
threshold = 0.1;
%Vary gca, gach, and delta
V0 = -20;
%deltas = [800, 100, 50, 25, 15, 10];
%epsilon is scale factor of refractory time scales...
epsilons = [1, 10, 100];
gcas = 0:1:24;
gachs = 0:1:9;
%deltas = [800];
%gcas = [10];
%gachs = [2,1];

pts = -10*ones(length(epsilons), length(gcas), length(gachs));

for i = 1:length(epsilons)
	for j = 1:length(gcas)
		for k = 1:length(gachs)
			eps = epsilons(i)
			gca = gcas(j)
			gach = gachs(k)
			%Run simulation with those parameters and the right ICs
			params = parameters('ml_sahp', 'bump1D', 0:0.1:10, 64, 'none');
			taur = params.modelps(14);
			taus = params.modelps(26);
			%Cm VCa VK VL Vsyn gCaM gKM gLM gAChM V1 V2 V3 V4 tauR tauACh D b delta k kap v0 lambda dur Vnoise alpha tauS c
			params.modelps(21) = V0;
			params.modelps(6) = gca; params.modelps(9) = gach;
			params.modelps(14) = taur*eps; params.modelps(26) = taus*eps;
			sol = retinal2D_split(params);
			%Plot solution
			%plotsol(sol, './worksheets/excitability/excitability_plots/testsol.gif', params);
			%Take solution and compute if wave made it to the other side of domain
			vsol = sol{1}(:,floor(params.nx/2),5);
			pts(i, j, k) = max(vsol);
		end
	end
end

thresh_pts = zeros(length(epsilons), length(gcas), length(gachs));
for i = 1:length(epsilons)
	for j=1:length(gcas)
		for k=1:length(gachs)
			if pts(i,j,k) > threshold
				thresh_pts(i,j,k) = 1;
			end
		end
	end
end
pts
%Plot parameter excitability phase portrait
save('./worksheets/excitability/excitability_thresholds_gachs_gcas_bump1D.mat');
for i = 1:length(epsilons)
	pcolor(permute(pts(i,:,:), [2,3,1]));
	caxis([0 1])
	xlabel('G_ca')
	ylabel('G_ach')
	saveplot(gcf, ['./worksheets/excitability/excitability_plots/threshold1D_epsilon_' num2str(epsilons(i)) '.eps']);
end
