function plotcorrelation_longsim(infn, outfn, ptx, pty) 
        %plotcorrelation	Plot the time evolution at specified points of each dynamic variable
        %
        % Usage:
        %                       plotcorrelation_longsim(infn, outfn, params, ptx, pty)
        %
        % Input:
        %                       infn = saved solution data filename from run_long_sim.m
        %                       outfn = output file name to save plot to
	%			ptx = (optional, default = [0.5]) x coordinate of point to measure, as a proportion of nx (total x grid pts)
	%			pty = (optional, default = ptx) y coordinate of point to measure, as above. 
        %
        % Examples:
 	%                       params = parameters('ml_sahp', 'homog', [0:0.1:100]);
        %	                runlongsim(params, 'test', 5, 0, 'split', 2, 1);
        %                       plotcorrelation_longsim('./simdata/test.mat', fn, params);

	close all;

        if (nargin < 2)
                throw(MException('Argin:MoreExpected', 'More input arguments expected'));
	elseif (nargin < 3)
		ptx = 0.5; pty = 0.5;
	elseif (nargin < 4)
		pty = ptx;
        end

	load(infn);
	nx = params.nx; ny = nx; tspan = params.tspan;
	n = params.n; names = params.names; L = params.length;

	centersol = {};
	for j = 1:n
		centersol = {centersol{:}, []};
	end

	distance = [];
	for m=1:length(sol)
		current_sol = sol{m};
		m
		for i=1:nx
			for j=1:nx
				distance = [distance, L*sqrt((i/nx-ptx)^2+(j/nx-pty)^2)];
				for k = 1:n
					corrpts = corr(current_sol{k}(:,i,j), current_sol{k}(:,floor(ptx*nx),floor(pty*ny)))^2;
					centersol{k} = [centersol{k} corrpts];
				end
			end
		end
	end
	
	[dd, ind] = sort(distance);

	for j = 1:n
		%Fit a loess curve to data
		loess = smooth((distance), centersol{j}', 0.1, 'loess');
		subplot(n,1,j);
        	%semilogx(distance, centersol{j}, '.');
        	%semilogx(dd, loess(ind), dd, centersol{j}(ind), '.');
        	%plot(log10(dd), loess(ind), log10(dd), centersol{j}(ind), '.');
		%hold on
		smoothhist2D([(dd)', centersol{j}(ind)'], 5, [100 100], 0.05);
		hold on
		plot((dd), loess(ind))
		axis xy
		%xlim([-1.5 0])
		ylim([0 1])
        	%plot(distance, centersol{j}, '.');
        	xlabel('distance (mm)'); ylabel(names{j}(1)); drawnow
		hold off
	end
	plotmult_vert(gcf, [outfn], n)
end

	
