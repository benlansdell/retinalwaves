function bernoulli_long_sim_128s(parts)
%Script to run simulations for a combined time of 2500s under different sets of parameters
	tlim = 500;
	if any(parts == 1)
		params = parameters('ml_sahp', 'homog', [0:0.1:tlim], 128, 'bernoulli');
        	%Vary D
        	params.modelps(16) = 0.0075;
		params.diffusion_coeff = 0.0075;
       		runlongsim(params, 'bernoulli_long_sim_128_D_0_0075', 5, 1, 'split', 0, 1);
        	params.modelps(16) = 0.005;
		params.diffusion_coeff = 0.005;
        	runlongsim(params, 'bernoulli_long_sim_128_D_0_005', 5, 1, 'split', 0, 1);
	end
	if any(parts == 2)
		params = parameters('ml_sahp', 'homog', [0:0.1:tlim], 128, 'bernoulli');
		runlongsim(params, 'bernoulli_long_sim_128_default', 5, 1, 'split', 0, 1);
	end
	%Compute statistics
	if any(parts == 3)
		%Load previously simulation
		compute_stats('./simdata/bernoulli_long_sim_128_D_0_005.mat', './simdata/bernoulli_long_sim_128_D_0_005_stats.mat');
		compute_stats('./simdata/bernoulli_long_sim_128_D_0_0075.mat', './simdata/bernoulli_long_sim_128_D_0_0075_stats.mat');
		compute_stats('./simdata/bernoulli_long_sim_128_default.mat', './simdata/bernoulli_long_sim_128_default_stats.mat');
	end
	%Finally plot all the stats!
	if any(parts == 4)
                plotstats('./simdata/bernoulli_long_sim_128_D_0_005_stats.mat', './worksheets/finding_realistic_waves/bernoulli_long_sim_128s_plots/bernoulli_long_sim_128_D_0_005');
                plotstats('./simdata/bernoulli_long_sim_128_D_0_0075_stats.mat', './worksheets/finding_realistic_waves/bernoulli_long_sim_128s_plots/bernoulli_long_sim_128_D_0_0075');
                plotstats('./simdata/bernoulli_long_sim_128_default_stats.mat', './worksheets/finding_realistic_waves/bernoulli_long_sim_128s_plots/bernoulli_long_sim_128_default');
	end
end
