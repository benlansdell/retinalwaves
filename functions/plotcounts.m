function plotcounts(cts, sol, params, filename)

	close all;
        fig = figure;

        nx = params.nx; ny = nx; tspan = params.tspan; nbc = params.nbc; names = params.names;
	threshold = params.threshold;
	ncolors = 24;
	zaxis_V = [min(min(min(sol{1}))), max(max(max(sol{1})))];
	
	%Threshold solution data and plot what gets input into wavecount algorithm

        for j=1:length(tspan)
            clf(fig);
	
	    %Plot voltage
            subplot(1,3,1)
            Vsol=reshape(sol{1}(j,:,:),nx,ny);
	    threshold_sol = Vsol > threshold;
            pcolor(Vsol);
            shading interp;
	    zaxis = zaxis_V;
            caxis(zaxis);
            set(gca,'Zlim',zaxis,'Ztick',zaxis, 'NextPlot', 'replacechildren');
            xlabel(['time = ' num2str(tspan(j))]);
            ylabel('V');
            colorbar;
	    drawnow;

	    %Plot wave counts
            subplot(1,3,2)
	    colormap([[1 1 1]; hsv(ncolors)]);
            pcolor(mod(cts(:,:,j),ncolors+1));
            shading flat;
            zaxis = [0 (ncolors)];
            caxis(zaxis);
            set(gca,'Zlim',zaxis,'Ztick',zaxis, 'NextPlot', 'replacechildren');
            xlabel(['time = ' num2str(tspan(j))]);
            drawnow

	    %Threshold solution data and plot what gets input into wavecount algorithm
	    subplot(1,3,3)
            colormap([[1 1 1]; hsv(ncolors)]);
            pcolor(mod(threshold_sol,ncolors+1));
            shading flat;
            zaxis = [0 (ncolors)];
            caxis(zaxis);
            set(gca,'Zlim',zaxis,'Ztick',zaxis, 'NextPlot', 'replacechildren');
            xlabel(['time = ' num2str(tspan(j))]);
            drawnow

            %Embarrassing workaround...don't look at this
            plotmult(gcf, './plots/tmp.png', 3, 'png', [6 4]);
            [X, m] = imread('./plots/tmp.png', 'png');
            f = im2frame(X, m);
            if j == 1
                [im, map] = rgb2ind(f.cdata, 256, 'nodither');
                im(1,1,1,length(tspan)) = 0;
            else
                im(:,:,1,j) = rgb2ind(f.cdata, map, 'nodither');
            end
        end
        imwrite(im, map, [filename], 'gif', 'DelayTime', 0, 'LoopCount', inf);
end

