%Here we study the effect of changing of minsize in wavedata.m before computing any wave statistics
%minsizes = [2 4 6 8 10];

%Load some simulated wave counts
%load('./simdata/bernoulli_long_sim_D_0_0075.mat');
%Compute wavecounts
%nsols = length(sol);
%nsols = 1;  %Test run with just one
%cts = {};

%for n = 1:nsols
%	cts = {cts{:}, wavecounts(sol{n}, params)};
%end

for ms = minsizes
	ms
	basename = ['./worksheets/wave_analysis/effect_of_minsize_plots/bernoulli_long_sim_D_0_0075_minsize_' num2str(ms)];
	strpts = []; endpts = []; wavesizes = []; wavedurs = []; wavespds = []; iwis = []; collidedspds = []; maxspds = []; maxcollidedspds = [];
	for n = 1:nsols
		%Run wavedata.m with different minsize stats
		[strpt, endpt, wavesize, wavedur, wavespd, iwi, collidedspd, maxspd, maxcollidedspd] = wavedata(cts{n}, params, '', ms);
		strpts = [strpts; strpt]; endpts = [endpts; endpt]; wavesizes = [wavesizes; wavesize]; wavedurs = [wavedurs; wavedur]; iwis = [iwis; iwi]; 
		collidedspds = [collidedspds; collidedspd]; maxspds = [maxspds; maxspd]; maxcollidedspds = [maxcollidedspds; maxcollidedspd]; 
	end
	%Save plots
	plotstats(strpts, endpts, wavesizes, wavedurs, wavespds, iwis, basename)
end

%Upload plots to homer.u.washington.edu for viewing
source = './worksheets/wave_analysis/effect_of_minsize_plots/';
uploadtoweb(source);

%Save for later...
%This this takes up a lot of space.... 10gb
save('./worksheets/wave_analysis/effect_of_minsize.mat');
