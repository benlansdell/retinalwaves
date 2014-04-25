%Script to vary parameters and estimate wave speed of resulting wave (if it exists)
%Set parameter combinations to vary
threshold = 0.1;
dt = 0.1;

%1D simulation
ic = 'bump1D'
%2D simulation
%ic = 'bump'

%Vary gca, gach, and delta
deltas = [400, 200, 100, 50, 25];
gachs = 0:1:30;

%Test params
%deltas = [400, 200, 100];
%gachs = 0:3;

speeds = zeros(length(deltas), length(gachs));

for i = 1:length(deltas)
	for j = 1:length(gachs)
		delta = deltas(i)
		gach = gachs(j)
		%Run simulation with those parameters and the right ICs
		params = parameters('ml_sahp', ic, 0:dt:10, 64, 'none');
		%Cm VCa VK VL Vsyn gCaM gKM gLM gAChM V1 V2 V3 V4 tauR tauACh D b delta k kap v0 lambda dur Vnoise alpha tauS c
		params.modelps(18) = delta; params.modelps(9) = gach;
		sol = retinal2D_split(params);
		%Plot solution
		%plotsol(sol, './worksheets/excitability/excitability_plots/testsol.gif', params);
		%Take solution and compute if wave made it to the other side of domain
		vsol1 = sol{1}(:,floor(params.nx/2),floor(params.nx/2));
		vsol2 = sol{1}(:,floor(params.nx/2),5);
		v1 = vsol1 > threshold;
		v2 = vsol2 > threshold;
		t1 = find(v1, 1);
		t2 = find(v2, 1);
		deltat = dt*(t2-t1)
		deltax = params.length/2;
		if (isempty(deltat))
			speeds(i, j) = 0; 
		else
			speeds(i, j) = deltax/deltat;
		end
	end
end
%Scale speeds to non-dimensional quantities
gkm = 30; D = 0.01; Cm = 0.16;
%scaling of space and time so that diffusion coefficient is 1
XoverT = sqrt(D*gkm/Cm)
%non-dimensionalize...
speeds = speeds/XoverT;
gachs = gachs/gkm;

%Compare to AUTO data
load('./worksheets/wavespeeds/wavespeeds_delta_gach.mat')

plot(gachs, speeds, '--', delta_400_gach, -delta_400_c, delta_200_gach, -delta_200_c, delta_100_gach, -delta_100_c, delta_50_gach, -delta_50_c, delta_25_gach, -delta_25_c)
xlabel('g_{ach}^m')
ylabel('c')
xlim([0 1])
ylim([0 2])
legend('400', '200', '100', '50', '25')
saveplot(gcf, ['./worksheets/wavespeeds/wavespeed_plots/gach_delta.eps']);

%save(['./worksheets/excitability/excitability_thresholds_' ic '.mat'], 'thresh_pts');
