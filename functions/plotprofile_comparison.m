function plotprofile_comparison(sol1, sol2, filename, params, sol_names, ptx, pty) 
        %plotprofile		Plot the time evolution at specified points of each dynamic variable compare two solutions
        %
        % Usage:
        %                       plotprofile_comparison(sol1, sol2, basename, params, ptx, pty)
        %
        % Input:
        %                       sol1 = solution output from retinal2D(_split/_spec)
        %                       sol2 = solution output from retinal2D(_split/_spec)
        %                       filename = output file name
	%			params = parameters used to generate solution. output from parameters()
	%			names = name of solutions
	%			ptx = (optional, default = [0.5]) list of x coordinates of points to measure, as a proportion of nx (total x grid pts)
	%			pty = (optional, default = ptx) list of y coordinates of points to measure, as above. 
        %
        % Examples:
        %                       bn = './plots/test.eps';
	%			params = parameters('ml_sahp', 'homog', [0:.1:10], 64, 'exponential');
        %                       sol1 = retinal2D_split(params);
	%			params.modelps(17) = 10;
        %                       sol2 = retinal2D_split(params);
        %                       plotprofile_comparison(sol1, sol2, bn, params);

	close all;

        if (nargin < 5)
                throw(MException('Argin:MoreExpected', 'More input arguments expected'));
	elseif (nargin < 6)
		ptx = [0.5]; pty = [0.5];
	elseif (nargin < 7)
		pty = ptx;
        end

	nx = params.nx; ny = nx; tspan = params.tspan;
	n = params.n; names = params.names;
	npts = length(ptx);

	centersol1 = {};
	centersol2 = {};
	for j = 1:n
		centersol1 = {centersol1{:}, []};
		centersol2 = {centersol2{:}, []};
	end

        for j=1:length(tspan)
		for k = 1:n
			tsol1 = [];
			tsol2 = [];
			for i = 1:npts
				s = sol1{k}(j, floor(ptx(i)*nx), floor(pty(i)*ny));
				%tsol1 = [tsol1; sol1{k}(j, floor(ptx(i)*nx), floor(pty(i)*ny))];
				tsol1 = [tsol1; s];
				tsol2 = [tsol2; sol2{k}(j, floor(ptx(i)*nx), floor(pty(i)*ny))];
			end
			centersol1{k} = [centersol1{k} tsol1];
			centersol2{k} = [centersol2{k} tsol2];
		end
        end

	subplot = @(m,n,p) subtightplot (m, n, p, [0.05 0.1], [0.1 0.05], [0.2 0.01]);
	f = figure
	for j = 1:n
		ax(j) = subplot(n,1,j);
		hold on
        	plot(tspan, centersol1{j});
        	plot(tspan, centersol2{j}, '--');
        	ylabel(names{j}); drawnow
		if j == n
			xlabel('time (s)');
		else
			set(ax(j),'xcolor',get(f, 'color'),'xtick',[], 'xticklabel', []);
		end
	end
	set(ax, 'box', 'off');
	plotmult_vert(gcf, [filename], floor(n/2));
end

