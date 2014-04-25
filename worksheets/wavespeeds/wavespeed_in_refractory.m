%Script to validate our estimates of wavespeed in the presence of noise
%December 3rd 2013

%Take data from a long simulation and compute histogram of refractory distribution
%%Load data from long simulation
%%Extract refractory data
load('./simdata/pharma_long_sim_D_0_01.mat')
R = reshape(sol{1}{2},1,5001*64*64);

%Then take data from AUTO which computes the C vs R curve
%%Load AUTO C vs R curve
AUTO_C_vs_R = csvread('./c_vs_r_pharma_default.txt');
%%Interpolate curve using interp1
interp_C = interp1(AUTO_C_vs_R(:,1), AUTO_C_vs_R(:,2), R);

%Then convert this curve to a function which can be used to map all the refractory points to 
%wave speed points and compute the histogram of _this_ distribution. Check this against wavespeed from simulations 

hist(R)
saveplot(gcf, ['./worksheets/wavespeeds/wavespeed_in_refractory_plots/hist_R.eps']);

hist(interp_C);
saveplot(gcf, ['./worksheets/wavespeeds/wavespeed_in_refractory_plots/pred_spd_from_ref.eps']);
