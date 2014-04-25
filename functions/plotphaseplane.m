function plotphaseplane(sol, filename, params, vars, ptx, pty) 
        %plotprofile		Plot the time evolution at a single point (the center by default) on a phase plane of specified variables
        %
        % Usage:
        %                       plotphaseplane(sol, basename, params, ptx, pty)
        %
        % Input:
        %                       sol = solution output from retinal2D(_split/_spec)
        %                       basename = output file name: './plots/' filename
	%			params = parameters used to generate solution. output from parameters()
	%			vars = two component array listing indices to plot on x and y axes
	%			ptx = (optional, default = 0.5) x coordinate of point to measure, as a proportion of nx (total x grid pts)
	%			pty = (optional, default = ptx) y coordinate of point to measure, as above. 
        %
        % Examples:
        %                       fn = './plots/test_phaseplane.eps';
	%			params = parameters('ml_sahp', 'homog', [0:.1:10], 64, 'exponential');
        %                       sol = retinal2D_split(params);
        %                       plotphaseplane(sol, fn, params);

	close all;

        if (nargin < 4)
                throw(MException('Argin:MoreExpected', 'More input arguments expected'));
	elseif (nargin < 5)
		ptx = 0.5; pty = 0.5;
	elseif (nargin < 6)
		pty = ptx;
        end

	nx = params.nx; ny = nx; tspan = params.tspan;
	n = params.n; names = params.names;

	centersol = {};
	for j = 1:n
		centersol = {centersol{:}, []};
	end

        for j=1:length(tspan)
		for k = 1:n
			centersol{k} = [centersol{k} sol{k}(j, floor(ptx*nx), floor(pty*ny))];
		end
        end

        plot(centersol{vars(1)}, centersol{vars(2)}, '.');
        xlabel(names{vars(1)}); ylabel(names{vars(2)}); drawnow
	saveplot(gcf, [filename])
end
