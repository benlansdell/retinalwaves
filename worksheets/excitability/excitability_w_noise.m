%Script to vary parameters and test for excitability. Run simulations with noise and check to see which parameters
%produce waves of a sufficiently large size -- these are regions in which we call the domain excitable

%Vary gca, gach, and delta
deltas = [800, 100, 50, 25, 15, 10];
gcas = 0:1:24;
gachs = 0:1:9;

%Test params
%deltas = [800];
%gcas = [10];
%gachs = [2,1];

V0 = -20;

%Threshold on area above which the medium is called excitable
threshold = 1.5;
tspn = 0:1:500;
maxsizes = zeros(length(deltas), length(gcas), length(gachs));

sizes = {};
durs = {};
spds = {};
waveiwis = {};
%Run a solution for 1000s w noise, then use it as initial condition for subsequent simulations
params = parameters('ml_sahp', 'homog', 0:1:750, 64, 'bernoulli');
%Change diffision coeff
D = 0.0075;
params.diffusion_coeff = D;
params.modelps(16) = D;
sol = retinal2D_split(params);
savesol(sol, params, './excitability_w_noise_tmp.mat');

for i = 1:length(deltas)
	for j = 1:length(gcas)
		for k = 1:length(gachs)
			delta = deltas(i)
			gca = gcas(j)
			gach = gachs(k)
			%Run simulation with those parameters and the right ICs
			params = parameters('./excitability_w_noise_tmp.mat');
			%Change time of simulation
			params.tspan = tspn;
			%Change params
			params.modelps(21) = V0;
			params.modelps(18) = delta; params.modelps(6) = gca; params.modelps(9) = gach;
			%Re-run simulation
			sol = retinal2D_split(params);
			%Find wave stats
			counts = wavecounts(sol, params);
                        [strpts, endpts, wavesizes, wavedurs, wavespds, iwis, collidedspds, maxspds, maxcollidedspds] = wavedata(counts, params);
			%Record wave stats
			maxsizes(i,j,k) = max(wavesizes);
			sizes{i,j,k} = wavesizes;
			durs{i,j,k} = wavedurs;
			spds{i,j,k} = wavesizes;
			waveiwis{i,j,k} = iwis;
		end
	end
end

thresh_pts = zeros(length(deltas), length(gcas), length(gachs));
for i = 1:length(deltas)
	for j=1:length(gcas)
		for k=1:length(gachs)
			if maxsizes(i,j,k) > threshold
				thresh_pts(i,j,k) = 1;
			end
		end
	end
end

save(['./worksheets/excitability/excitability_thresholds_noise.mat'], 'thresh_pts', 'maxsizes', 'sizes', 'durs', 'waveiwis', 'deltas', 'gcas', 'gachs');
