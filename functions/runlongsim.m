function runlongsim(params, name, nruns, plotsolution, method, nave, savesols)
	% runlongsim    Run a simulation a given amount of times and collect and plot statistics from simulations
        %
        % Usage:
        %                       runlongsim(params, name, nruns, plotsolution, method, nave, savesols)
        %
        % Input:
        %                       params = output from parameters() used to generate solution being plotted
        %                       name = name of experiment to attach to file name
        %                       nruns = number of simulations to perform
	%			plotsolution = (optional, default = 0) whether to plot solution (1) or not (0)
	%			method = (optional, default = 'split') which PDE method to use. 'split' or 'spec'
	%			nave = (optional, default = 2) number of averaging cycles to go through
	%			savesols = (optional, default = 0) 1 = save solution data, 0 = don't
        %
        % Examples:
        %                       params = parameters('ml_sahp', 'homog', [0:0.1:100]);
	%			runlongsim(params, './simdata/test', 5);

        if (nargin < 3)
                throw(MException('Argin:MoreExpected', 'More input arguments expected'));
        elseif (nargin < 4)
                plotsolution = 0;
		method = 'split';
		savesols = 0;
		nave = 2;
	elseif nargin < 5
		method = 'split';
		savesols = 0;
		nave = 2;
	elseif nargin < 6
		nave = 2;
		savesols = 0;
	elseif nargin < 7
		savesols = 0;
        end

	if strcmp(method, 'split')
		sol = retinal2D_split(params);
	elseif strcmp(method, 'spec')
		sol = retinal2D_spec(params);
	else
		throw(MException('Argin:invalid', 'Please select method as one of split or spec'));
	end
	%Starting data for each simulation. Just use different random noise for each one
	savesol(sol, params, [name '.mat']);
	sols = {};
	for n = 1:nruns
		display([name ': run ' num2str(n) ' of ' num2str(nruns)])
		%Load previous as initial condition
		params = parameters([name '.mat']);
		%Solve again
		if strcmp(method, 'split')
			sol = retinal2D_split(params);
		else
			sol = retinal2D_spec(params);
		end
		sols = {sols{:}, sol};
        	savesol(sol, params, [name '.mat']);
	end

	if plotsolution == 1
		plotmultisol(sol, ['./simdata/' name '_sol.gif'], params, {[-90, 0], [0, 0.2], [0 0.6]}, {1,3,4});
	end

	if savesols == 1
		savesol(sols, params, ['./simdata/' name '.mat']);
	end
end
