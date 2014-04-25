%Script to plot where we predict SOC to occur in simulations...and then to run a lot of simulations
%for those parameters and inspect (by eye, for now, but with longer simulations eventually...) whether 
%we do indeed observe SOC in those region


%we expect SOC to occur when:
%2.3*tau_s << 0.35 f^{-1} (finv)

[taus, finv] = meshgrid((0:80), (0:800));
ineq1 = 2.3*taus < 0.35*finv;             %# First inequation
ineq2 = 0.05^2*finv < 2.3^2*taus.^3; %# Second inequation
both = ineq1 & ineq2;                      %# Intersection of both inequations

figure, hold on
c = 1:3;                                   %# Contour levels
contourf(c(1) * both, [c(1), c(1)], 'k')   %# Fill area for both inequations
xlabel('tau_s')
ylabel('f inv')
%set(gca, 'XTickLabel', {t(get(gca, 'XTick'))}, 'YTickLabel', {t(get(gca, 'YTick'))})
saveplot(gcf, './worksheets/soc/soc_plots/taus_finv.eps');

%Run some longer simulations on a 128*128 grid and collect wave size stats
%Run with default parameters

%Let's first determine a good value of L and D to produce small waves for n = 128

tlim = 400;
params = parameters('ml_sahp', 'homog', [0:0.1:tlim], 128, 'bernoulli');
finv = 800;
p = params.noiseStepSize/finv; gnM = 20;
D = 0.005;
params.modelps(16) = D;
params.diffusion_coeff = D;
params.length = 4;
params.fnoise = noisehandle('bernoulli', {p, gnM});

%Then run that for a long time with three different parameter sets
runlongsim(params, 'soc1', 2, 1, 'split', 0, 1);
p = params.noiseStepSize/finv; gnM = 20;
params.fnoise = noisehandle('bernoulli', {p, gnM});
runlongsim(params, 'soc2', 2, 1, 'split', 0, 1);
compute_stats('./simdata/soc1.mat', './simdata/soc1_stats.mat');
compute_stats('./simdata/soc2.mat', './simdata/soc2_stats.mat');
plotstats('./simdata/soc1_stats.mat', './worksheets/soc/soc_plots/soc1');
plotstats('./simdata/soc2_stats.mat', './worksheets/soc/soc_plots/soc2');

%Compute R^2 value of fit to power-law. Exponent

%Take simulation data and look at 'critical density'

%Take stats and compute RMS of fires

%That's it....
