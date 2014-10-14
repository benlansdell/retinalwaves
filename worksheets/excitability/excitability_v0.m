%Script to vary parameters and test for excitability

%Set parameter combinations to vary
threshold = 0.1;

%1D simulation
%ic = 'bump1D'
%2D simulation
ic = 'bump'

%Vary gca, gach, and v0
v0s = [0 -10 -20 -30 -40 -50 -60];
gcas = 0:1:24;
gachs = 0:1:9;

%Test params
%v0s = [-0.2];
%gcas = [10];
%gachs = [2,1];

pts = -10*ones(length(v0s), length(gcas), length(gachs));

for i = 1:length(v0s)
	for j = 1:length(gcas)
		for k = 1:length(gachs)
			v0 = v0s(i)
			gca = gcas(j)
			gach = gachs(k)
			%Run simulation with those parameters and the right ICs
			%params = parameters('ml_sahp', ic, 0:0.1:10, 64, 'none');
			params = parameters('ml_sahp', ic, 0:0.1:10, 64, 'none');
			%Cm VCa VK VL Vsyn gCaM gKM gLM gAChM V1 V2 V3 V4 tauR tauACh D b delta k kap v0 lambda dur Vnoise alpha tauS c
			params.modelps(21) = v0; params.modelps(6) = gca; params.modelps(9) = gach;
			sol = retinal2D_split(params);
			%Plot solution
			%plotsol(sol, './worksheets/excitability/excitability_plots/testsol.gif', params);
			%Take solution and compute if wave made it to the other side of domain
			vsol = sol{1}(:,floor(params.nx/2),5);
			pts(i, j, k) = max(vsol);
		end
	end
end

thresh_pts = zeros(length(v0s), length(gcas), length(gachs));
for i = 1:length(v0s)
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

for i = 1:length(v0s)
	%pcolor(permute(pts(i,:,:), [2,3,1]));
	caxis([0 1])
	xlabel('G_ca')
	ylabel('G_ach')
	saveplot(gcf, ['./worksheets/excitability/excitability_plots/threshold_delta_' num2str(v0s(i)) '.eps']);
end

save(['./worksheets/excitability/excitability_thresholds_v0_' ic '.mat'], 'thresh_pts');
