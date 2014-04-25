function plotcounts(cts, filename, options) 
	%plotcounts       Plot the solution as a heatmap for all times specified. Output to gif file
	%
	% Usage:
	%                       plotsol(EVRt_sol, filename, options, zaxis)
	%
	% Input:
	%                       cts = matrix output from wavecounts() containing numbered waves
	%                       filename = save plot to this file
	%			options = output from retinal2D.m containing options used in generating solution
	%
	% Examples:
        %                       ics = loadics('randomIC');
        %                       params = paramset('stdP');
        %                       [sol, opts] = retinal2D(ics, params);
        %                       cts = wavecounts(sol, opts);
        %                       plotcounts(cts, './plots/testcts.gif', opts);

	close all;
	fig = figure;

	nx = options{1}; ny = options{2}; tspan = options{3}; nbc = options{4};

        if (nargin < 3)
                throw(MException('Argin:MoreExpected', 'More input arguments expected'));
        end

	nwaves = max(max(max(cts)));
	mp = colormap(lines);
	mp = [mp; 1.0 1.0 1.0];
	%mp = mp(1:(nwaves+1),:)

        for j=1:length(tspan)
	    clf(fig);
	    A=image(cts(:,:,j)+1, 'CDataMapping', 'direct');
	    colormap(mp);
	    drawnow 
	    %Embarrassing workaround...don't look at this
	    imwrite(A, mp, './plots/tmp.png', 'png');
	    saveplot(gcf, './plots/tmp.png', 'png');
	    %saveplot(gcf, ['./plots/tmp' num2str(j) '.png'], 'png');
	    [X, m] = imread('./plots/tmp.png', 'png');
	    f = im2frame(X, m);
	    %f = im2frame(cts(:,:,j)+1, mp);
	    if j == 1
	        [im, map] = rgb2ind(f.cdata, mp, 'nodither');
		im(1,1,1,length(tspan)) = 0;
	    else
	        im(:,:,1,j) = rgb2ind(f.cdata, mp, 'nodither');
	    end
        end
	imwrite(im, map, [filename], 'gif', 'DelayTime', 0, 'LoopCount', inf);
