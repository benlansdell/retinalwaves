function pharma_long_sims(parts)
%Script to run simulations for a combined time of 2500s under different sets of parameters
	tlim = 500;
	if any(parts == 1)
		params = parameters('ml_sahp', 'homog', [0:0.1:tlim], 64, 'bernoulli');
		%[Cm VCa VK VL Vsyn gCaM gKM gLM gAChM V1 V2 V3 V4 tauR tauACh D b delta k kap v0 lambda dur Vnoise alpha tauS c];
                %Change D (diffusion, param 16, default 0.01) to 0.0075
        	%Vary g_ach (param 9, default 2)
        	%params.modelps(9) = 1.5;
       		%runlongsim(params, 'pharma_long_sim_D_0_01_gach_1_5', 5, 1, 'split', 0, 1);
        	%params.modelps(9) = 2.66;
        	%runlongsim(params, 'pharma_long_sim_D_0_01_gach_2_66', 5, 1, 'split', 0, 1);
		%params.modelps(9) = 2;
		%Vary tau_ach (param 15, default 0.2)
                params.modelps(15) = 0.15;
                runlongsim(params, 'pharma_long_sim_D_0_01_tauach_0_15', 5, 1, 'split', 0, 1);
                params.modelps(15) = 0.266;
                runlongsim(params, 'pharma_long_sim_D_0_01_tauach_0_266', 5, 1, 'split', 0, 1);
		params.modelps(15) = 0.2;
		%Vary tau_sahp (param 26, default 60)
                params.modelps(26) = 50;
                runlongsim(params, 'pharma_long_sim_D_0_01_tausahp_50', 5, 1, 'split', 0, 1);
                params.modelps(26) = 70;
                runlongsim(params, 'pharma_long_sim_D_0_01_tausahp_70', 5, 1, 'split', 0, 1);
	end
	if any(parts == 2)
		params = parameters('ml_sahp', 'homog', [0:0.1:tlim], 64, 'bernoulli');
		runlongsim(params, 'pharma_long_sim_D_0_01', 5, 1, 'split', 0, 1);
	end
	%Compute statistics
	if any(parts == 3)
		%Load previously simulation
		compute_stats('./simdata/pharma_long_sim_D_0_01_gach_1_5.mat', './simdata/pharma_long_sim_D_0_01_gach_1_5_stats.mat');
		compute_stats('./simdata/pharma_long_sim_D_0_01_gach_2_66.mat', './simdata/pharma_long_sim_D_0_01_gach_2_66_stats.mat');
		compute_stats('./simdata/pharma_long_sim_D_0_01_tauach_0_15.mat', './simdata/pharma_long_sim_D_0_01_tauach_0_15_stats.mat');
		compute_stats('./simdata/pharma_long_sim_D_0_01_tauach_0_266.mat', './simdata/pharma_long_sim_D_0_01_tauach_0_266_stats.mat');
		compute_stats('./simdata/pharma_long_sim_D_0_01_tausahp_50.mat', './simdata/pharma_long_sim_D_0_01_tausahp_50_stats.mat');
		compute_stats('./simdata/pharma_long_sim_D_0_01_tausahp_70.mat', './simdata/pharma_long_sim_D_0_01_tausahp_70_stats.mat');
		compute_stats('./simdata/pharma_long_sim_D_0_01.mat', './simdata/pharma_long_sim_D_0_01_stats.mat');
	end
	%Finally plot all the stats!
	if any(parts == 4)
                plotstats('./simdata/pharma_long_sim_D_0_01_gach_1_5_stats.mat', './worksheets/pharmacology/pharma_long_sims_plots/D_0_01_gach_1_5');
                plotstats('./simdata/pharma_long_sim_D_0_01_gach_2_66_stats.mat', './worksheets/pharmacology/pharma_long_sims_plots/D_0_01_gach_2_66');
                plotstats('./simdata/pharma_long_sim_D_0_01_tauach_0_15_stats.mat', './worksheets/pharmacology/pharma_long_sims_plots/D_0_01_tauach_0_15');
                plotstats('./simdata/pharma_long_sim_D_0_01_tauach_0_266_stats.mat', './worksheets/pharmacology/pharma_long_sims_plots/D_0_01_tauach_0_266');
                plotstats('./simdata/pharma_long_sim_D_0_01_tausahp_50_stats.mat', './worksheets/pharmacology/pharma_long_sims_plots/D_0_01_tausahp_50');
                plotstats('./simdata/pharma_long_sim_D_0_01_tausahp_70_stats.mat', './worksheets/pharmacology/pharma_long_sims_plots/D_0_01_tausahp_70');
                plotstats('./simdata/pharma_long_sim_D_0_01_stats.mat', './worksheets/pharmacology/pharma_long_sims_plots/D_0_01');
	end
end
