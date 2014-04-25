tlim = 500;
params = parameters('ml_sahp', 'homog', [0:1:tlim], 64, 'exponential');
sol = retinal2D_split(params);
savesol(sol, params, ['./worksheets/wave_analysis/effect_of_smoothing_on_stats_plots.mat']);

%Test counting and speed calulation effect on wave stats
params = parameters(['./worksheets/wave_analysis/effect_of_smoothing_on_stats_plots.mat']);
tlim = 500; params.tspan = [0:0.1:tlim];
rng shuffle
sol1 = retinal2D_split(params);
fn1 = ['./worksheets/wave_analysis/effect_of_smoothing_on_stats_plots/wavecounts_no_smooth_thresh_-60'];
fn2 = ['./worksheets/wave_analysis/effect_of_smoothing_on_stats_plots/wavecounts_no_smooth_thresh_-55'];
fn3 = ['./worksheets/wave_analysis/effect_of_smoothing_on_stats_plots/wavecounts_no_smooth_thresh_-50'];

%Without smooting, threshold = -60
cts1 = wavecounts(sol1, params, [fn1 '.gif']);
[strpts, endpts, wavesizes, wavedurs, wavespds, iwis, collidedspds, maxspds, maxcollidedspds] = wavedata(cts1, params, fn1);
plotstats(strpts, endpts, wavesizes, wavedurs, wavespds, iwis, fn1, params);

%Change threshold to -55 and -50
params.threshold = -55;
cts2 = wavecounts(sol1, params, [fn2 '.gif']);
[strpts, endpts, wavesizes, wavedurs, wavespds, iwis, collidedspds, maxspds, maxcollidedspds] = wavedata(cts2, params, fn2);
plotstats(strpts, endpts, wavesizes, wavedurs, wavespds, iwis, fn2, params);

params.threshold = -50;
cts3 = wavecounts(sol1, params, [fn3 '.gif']);
[strpts, endpts, wavesizes, wavedurs, wavespds, iwis, collidedspds, maxspds, maxcollidedspds] = wavedata(cts3, params, fn3);
plotstats(strpts, endpts, wavesizes, wavedurs, wavespds, iwis, fn3, params);

fn4 = ['./worksheets/wave_analysis/effect_of_smoothing_on_stats_plots/wavecounts_smooth_thresh_-30'];
fn5 = ['./worksheets/wave_analysis/effect_of_smoothing_on_stats_plots/wavecounts_smooth_thresh_-40'];
fn6 = ['./worksheets/wave_analysis/effect_of_smoothing_on_stats_plots/wavecounts_smooth_thresh_-50'];

%With smooting, threshold = -30
params.threshold = -30;
cts1 = wavecounts(sol1, params, [fn4 '.gif'], 2, 2);
[strpts, endpts, wavesizes, wavedurs, wavespds, iwis, collidedspds, maxspds, maxcollidedspds] = wavedata(cts1, params, fn4);
plotstats(strpts, endpts, wavesizes, wavedurs, wavespds, iwis, fn4, params);

%Change threshold to -40 and -50
params.threshold = -40;
cts2 = wavecounts(sol1, params, [fn5 '.gif']);
[strpts, endpts, wavesizes, wavedurs, wavespds, iwis, collidedspds, maxspds, maxcollidedspds] = wavedata(cts2, params, fn5);
plotstats(strpts, endpts, wavesizes, wavedurs, wavespds, iwis, fn5, params);

params.threshold = -50;
cts3 = wavecounts(sol1, params, [fn6 '.gif']);
[strpts, endpts, wavesizes, wavedurs, wavespds, iwis, collidedspds, maxspds, maxcollidedspds] = wavedata(cts3, params, fn6);
plotstats(strpts, endpts, wavesizes, wavedurs, wavespds, iwis, fn6, params);

