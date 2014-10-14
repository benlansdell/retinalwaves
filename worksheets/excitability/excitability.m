%Script to vary parameters and test for excitabilityss
%Set parameter combinations to vary
threshold = 0.1;
%Vary gca, gach, and delta
V0 = -20;
deltas = [800, 100, 50, 25, 15, 10];
gcas = 0:1:24;
gachs = 0:1:9;
%deltas = [800];
%gcas = [10];
%gachs = [2,1];

pts = -10*ones(length(deltas), length(gcas), length(gachs));

for i = 1:length(deltas)
	for j = 1:length(gcas)
		for k = 1:length(gachs)
			delta = deltas(i)
			gca = gcas(j)
			gach = gachs(k)
			%Run simulation with those parameters and the right ICs
			params = parameters('ml_sahp', 'bump', 0:0.1:10, 64, 'none');
			%Cm VCa VK VL Vsyn gCaM gKM gLM gAChM V1 V2 V3 V4 tauR tauACh D b delta k kap v0 lambda dur Vnoise alpha tauS c
			params.modelps(21) = V0;
			params.modelps(18) = delta; params.modelps(6) = gca; params.modelps(9) = gach;
			sol = retinal2D_split(params);
			%Plot solution
			%plotsol(sol, './worksheets/excitability/excitability_plots/testsol.gif', params);
			%Take solution and compute if wave made it to the other side of domain
			vsol = sol{1}(:,floor(params.nx/2),5);
			pts(i, j, k) = max(vsol);
		end
	end
end

thresh_pts = zeros(length(deltas), length(gcas), length(gachs));
for i = 1:length(deltas)
	for j=1:length(gcas)
		for k=1:length(gachs)
			if pts(i,j,k) > threshold
				thresh_pts = 1;
			end
		end
	end
end
pts
%Plot parameter excitability phase portrait

for i = 1:length(deltas)
	pcolor(permute(pts(i,:,:), [2,3,1]));
	caxis([0 1])
	xlabel('G_ca')
	ylabel('G_ach')
	saveplot(gcf, ['./worksheets/excitability/excitability_plots/threshold_delta_' num2str(deltas(i)) '.eps']);
end

%At some stage:
%Compare a '1D' initial condition, vs a 2D one (circular symmetric)
%Can even do the same plots with a different solver to see if makes a difference
