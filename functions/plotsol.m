function plotsol(sol, filename, params, zaxis, idx, plotevery) 
	%plotsol       Plot the solution as a heatmap for all times specified. Output to gif file
	%              named specified. 
	%
	% Usage:
	%                       plotsol(sol, filename, params, zaxis, idx, plotevery)
	%
	% Input:
	%                       sol = solution output from retinal2D.m
	%                       filename = save plot to this file
	%			params = output from parameters() used to generate solution being plotted
	%                       zaxis = z-axis limits on plot (optional, default [-90 30])
	%			idx = index of variable to plot (optional, default = 1 [the voltage term])
	%			plotevery = plot solution every x time steps (optional, default = [100])
	%
	% Examples:
	%			params = parameters('ml_sahp', 'homog', [0:1:100]);
	%                       sol = retinal2D(params);
	%                       plotsol(sol, './plots/test.gif', params);

	close all;
	fig = figure;

	nx = params.nx; ny = nx; tspan = params.tspan; nbc = params.nbc;
	L = params.length; names = params.names;
	xpts=linspace(-L/2,L/2,nx);

        if (nargin < 3)
                throw(MException('Argin:MoreExpected', 'More input arguments expected'));
        elseif (nargin < 4)
		idx = 1;
                zaxis = [-90 30];
		plotevery = 10;
	elseif (nargin < 5)
		idx = 1;
		plotevery = 10;
	elseif (nargin < 6)
		plotevery = 10;
        end

	framen = 1;
	frames = 1:plotevery:length(tspan);
        for j=frames
	    clf(fig);
            Vsol=reshape(sol{idx}(j,:,:),nx,ny);
            pcolor(xpts, xpts, Vsol);
            shading interp;
            caxis(zaxis);
            set(gca,'Zlim',zaxis,'Ztick',zaxis, 'NextPlot', 'replacechildren');
            xlabel(['mm (time = ' num2str(tspan(j)) 's)']);
	    ylabel(names{1});
            colorbar, drawnow
	    %Embarrassing workaround...don't look at this
	    saveplot(gcf, [filename '_tmp.png'], 'png', [6 4]);
	    [X, m] = imread([filename '_tmp.png'], 'png');
	    f = im2frame(X, m);
	    if j == 1
	        [im, map] = rgb2ind(f.cdata, 256, 'nodither');
		im(1,1,1,length(frames)) = 0;
	    else
	        im(:,:,1,framen) = rgb2ind(f.cdata, map, 'nodither');
	    end
	    framen = framen + 1;
        end
	imwrite(im, map, [filename], 'gif', 'DelayTime', 0, 'LoopCount', inf);
