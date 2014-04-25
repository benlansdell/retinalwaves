function [strpts, endpts, wavesizes, wavedurs, wavespds, iwis] = wavedata(cts)
        % wavedata     Function to collect wave data from a simulation of retinal wave behaviour. This includes the distribution of starting points,
	%			the set of observed wave sizes, wave durations, wave speeds, and inter-wave intervals.
        %
        % Usage:
        %                       [strpts, endpts, wavesizes, wavedurs, wavespds, iwis] = wavedata(cts)
        %
        % Input:
	%			cts = output from wavecounts. A solution from retinal2D which has been thresholded and labeled with 
	%				wave numbers
        %
        % Output:
        %                       A cell array is output containing the following items
	%			strpts = nx2 matrix containing initation points of the n wave observed during the simulation
	%			wavesizes = list of wave sizes -- the number of grid points associated with each wave
	%			wavedurs = list of wave durations -- the time between the first and last frame associated with
	%				each wave.
	%			wavespds = list of wave speeds -- the distance between the (mean) initiation point and the (mean)
	%				(mean) ending point divided by the wave duration
	%			iwis = list of observed interwave intervals taken from every cell in the grid
        %
        % Example(s):
        %                       ics = loadics('randomIC');
        %                       params = paramset('stdP');
        %                       [sol, opts] = retinal2D(ics, params);
	%			counts = wavecounts(sol, opts);
	%			strpts = wavedata(counts);

	nwaves = max(max(max(cts)));

	%We're collecting: 
	strpts = [];
	endpts = [];
	wavesizes = [];
	wavedurs = [];
	wavespds = [];
	iwis = [];

	%Cycle through each wave
	for n=1:nwaves
		%Compress along x and y directions
		a = (cts == n);
		%Make sure not empty!
		if any(any(any(a)))
			compressxy = any(any(a));
			starttime = find(compressxy, 1, 'first');
			endtime = find(compressxy, 1, 'last');
			deltat = endtime-starttime+1;
			[startptsx, startptsy] = find(a(:,:,starttime));
			[endptsx, endptsy] = find(a(:,:,endtime));
			startptx = mean(startptsx);
			startpty = mean(startptsy);
			endptx = mean(endptsx);
			endpty = mean(endptsy);
			deltax = sqrt((endptx-startptx)^2 + (endpty-startpty)^2);
			wavedurs = [wavedurs sum(compressxy)];
			wavesizes = [wavesizes sum(sum(any(a,3)))];
			wavespds = [wavespds deltax/deltat];
			strpts = [strpts; startptx, startpty];
			endpts = [endpts; endptx, endpty];
		end
	end

	%Compute the IWIs in a separate loop...
	b = (a(:,:,2:end) - a(:,:,1:(end-1)))==1;
	sizeb = size(b);
	for i=1:sizeb(1)
		for j=1:sizeb(2)
			spiketimes = find(b(i,j,:));
			spiketimes = [0; spiketimes; 0];
			spikediff = spiketimes(2:end)-spiketimes(1:end-1);
			spikediff = spikediff(2:end-1);
			iwis = [iwis; spikediff];
		end
	end
