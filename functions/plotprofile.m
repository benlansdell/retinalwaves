function plotprofile(sol, filename, params, ptx, pty) 
        %plotprofile		Plot the time evolution at specified points of each dynamic variable
        %
        % Usage:
        %                       plotprofile(sol, basename, params, ptx, pty)
        %
        % Input:
        %                       sol = solution output from retinal2D(_split/_spec)
        %                       filename = output file names
	%			params = parameters used to generate solution. output from parameters()
	%			ptx = (optional, default = [0.5]) list of x coordinates of points to measure, as a proportion of nx (total x grid pts)
	%			pty = (optional, default = ptx) list of y coordinates of points to measure, as above. 
        %
        % Examples:
        %                       bn = './plots/test.eps';
	%			params = parameters('ml_sahp', 'homog', [0:.1:10], 64, 'exponential');
        %                       sol = retinal2D_split(params);
        %                       plotprofile(sol, bn, params);

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
	npts = length(ptx);

	centersol = {};
	for j = 1:n
		centersol = {centersol{:}, []};
	end

        for j=1:length(tspan)
		for k = 1:n
			tsol = [];
			for i = 1:npts
				tsol = [tsol; sol{k}(j, floor(ptx(i)*nx), floor(pty(i)*ny))];
			end
			centersol{k} = [centersol{k} tsol];
		end
        end

        subplot = @(m,n,p) subtightplot (m, n, p, [0.05 0.1], [0.1 0.05], [0.2 0.01]);
        f = figure
        for j = 1:n
                ax(j) = subplot(n,1,j);
                hold on
                plot(tspan, centersol{j});
                ylabel(names{j}); drawnow
                if j == n
                        xlabel('time (s)');
                else
                        set(ax(j),'xcolor',get(f, 'color'),'xtick',[], 'xticklabel', []);
                end
        end
        set(ax, 'box', 'off');
        plotmult_vert(gcf, [filename], floor(n/2), 'eps', 0.5, 'plos1.5');
end
