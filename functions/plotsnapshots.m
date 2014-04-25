function plotsnapshots(sol, filename, params, times, zaxis, idx) 
	%plotsnapshots 		Plot the solution as a heatmap for all times specified. Output to eps file
	%             		named specified. 
	%
	% Usage:
	%                       plotsnapshots(sol, filename, params, zaxis, idx, times)
	%
	% Input:
	%                       sol = solution output from retinal2D.m
	%                       filename = beginning of file name, will output to filename_1.eps, etc
	%			params = output from parameters() used to generate solution being plotted
	%			times = times to plot solution
	%                       zaxis = z-axis limits on plot (optional, default [-90 30])
	%			idx = index of variable to plot (optional, default = 1 [the voltage term])
	%
	% Examples:
	%			%Plot solution at t = 1, 2, 3
	%			params = parameters('ml_sahp', 'homog', [0:1:100]);
	%                       sol = retinal2D(params);
	%                       plotsnapshots(sol, './plots/test.eps', params, [1 2 3]);

	close all;
	fig = figure;

	nx = params.nx; ny = nx; tspan = params.tspan; nbc = params.nbc;
	L = params.length; names = params.names;
	xpts=linspace(-L/2,L/2,nx);

        if (nargin < 4)
                throw(MException('Argin:MoreExpected', 'More input arguments expected'));
        elseif (nargin < 5)
		idx = 1;
                zaxis = [-90 30];
	elseif (nargin < 6)
		idx = 1;
        end

	times = sort(times);
	i=1;
	n = 1;

        while length(times) > 0
	    if times(1) <= tspan(i)
		clf(fig);
	        Vsol=reshape(sol{idx}(i,:,:),nx,ny);
         	pcolor(xpts, xpts, Vsol);
        	caxis(zaxis);
	        set(gca,'Zlim',zaxis,'Ztick',zaxis, 'NextPlot', 'replacechildren');
        	xlabel(['mm (time = ' num2str(tspan(i)) 's)']);
		ylabel(names{idx});
        	colorbar, drawnow
		saveplot(gcf, [filename '_' num2str(n)  '.eps'], 'eps', [6 4]);
		times = times(2:end);
		n = n+1;
	    end
	    i = i + 1;
        end
