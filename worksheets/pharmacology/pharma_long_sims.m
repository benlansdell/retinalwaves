function pharma_long_sims(parts)
%Script to run simulations for a combined time of 2500s under different sets of parameters
	tlim = 500;
	if any(parts == 1)
		params = parameters('ml_sahp', 'homog', [0:0.1:tlim], 64, 'bernoulli');
		%[Cm VCa VK VL Vsyn gCaM gKM gLM gAChM V1 V2 V3 V4 tauR tauACh D b delta k kap v0 lambda dur Vnoise alpha tauS c];
                %Change D (diffusion, param 16, default 0.01) to 0.0075
                params.modelps(16) = 0.075;
                params.diffusion_coeff = 0.0075;
        	%Vary g_ach (param 9, default 2)
        	%params.modelps(9) = 1;
       		%runlongsim(params, 'pharma_long_sim_gach_1', 5, 1, 'split', 0, 1);
        	%params.modelps(9) = 4;
        	%runlongsim(params, 'pharma_long_sim_gach_4', 5, 1, 'split', 0, 1);
		%params.modelps(9) = 2;
		%Vary tau_ach (param 15, default 0.2)
                params.modelps(15) = 0.1;
                runlongsim(params, 'pharma_long_sim_tauach_0_1', 5, 1, 'split', 0, 1);
                params.modelps(15) = 0.4;
                runlongsim(params, 'pharma_long_sim_tauach_0_4', 5, 1, 'split', 0, 1);
		params.modelps(15) = 0.2;
		%Vary tau_sahp (param 26, default 60)
                params.modelps(26) = 40;
                runlongsim(params, 'pharma_long_sim_tausahp_40', 5, 1, 'split', 0, 1);
                params.modelps(26) = 20;
                runlongsim(params, 'pharma_long_sim_tausahp_20', 5, 1, 'split', 0, 1);
	end
	if any(parts == 2)
		params = parameters('ml_sahp', 'homog', [0:0.1:tlim], 64, 'bernoulli');
                %Change D (diffusion, param 16, default 0.01) to 0.0075
                params.modelps(16) = 0.0075;
                params.diffusion_coeff = 0.0075;
		runlongsim(params, 'pharma_long_sim_default', 5, 1, 'split', 0, 1);
	end
	%Compute statistics
	if any(parts == 3)
		%Load previously simulation
		compute_stats('./simdata/pharma_long_sim_gach_1.mat', './simdata/pharma_long_sim_gach_1_stats.mat');
		compute_stats('./simdata/pharma_long_sim_gach_4.mat', './simdata/pharma_long_sim_gach_4_stats.mat');
		compute_stats('./simdata/pharma_long_sim_tauach_0_1.mat', './simdata/pharma_long_sim_tauach_0_1_stats.mat');
		compute_stats('./simdata/pharma_long_sim_tauach_0_4.mat', './simdata/pharma_long_sim_tauach_0_4_stats.mat');
		compute_stats('./simdata/pharma_long_sim_tausahp_40.mat', './simdata/pharma_long_sim_tausahp_40_stats.mat');
		compute_stats('./simdata/pharma_long_sim_tausahp_20.mat', './simdata/pharma_long_sim_tausahp_20_stats.mat');
		compute_stats('./simdata/pharma_long_sim_default.mat', './simdata/pharma_long_sim_default_stats.mat');
	end
	%Finally plot all the stats!
	if any(parts == 4)
                plotstats('./simdata/pharma_long_sim_gach_1_stats.mat', './worksheets/pharmacology/pharma_long_sims_plots/gach_1');
                plotstats('./simdata/pharma_long_sim_gach_4_stats.mat', './worksheets/pharmacology/pharma_long_sims_plots/gach_4');
                plotstats('./simdata/pharma_long_sim_tauach_0_1_stats.mat', './worksheets/pharmacology/pharma_long_sims_plots/tauach_0_1');
                plotstats('./simdata/pharma_long_sim_tauach_0_4_stats.mat', './worksheets/pharmacology/pharma_long_sims_plots/tauach_0_4');
                plotstats('./simdata/pharma_long_sim_tausahp_40_stats.mat', './worksheets/pharmacology/pharma_long_sims_plots/tahsahp_40');
                plotstats('./simdata/pharma_long_sim_tausahp_20_stats.mat', './worksheets/pharmacology/pharma_long_sims_plots/tausahp_20');
                plotstats('./simdata/pharma_long_sim_default_stats.mat', './worksheets/pharmacology/pharma_long_sims_plots/default');
	end
end
