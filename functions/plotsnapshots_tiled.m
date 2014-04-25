function plotsnapshots_tiled(sol, filename, params, times, zaxes, indices, tight) 
	%plotsnapshots_tiled	Plot the solution as a heatmap for all times specified. Output to eps file
	%             		named specified. 
	%
	% Usage:
	%                       plotsnapshots_tiled(sol, filename, params, zaxis, idx, times)
	%
	% Input:
	%                       sol = solution output from retinal2D.m
	%                       filename = output file name
	%			params = output from parameters() used to generate solution being plotted
	%			times = times to plot solution
	%                       zaxes = z-axis limits on plot
	%			indices = indices of variable to plot
	%			tight = (optional, default = 1) 1 or 0, whether or not to make axes close together
	%					usually a good idea to make two plots, one tight and one not.
	%					non-tight plot will show colorbar and labels correctly
	%
	% Examples:
	%			%Plot solution at t = 1, 2, 3
	%			params = parameters('ml_sahp', 'homog', [0:1:100]);
	%                       sol = retinal2D(params);
	%                       plotsnapshots_tiled(sol, './plots/test.eps', params, [1 2 3], {[-90 30],[0 0.3],[0 0.3]}, {1,2,3});

	close all;
	fig = figure;

	nx = params.nx; ny = nx; tspan = params.tspan; nbc = params.nbc;
	L = params.length; names = params.names;
	xpts=linspace(-L/2,L/2,nx);

        if (nargin < 6)
                throw(MException('Argin:MoreExpected', 'More input arguments expected'));
	elseif nargin < 7
		tight = 1;
        end

	times = sort(times);
	i = 1;
	j = 1;

	subplots = @(m,n,p) subplot(m, n, p);
	if tight
		subplots = @(m,n,p) subtightplot (m, n, p, [0.01 0.01], [0.01 .01], [0.01 0.01]);
	end

	n = length(times);
	m = length(indices);

        while length(times) > 0
	    if times(1) <= tspan(i)
		for k = 1:m
			subplots(m, n, (k-1)*n+j);
		        Vsol=reshape(sol{indices{k}}(i,:,:),nx,ny);
        	 	pcolor(xpts, xpts, Vsol);
        		caxis(zaxes{k});
			shading interp
            		if j == 1 & ~tight
            			ylabel(params.names{k});
			end
			if j == n & ~tight
				colorbar
			end
		        set(gca,'Zlim',zaxes{k},'Ztick',zaxes{k}, 'NextPlot', 'replacechildren');
	 		set(gca,'xtick',[], 'xticklabel', [], 'ytick', [], 'yticklabel', []);
			if k == m
				text(xpts(1), xpts(1)+0.3, ['t=' num2str(tspan(i))], 'color', [1 1 1], 'fontsize', 10);
			end
        		%colorbar, drawnow
		end
		times = times(2:end);
		j = j + 1;
	    end
	    i = i + 1;
        end
	if tight
		saveplot(gcf, filename, 'eps', [2.86 2.86*0.6]);
	else
		saveplot(gcf, filename, 'eps', [3.86 3.86*0.6]);
	end
