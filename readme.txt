== A reaction-diffusion model of cholinergic retinal waves==

Benjamin Lansdell, Kevin Ford and J. Nathan Kutz. 2014. Made available under the GNU Public License v3.0 license -- see COPYING and license.txt for more information.

Contains matlab and AUTO code to run simulations of general retinal waves models on a 2D lattice. An application of this code can be found here: http://arxiv.org/abs/1404.7549

Dependencies:

Developed using MATLAB 2013b, AUTO-07p.

MATLAB Usage:

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

AUTO code runs numerical continuation using subpackage homcont to compute heteroclinic orbits used to construct traveling wave fronts of retinal wave model.
Determines excitability thresholds as a function of model parameters.

Contact for more information:
Ben Lansdell
staff.washington.edu/lansdell
lansdell@uw.edu
