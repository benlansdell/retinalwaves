inputfile = './simdata/bernoulli_long_sim_D_0_005.mat';
outfile = './worksheets/finding_realistic_waves/plot_correlation_bernoulli_long_sim_plots/correlation_D_0_005.eps';
%See if it's enough to just plot correlation from 500s of simulation, or if we need more
plotcorrelation_longsim(inputfile, outfile);
