function [strpts, endpts, wavesizes, wavedurs, wavespds, iwis, collidedspds, maxspds, maxcollidedspds] = wavedata(countdata, params, basename, minsize)
        % wavedata     Function to collect wave data from a simulation of retinal wave behaviour. This includes the distribution of starting points,
	%			the set of observed wave sizes, wave durations, wave speeds, and inter-wave intervals.
        %
        % Usage:
        %                       [strpts, endpts, wavesizes, wavedurs, wavespds, iwis, collidedspds, maxspds, maxcollidedspds] = wavedata(cts, params, basename)
        %
        % Input:
	%			countdata = output from wavecounts. A solution from retinal2D which has been thresholded and labeled with 
	%				wave numbers
	%			params = parameters used to generate solution. See example
	%			basename = (optional) if provided then generate a series of plots containing path used for wave speed
	%					computation, having names wavespeed_basename1.eps, etc. A diagnostic. Will generate a
	%					plot for each wave larger than 10 grid points, so use on small datasets. 
	%			minsize = (optional, default = 2) the minimum size of wave to count towards computing wave statistics. Remove waves smaller
	%				than minsize.
        %
        % Output:
	%			strpts = nx2 matrix containing initation points of the n wave observed during the simulation
	%			endpts = nx2 matrix containing end points of the n waves observed during the simulation
	%			wavesizes = list of wave sizes -- scaled to the mm^2
	%			wavedurs = list of wave durations -- the time between the first and last frame associated with
	%				each wave, scaled to be in seconds
	%			wavespds = list of average wave speeds -- in mm/s, computed as in methods
	%			iwis = list of observed interwave intervals taken from every cell in the grid, scaled to be in seconds
	%			collidedspds = list of wave speeds from waves that have resulted from a collision
	%			maxspds = list of maximum speeds from waves
	%			maxcollidedspds = list of maximum speeds from waves whicih have collided
        %
        % Example(s):
	%			params = parameters('ml_sahp', 'homog', [0:0.05:50], 64, 'exponential');
	%			sol = retinal2D_split(params);
	%			counts = wavecounts(sol, params);
	%			strpts = wavedata(counts, params);

        if (nargin < 2)
                throw(MException('Argin:MoreExpected', 'More input arguments expected'));
        elseif (nargin < 3)
		basename = '';
		minsize = 2;
	elseif (nargin < 4)
		minsize = 2;
        end

	cts = countdata{1}; collisions = countdata{2};
	nwaves = max(max(max(cts)));

	%Remove waves smaller than minsize
        for n = 1:nwaves
                if sum(sum(sum(cts == n))) < minsize
                        cts(cts == n) = 0;
                end
        end

	%We're collecting: 
	strpts = [];
	endpts = [];
	wavesizes = [];
	wavedurs = [];
	wavespds = [];
	collidedspds = [];
	maxspds = [];
	maxcollidedspds =[];
	iwis = [];

	dt = params.tspan(2) - params.tspan(1);
	L = params.length;
	nx = params.nx;

	%Only computer wave speeds for waves above a certain size
	mingridpts = 10;
        %Set a minimum time of 1s for IWIs, otherwise considered part of the same wave.
        miniwi = 2;
        %Only record IWIS from center grid points to remove boundary effects -- center points will observe 
        %move waves
        border = 6;
	speedstep = 0.5;
	mindur = speedstep*2;

	%Cycle through each wave
	for n=1:nwaves
		a = (cts == n);
		%Make sure not empty!
		if any(any(any(a)))
			%Compress along x and y directions
			compressxy = any(any(a));
			starttime = find(compressxy, 1, 'first');
			endtime = find(compressxy, 1, 'last');
			deltat = dt*(endtime-starttime+1);
			[startptsx, startptsy] = find(a(:,:,starttime));
			[endptsx, endptsy] = find(a(:,:,endtime));
			startptx = mean(startptsx)*L/nx;
			startpty = mean(startptsy)*L/nx;
			endptx = mean(endptsx)*L/nx;
			endpty = mean(endptsy)*L/nx;
			if (startptx*nx/L > border) & (startptx*nx/L < nx-border) & (startpty*nx/L > border) & (startpty*nx/L < nx-border)
				wavedur = sum(compressxy)*dt;
				wavedurs = [wavedurs; wavedur];
				wavesize = sum(sum(any(a,3)));
				wavesizes = [wavesizes; wavesize*(L^2/nx^2)];
				%Only compute wave speed for waves of a minimum size
				%And if wave did not collide with others
				if (wavesize > mingridpts) & (wavedur > mindur)
					[spd, maxspd] = speedof(a, dt, L, nx, n, speedstep, basename);
					if ~any(collisions == n)
						wavespds = [wavespds; spd];
						maxspds = [maxspds; maxspd];
					else
						collidedspds = [collidedspds; spd];
						maxcollidedspds = [maxcollidedspds; maxspds];
					end
				end
			end
				strpts = [strpts; startptx, startpty];
				endpts = [endpts; endptx, endpty];
		end
	end

	%Compute the IWIs in a separate loop...
	active = cts > 0;
	%Spikes occur when activity goes up
	b = (active(:,:,2:end) - active(:,:,1:(end-1)))==1;

	sizeb = size(b);
	for i=border:(sizeb(1)-border)
		for j=border:(sizeb(2)-border)
			spiketimes = find(b(i,j,:));
			spiketimes = [0; spiketimes; 0];
			spikediff = spiketimes(2:end)-spiketimes(1:end-1);
			spikediff = spikediff(2:end-1);
			if spikediff*dt > miniwi
				iwis = [iwis; spikediff*dt];
			end
		end
	end
