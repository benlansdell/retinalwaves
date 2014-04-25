%Run some longer simulations on a 128*128 grid and collect wave size stats
finvs = [200, 400, 600, 800];
tauss = [20, 40, 60, 80];
tlim = 500;

%test run
finvs = [200];
tauss = [20];
tlim = 10;

%Run with default parameters
params = parameters('ml_sahp', 'homog', [0:0.1:tlim], 128, 'bernoulli');
D = 0.005;
params.modelps(16) = D;
params.diffusion_coeff = D;
params.length = 4;

for idx1 = finvs
	for idx2 = tauss
		idx1
		idx2
		finv = finvs(idx1);
		p = params.noiseStepSize/finv; gnM = 20;
		params.fnoise = noisehandle('bernoulli', {p, gnM});
		params.modelps(26) = tauss(idx2);
		nm = ['soc_finv_' num2str(finv) '_taus_' num2str(tauss(idx2))];
		runlongsim(params, nm, 4, 1, 'split', 0, 1);
		compute_stats(['./simdata/' nm  '.mat'], ['./simdata/' nm '_stats.mat']);
		plotstats(['./simdata/' nm '_stats.mat'], ['./worksheets/soc/soc_plots/' nm]);
	end
end

if part == 4
%Compute R^2 value and perform KS test to test for power-law distribution
names = {'./simdata/soc_finv_800_stats.mat', './simdata/soc_taus_20_stats.mat', './simdata/soc_finv_200_stats.mat'};

for name = names
	%Compute R^2 value of fit to power-law. Exponent
	name
        x = 0.001:0.01:0.151;
	load(name{1})
        n_elements = histc(wavesizes,x);
        if ~isempty(n_elements)
                f = polyfit(log10(x(1:end-1)),log10(n_elements(1:end-1)'),1);
                r2 = coeffdet(log10(x(1:end-1)),log10(n_elements(1:end-1)'));
		f
		r2
        end

	%Simulate data from a theoretical power-law -1.15 distribution
	unif = rand(1,10000)';
	alpha = 0.15;
	power_alpha = unif.^(-1/alpha);
	power_alpha = power_alpha(power_alpha < (128^2));

	%compare wave size data to theoretical distribution
	[h, p, a] = kstest2(wavesizes, power_alpha, 0.1)

end
end
