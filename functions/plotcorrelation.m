function [dd, loess_v] = plotcorrelation(sol, filename, params, ptx, pty) 
        %plotcorrelation	Plot the time evolution at specified points of each dynamic variable
        %
        % Usage:
        %                       plotcorrelation(sol, basename, params, ptx, pty)
        %
        % Input:
        %                       sol = solution output from retinal2D(_split/_spec)
        %                       filename = output file name
	%			params = parameters used to generate solution. output from parameters()
	%			ptx = (optional, default = [0.5]) x coordinate of point to measure, as a proportion of nx (total x grid pts)
	%			pty = (optional, default = ptx) y coordinate of point to measure, as above. 
	% 
	% Output:
	%			dd = distance coordinate for plotting externally
	%			loess_v = smoothed voltage correlation coordinate for plotting externally
        %
        % Examples:
        %                       fn = './tests/test_plotcorrelation.eps';
	%			params = parameters('ml_sahp', 'homog', [0:.1:10], 64, 'exponential');
        %                       sol = retinal2D_split(params);
        %                       plotcorrelation(sol, fn, params);

	close all;

        if (nargin < 3)
                throw(MException('Argin:MoreExpected', 'More input arguments expected'));
	elseif (nargin < 4)
		ptx = 0.5; pty = 0.5;
	elseif (nargin < 5)
		pty = ptx;
        end

	nx = params.nx; ny = nx; tspan = params.tspan;
	n = params.n; names = params.names; L = params.length;

	centersol = {};
	for j = 1:n
		centersol = {centersol{:}, []};
	end

	distance = [];
	for i=1:nx
		for j=1:nx
			distance = [distance, L*sqrt((i/nx-ptx)^2+(j/nx-pty)^2)];
			for k = 1:n
				corrpts = corr(sol{k}(:,i,j), sol{k}(:,floor(ptx*nx),floor(pty*ny)))^2;
				centersol{k} = [centersol{k} corrpts];
			end
		end
	end
	
	[dd, ind] = sort(distance);

	for j = 1:n
		%Fit a loess curve to data
		loess = smooth((distance), 1-centersol{j}, 0.3, 'loess');
		loess = loess(ind);
		subplot(n,1,j);
        	%semilogx(distance, centersol{j}, '.');
        	%semilogx(dd, loess(ind), dd, centersol{j}(ind), '.');
        	%plot(log10(dd), loess(ind), log10(dd), centersol{j}(ind), '.');
		%hold on
		smoothhist2D([(dd)', 1-centersol{j}(ind)'], 5, [100 100], 0.05);
		hold on
		plot((dd), loess)
		%xlim([-1.5 0])
		ylim([0 1])
        	%plot(distance, centersol{j}, '.');
        	xlabel('distance (mm)'); ylabel(names{j}(1)); drawnow
		hold off
		if (j == 1)
			loess_v = loess
		end
	end
	plotmult_vert(gcf, [filename], n)
end
