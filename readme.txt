== A reaction-diffusion model of cholinergic retinal waves==

Contains matlab code to run simulations of general retinal waves models on a 2D lattice

Dependencies:

Developed using MATLAB 2013b.

Usage:

start matlab in this directory. All required functions lie in ./functions and ./models and should be added to path automatically by startup.m

An example:

	%Load parameters: 'ml_sahp' is name of main model, 'homog' is flat IC, [0:1:500] are time points to return solution
	params = parameters('ml_sahp', 'homog', [0:1:500]);
	%Run simulation for 500s, so system reaches 'equilibrium'
	sol = retinal2D_split(params);
	%Save solution to use as IC for future simulations
	savesol(sol, params, './test.mat');
	%Run another simulation with same parameters, using previously computed endpoint as IC
	params = parameters('./test.mat');
	sol = retinal2D_split(params);
	%Create animation of solution
	plotsol(sol, './test.gif', params);
	%Find and label waves
	counts = wavecounts(sol, params);
	%Compute wave statistics
	[strpts, endpts, wavesizes, wavedurs, wavespds, iwis] = wavedata(counts, params);
	%Plot wave statistics
	plotstats(strpts, endpts, wavesizes, wavedurs, wavespds, iwis, './test_stats');

See also:

	help runlongsim %Run a batch of simulations with a given parameter set
	[The ./worksheets directory for other examples]

Contact for more information:
Ben Lansdell
lansdell@uw.edu
