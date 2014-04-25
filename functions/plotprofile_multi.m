function plotprofile_multi(sols, filename, params, ptx, pty) 
        %plotprofile		Plot the time evolution at specified points of each dynamic variable compare two solutions
        %
        % Usage:
        %                       plotprofile_multi(sols, basename, params, ptx, pty)
        %
        % Input:
        %                       sols = cell-array of solution output from retinal2D(_split/_spec)
        %                       filename = output file name
	%			params = parameters used to generate solution. output from parameters()
	%			ptx = (optional, default = 0.5) x-coordinate of point to measure, as a proportion of nx (total x grid pts)
	%			pty = (optional, default = ptx) y-coordinate of points to measure, as above. 
        %
        % Examples:
        %                       bn = './plots/test.eps';
	%			params = parameters('ml_sahp', 'homog', [0:.1:10], 64, 'exponential');
        %                       sol1 = retinal2D_split(params);
	%			params.modelps(17) = 10;
        %                       sol2 = retinal2D_split(params);
        %                       plotprofile_multi({sol1, sol2}, bn, params);

	close all;

        if (nargin < 3)
                throw(MException('Argin:MoreExpected', 'More input arguments expected'));
	elseif (nargin < 4)
		ptx = 0.5; pty = 0.5;
	elseif (nargin < 5)
		pty = ptx;
        end

	nx = params.nx; ny = nx; tspan = params.tspan;
	n = params.n; names = params.names;
	nsols = length(sols);

	centersols = {};
	for i = 1:nsols
		centersols{i} = {};
		for j = 1:n
			centersols{i} = {centersols{i}{:}, []};
		end
	end
	centersols

        for i = 1:nsols
		for j=1:n
			tsol = [];
			for k = 1:length(tspan)
				tsol = [tsol; sols{i}{j}(k, floor(ptx*nx), floor(pty*ny))];
			end
			centersols{i}{j} = tsol;
        	end
	end

	subplot = @(m,n,p) subtightplot (m, n, p, [0.05 0.1], [0.15 0.05], [0.3 0.05]);
	f = figure;
	colors = colormap('lines');
	for i = 1:nsols
		for j = 1:n
			ax(j) = subplot(n,1,j);
			hold on
        		plot(tspan, centersols{i}{j}, 'Color', colors(i,:));
	        	ylabel(names{j}); drawnow
			if j == n
				xlabel('time (s)');
			else
				set(ax(j),'xcolor',get(f, 'color'),'xtick',[], 'xticklabel', []);
			end
		end
	end
	set(ax, 'box', 'off');
	%plotmult_vert(gcf, [filename], floor(n/2), 'eps', 0.5, 'plos1.5');
	plotmult_vert(gcf, [filename], floor(n/2), 'eps', 0.5, 'plos1.5');
end