end

function [avespd, maxspd] = speedof(wave, dt, L, nx, n, speedstep, basename)
	%Function to compute wave speeds according to method laid out in Blankenship et al 2009. See their
	%supplementary materials
	compressxy = any(any(wave));
        starttime = find(compressxy, 1, 'first');
        endtime = find(compressxy, 1, 'last');
	[startptsx, startptsy] = find(wave(:,:,starttime));
	startptx = mean(startptsx); startpty = mean(startptsy);
        [endptsx, endptsy] = find(wave(:,:,endtime));
        deltat = dt*(endtime-starttime+1);
	deltax = 0;
	xys = [];
	instspd = [];
	%Find pt at end of time, and further from starting point. Add coords to a list of points
	dist = 0;
	for i = 1:length(endptsx)
		current_dist = sqrt((endptsx(i)-startptx)^2 + (endptsy(i)-startpty)^2);
		if current_dist > dist
			dist = current_dist;
			xy = [endptsx(i), endptsy(i)];
		end
	end
	xys = [xy];
	%Go back speedstep (how every many units in the array that is) and find point that is closest to the previous point. Add this to list
	%and add this distance to deltax
	pointone = floor(speedstep/dt);
	for i = (endtime-pointone):-pointone:starttime
		dist = inf;
		[ptsx, ptsy] = find(wave(:,:,i));
		for j = 1:length(ptsx)
			current_dist = sqrt((ptsx(j)-xys(end,1))^2 + (ptsy(j)-xys(end,2))^2);
			if current_dist < dist
				dist = current_dist;
				xy = [ptsx(j), ptsy(j)];
			end
		end
		xys = [xys; xy];
		instspd = [instspd; dist/speedstep];
		deltax = deltax + dist;
	end

	deltax = deltax*L/nx;
	instspd = instspd*L/nx;
	avespd = deltax/deltat;
	maxspd = max(instspd);

	%Output some screenshots of waves, just to get an idea it's doing what it should
	if length(basename) > 0
		figure 
                subplot(1,2,1)
		hold on
		%Color wave according to time index
		wavemap = zeros(nx,nx);
		for i = endtime:-1:starttime
			tmp = wave(:,:,i);
			wavemap(tmp>0) = i-starttime+1;
		end
		ncolors = endtime-starttime+1;
		col_copper = [1 1 1; copper(ncolors)];
	        colormap(col_copper);
        	pcolor(wavemap);
        	shading flat;
        	%set(gca,'Zlim',zaxis,'Ztick',zaxis, 'NextPlot', 'replacechildren');
        	%xlabel(['time = ' num2str(tspan(j))]);
		plot(xys(:,2), xys(:,1), '-og', 'LineWidth', 2);
		xlabel(['ave speed = ' num2str(avespd), ', duration = ' num2str(dt*(endtime-starttime+1)) ', max speed = ' num2str(maxspd)])	
                subplot(1,2,2)
                plot((1:length(instspd))*speedstep, instspd(end:-1:1));
		xlabel('time (s)'); ylabel('speed (mm)');
		plotmult(gcf, [basename '_wave_' num2str(n) '.eps'], 2);
	end
end
