function [cts, collisions] = wavecounts(sol, params, filename, minsize)
        % wavecounts     Function to identify waves in solution data. Points above a threshold are identified and those adjacent to each
        %                       in either space of in time are labaled as belonging to the same wave. Points in the grid are labeled with
        %                       wave numbers in this fashion.
        %
        % Usage:
        %                       [cts, collisions] = wavedata(sol, params, filename)
        %
        % Input:
        %                       solution = solution matrix output from retinal2D
        %                       params = parameter structure used to generate provided solution
	%			filename = (optional) if not empty or not 0, will plot the labeled waves alongside the voltage field
	%				of the simulation
	%			minsize = (optional, default = 2) minimum size of waves to keep track of
        %
        % Output:
        %                       cts = matrix with the same dimensions as sol containing wave numbers
        %                       collisions = list of wave numbers which have collided with another wave
        %
        % Example(s):
        %                       params = paramset('ml', 'homog', [0:1:100], 64, 'exponential');
        %                       sol = retinal2D_split(params);
        %                       counts = wavecounts(sol, params);
        %                       plotcounts(counts);

        if (nargin < 2)
                throw(MException('Argin:MoreExpected', 'More input arguments expected'));
	elseif nargin < 3
		filename = 0;
		minsize = 2;
	elseif nargin < 4
		minsize = 2;
        end

	threshold = params.threshold;
	nx = params.nx; ny = nx;
	tspan = params.tspan;

        Vsol = permute(sol{1} > threshold, [2, 3, 1]);

        cts = zeros(nx, ny,length(tspan));
        curwaven = 1;
        %Keep track of which waves collide with one another and remove those later on from cts
        collidedwaves = [];
        %For each time step
        for k=1:length(tspan)
                %Create a list to traverse of active grid points
                tmpcts = zeros(nx, ny);
                [is,js] = find(Vsol(:,:,k));
                tmpwaven = 1;
                totraverse = [is, js];
                while ~isempty(totraverse)
                        [tmpcts, totraverse] = traverse(tmpcts, tmpwaven, totraverse);
                        tmpwaven = tmpwaven + 1;
                end
                %Now that current waves have been listed we need to relate these to previous waves
                %Create a list of mappings from tmp waves to permanent waves
                %For the moment, only look one step behind
		%Bursting behaviour may mean we have to look further back to avoid splitting waves into 
		%Different numbers...until model exhibits bursting this should be fine
		%This can be fixed by simply adding more pts in the prevpts array from earlier times.
		%That should be easy
                if k > 1
                        totraverse = [is, js];
			totraverse;
                        mappings = zeros(tmpwaven-1,1);
                        for I=totraverse'
                                i = I(1);
				j = I(2);
				im1 = max(i-1,1);
				ip1 = min(i+1,nx);
				jm1 = max(j-1,1);
				jp1 = min(j+1,ny);
                                prevpts = [cts(i,j,k-1) cts(im1,j,k-1) cts(ip1,j,k-1) cts(i,jm1,k-1) cts(i,jp1,k-1)];
                                currpt = tmpcts(i,j);
                                for prevpt=prevpts
                                        if prevpt > 0
                                                if mappings(currpt) == 0
                                                        mappings(currpt) = prevpt;
                                                elseif (mappings(currpt) > 0) & (mappings(currpt) ~= prevpt)
                                                        collidedwaves = [collidedwaves prevpt mappings(currpt)];
                                                        mappings(currpt) = -1;
                                                end
                                        end
                                end
                        end

                        %Then go through and assign those which haven't been assigned wave numbers yet
                        %a new wave number.
                        for m = 1:length(mappings)
                                if mappings(m) == 0
                                        mappings(m) = curwaven;
                                        curwaven = curwaven + 1;
                                end
                        end    

                        %Then add these to cts matrix thing
                        tmp = zeros(nx,ny);
                        for m = 1:length(mappings)
                                if mappings(m) ~= -1
                                        tmp(tmpcts == m) = mappings(m);
                                end
                        end
                        cts(:,:,k) = tmp;
                %Or none if the case may be...
                else
                        cts(:,:,k) = tmpcts;
                        curwaven = tmpwaven;
                end
        end

        %Remove all collision labels from cts matrix
        collisions = unique(collidedwaves);
        cts(cts == -1) = 0;
        for c = collisions
		%Set collided waves to zero, to ignore their existence
                cts(cts == c) = 0;
		%Set collided waves to negative one, to acknowledge their existence
                %cts(cts == c) = -1;
        end

	%Remove waves which are below minsize
	for n = 1:curwaven
		if sum(sum(sum(cts == n))) < minsize
			cts(cts == n) = 0;
		end
	end

	if filename ~= 0
		plotcounts(cts, sol, params, filename);
	end
end

function plotcounts(cts, sol, params, filename)

	close all;
        fig = figure;

        nx = params.nx; ny = nx; tspan = params.tspan; nbc = params.nbc; names = params.names;
	ncolors = 24;
	zaxis_V = [min(min(min(sol{1}))), max(max(max(sol{1})))];

        for j=1:length(tspan)
            clf(fig);
	
	    %Plot voltage
            subplot(1,2,1)
            Vsol=reshape(sol{1}(j,:,:),nx,ny);
            pcolor(Vsol);
            shading interp;
	    zaxis = zaxis_V;
            caxis(zaxis);
            set(gca,'Zlim',zaxis,'Ztick',zaxis, 'NextPlot', 'replacechildren');
            xlabel(['time = ' num2str(tspan(j))]);
            ylabel('V');
            colorbar;
	    %freezeColors; %cbfreeze(colorbar);
	    drawnow;

	    %Plot wave counts
            subplot(1,2,2)
	    colormap(hsv(ncolors));
            pcolor(mod(cts(:,:,j),ncolors));
            shading flat;
            zaxis = [0 (ncolors-1)];
            caxis(zaxis);
            set(gca,'Zlim',zaxis,'Ztick',zaxis, 'NextPlot', 'replacechildren');
            xlabel(['time = ' num2str(tspan(j))]);
	    %freezeColors;% cbfreeze(colorbar);
            drawnow

            %Embarrassing workaround...don't look at this
            plotmult(gcf, './plots/tmp.png', 2);
            [X, m] = imread('./plots/tmp.png', 'png');
            f = im2frame(X, m);
            if j == 1
                [im, map] = rgb2ind(f.cdata, 256, 'nodither');
                im(1,1,1,length(tspan)) = 0;
            else
                im(:,:,1,j) = rgb2ind(f.cdata, map, 'nodither');
            end
        end
        imwrite(im, map, ['./plots/' filename], 'gif', 'DelayTime', 0, 'LoopCount', inf);
end

function plotmult(h, filename, nframes)
        dev = '-dpng';
        set(h, 'paperunits', 'inches');
        set(h, 'papersize', [9*nframes 6]);
        set(h, 'paperposition', [0 0 6*nframes 4]);
        print(h, filename, dev, '-painters');
end
