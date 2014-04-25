function compute_stats(inputfile, filename, minsize, threshold)

	if nargin < 3
		minsize = 2;
		threshold = '';
	elseif nargin < 4
		threshold = '';
	end

	strpts = []; endpts = []; wavesizes = []; wavedurs = []; iwis = []; wavespds = []; collidedspds = [];
	maxspds = []; maxcollidedspds = [];
	load(inputfile)
	l = length(sol)
	clearvars('sol');
	for n = 1:l
		%Only load one in at a time
		n
        	%Collect data
		load(inputfile);
		if ~strcmp(threshold, '')
			params.threshold = threshold;
		end
		current_sol = sol{n};
		clearvars('sol');
        	counts = wavecounts(current_sol, params, 0, minsize);
        	[strpt, endpt, wavesize, wavedur, wavespd, iwi, collidedspd, maxspd, maxcollidedspd] = wavedata(counts, params, '', minsize);
        	%Append to previously collected data
        	strpts = [strpts; strpt]; endpts = [endpts; endpt];
        	iwis = [iwis; iwi]; wavesizes = [wavesizes; wavesize]; wavedurs = [wavedurs; wavedur]; wavespds = [wavespds; wavespd];
		collidedspds = [collidedspds; collidedspd]; maxspds = [maxspds; maxspd]; maxcollidedspds = [maxcollidedspds; maxcollidedspd];
	end
	%Save data for later...
	savestats(strpts, endpts, wavesizes, wavedurs, wavespds, iwis, collidedspds, maxspds, maxcollidedspds, filename);

end
