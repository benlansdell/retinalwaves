function [cts, collisions] = wavecounts(sol, params, filename, minsize, nave)
        % wavecounts     Function to identify waves in solution data. Points above a threshold are identified and those adjacent to each
        %                       in either space of in time are labaled as belonging to the same wave. Points in the grid are labeled with
        %                       wave numbers in this fashion.
        %
        % Usage:
        %                       [cts, collisions] = wavedata(sol, params, filename, minsize, nave)
        %
        % Input:
        %                       solution = solution matrix output from retinal2D
        %                       params = parameter structure used to generate provided solution
	%			filename = (optional) if not empty or not 0, will plot the labeled waves alongside the voltage field
	%				of the simulation
	%			minsize = (optional, default = 2) minimum size of waves to keep track of
	%			nave = (optional, default = 0) number of averages of voltage field to take before computing counts
        %
        % Output:
        %                       cts = matrix with the same dimensions as sol containing wave numbers
        %                       collisions = list of wave numbers which have collided with another wave
        %
        % Example(s):
        %                       params = paramset('ml', 'homog', [0:1:100], 64, 'exponential');
        %                       sol = retinal2D_split(params);
        %                       counts = wavecounts(sol, params, 'testcts.gif');

        if (nargin < 2)
                throw(MException('Argin:MoreExpected', 'More input arguments expected'));
	elseif nargin < 3
		nave = 0;
		filename = 0;
		minsize = 2;
	elseif nargin < 4
		nave = 0;
		minsize = 2;
	elseif nargin < 5
		nave = 0;
        end

	threshold = params.threshold;
	nx = params.nx; ny = nx;
	tspan = params.tspan;

	%Average solution first
        e = ones(nx,1);
        b = spdiags([e e], [-1 1], nx, nx);

	Vsol = permute(sol{1}, [2,3,1]);
	%Try averaging first...
	nave = 2;
	for i = 1:nave
		for j = 1:length(tspan)
			a = Vsol(:,:,j);
			a = (a + b*a + a*b)/5;
		end	
	end
        Vsol = Vsol > threshold;

        cts = zeros(nx, ny,length(tspan));
        curwaven = 1;
        %Keep track of which waves collide with one another and remove those later on from cts
        collidedwaves = [];
        %For each time step
        for k=1:length(tspan)
                %Create a list to traverse of active grid points
		display(['Counting data for t=' num2str(tspan(k))])
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
                                                if (mappings(currpt) > 0) & (mappings(currpt) ~= prevpt)
                                                        collidedwaves = [collidedwaves; [prevpt mappings(currpt)]];
                                                end
						mappings(currpt) = prevpt;
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

        %Combine waves that have collided at some point
        for c = collidedwaves'
		%Set collided waves to zero, to ignore their existence
		c1 = c(1); c2 = c(2);
                cts(cts == c1) = c2;
		%Set collided waves to negative one, to acknowledge their existence
               	%cts(cts == c) = -1;
        end
	s = size(collidedwaves);
	collisions = unique(reshape(collidedwaves, 1, 2*s(1)));

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
