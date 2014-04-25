function plotmultisol(sol, filename, params, zaxes, indices, plotevery)
	%plotsol       Plot the specified solution components as a heatmap for all times specified. Output to gif file
	%              named specified. Use subplot to display multiple solution components at once.
	%
	% Usage:
	%                       plotmultisol(sol, filename, options, zaxes, indices, plotevery)
	%
	% Input:
	%                       sol = solution output from retinal2D.m
	%			params = output from parameters() used to generate solution being plotted
	%                       filename = save plot to this file
	%                       zaxes = cell-array containing z-axes limits on each plot
	%			indices = cell-array containing indices of variables to plot
	%			plotevery = plot solution every x time steps (optional, default = 100)
	%
	% Examples:
	%			%plot voltage and A fields
	%                       fn = './plots/test.gif';
	%			params = parameters('ml_sahp', 'homog', [0:1:100], 64, 'exponential');
	%                       sol = retinal2D_split(params);
	%                       plotmultisol(sol, fn, params, {[-90, 30], [0 0.6]}, {1,4});

	close all;
	fig = figure;

	nx = params.nx; ny = nx; tspan = params.tspan; nbc = params.nbc; names = params.names; L = params.length;
	pts = linspace(-L/2,L/2,nx);

        if (nargin < 5)
                throw(MException('Argin:MoreExpected', 'More input arguments expected'));
	elseif (nargin < 6)
		plotevery = 10;
        end

	framen = 1;
	frames = 1:plotevery:length(tspan);
        for j=frames
	    clf(fig);
		for k = 1:length(indices)
			subplot(1,length(indices),k)
            		Vsol=reshape(sol{indices{k}}(j,:,:),nx,ny);
            		pcolor(pts,pts,Vsol);
            		shading interp;
			zaxis = zaxes{k};
            		caxis(zaxis);
            		set(gca,'Zlim',zaxis,'Ztick',zaxis, 'NextPlot', 'replacechildren');
            		xlabel(['mm (time = ' num2str(tspan(j)) 's)']);
			ylabel(names{indices{k}});
            		colorbar, drawnow
		end
	    %Embarrassing workaround...don't look at this
	    plotmult(gcf, [filename '_tmp.png'], length(indices), 'png', [6 4]);
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
end
