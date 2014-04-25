function plotprofile3d(EVRt_sol, filename, options) 
        %plotprofile3d		Plot the time evolution at a single point (the center of the domain) of the
	%                       voltage, refractory and excitatory variable.
        %
        % Usage:
        %                       plotprofile(EVRt_sol, filename, options)
        %
        % Input:
        %                       EVRt_sol = solution output from retinal2D.m
        %                       filename = output file names: filename
	%			options = output from retinal2D.m containing options used in generating solution
        %
        % Examples:
        %                       tspan = 0:1:50;
        %                       fn = './plots/test.eps';
        %                       [sol, options] = retinal2D(loadics('randomIC'), paramset('stdP'), tspan);
        %                       plotprofile3d(sol, fn, options);

	close all;

        if (nargin < 3)
                throw(MException('Argin:MoreExpected', 'More input arguments expected'));
        end

	nx = options{1}; ny = options{2}; tspan = options{3}; nbc = options{4};

	E = []; V = []; R = [];
        for j=1:length(tspan)
            Esol=ifft2(reshape(EVRt_sol(j,1:nx*ny),nx,ny)).';
            Vsol=ifft2(reshape(EVRt_sol(j,(nx*ny+1):(2*nx*ny)),nx,ny)).';
            Rsol=ifft2(reshape(EVRt_sol(j,(2*nx*ny+1):end),nx,ny)).';
	    E = [E real(Esol(floor(nx/2),floor(ny/2)))];
	    V = [V real(Vsol(floor(nx/2),floor(ny/2)))];
	    R = [R real(Rsol(floor(nx/2),floor(ny/2)))];
        end
	figure

	cmap = colormap;
	% change c into an index into the colormap
	% min(c) -> 1, max(c) -> number of colors
	c = round(1+(size(cmap,1)-1)*(tspan - min(tspan))/(max(tspan)-min(tspan)));
	% make a blank plot
	plot3(E,V,R,'linestyle','none')
	% add line segments
	for k = 1:(length(V)-1)
		line(E(k:k+1),V(k:k+1),R(k:k+1),'color',cmap(c(k),:))
	end
	colorbar
	grid on
	%plot3(E, V, R); 
	xlabel('E field'); ylabel('V field'); zlabel('R field'); drawnow
        saveplot(gcf, [filename]);
