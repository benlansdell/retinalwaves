function plotstats(strpts, endpts, wavesizes, wavedurs, wavespds, iwis, basename, nx, ny)
        % plotstats     Function to plot distributions of wave properites. All of the inputs can be computed using wavedata().
        %
        % Usage:
        %                       plotstats(strpts, endpts, wavesizes, wavedurs, wavespds, iwis, basename, nx, ny)
        %
        % Input:
        %                       cts = output from wavecounts. A solution from retinal2D which has been thresholded and labeled with 
        %			strpts = nx2 matrix listing the x and y coordinates of initiation points of waves
	%			endpts = nx2 matrix listing the x and y coordinates of the ending points of waves
	%			wavesizes = list of observed wave sizes in simulation
	%			wavedurs = list of observed wave durations in simulation
	%			wavespds = list of observed wave speeds in simulation
	%			iwis = list of observed interwave-intervals in simulation
	%			basename = base of filename to save each plot to. note that mean, std and number of data points are
	%				attached to the filename
	%			nx = x dimension, used for plot of strpts and endpts
	%			ny = y dimension, used for plots of strpts and endpts
	%
        % Output:
        %
        % Example(s):
        %                       ics = loadics('random');
        %                       params = parameters('fn');
        %                       [sol, opts] = retinal2D(ics, 'fn', params);
        %                       counts = wavecounts(sol, opts);
        %                       [strpts, endpts, wavesizes, wavedurs, wavespds, iwis] = wavedata(counts);
	%			plotstats(strpts, endpts, wavesizes, wavedurs, wavespds, iwis, './plots/test', 64, 64);


	%For the time being a histogram is better...
	%[f, xi] = ksdensity(wavesizes);
	%plot(xi, f);
	hist(wavesizes)
	xlabel('Wave size')
	saveplot(gcf, [basename '_wavesizes_mean_' num2str(mean(wavesizes)) '_std_' num2str(std(wavesizes)) '_n_' num2str(length(wavesizes)) '.eps'])
	hist(wavedurs)
	xlabel('Wave duration')
	saveplot(gcf, [basename '_wavedurs_mean_' num2str(mean(wavedurs)) '_std_' num2str(std(wavedurs)) '_n_' num2str(length(wavedurs)) '.eps'])
	hist(wavespds)
	xlabel('Wave speed')
	saveplot(gcf, [basename '_wavespds_mean_' num2str(mean(wavespds)) '_std_' num2str(std(wavespds)) '_n_' num2str(length(wavespds)) '.eps'])
	hist(iwis)
	xlabel('Interwave interval')
	saveplot(gcf, [basename '_iwis_mean_' num2str(mean(iwis)) '_std_' num2str(std(iwis)) '_n_' num2str(length(iwis)) '.eps'])
