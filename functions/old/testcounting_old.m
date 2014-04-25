function cts = testcounting
        nx = 5; ny = 5; tspan = 5;
        Vsol = zeros(nx, ny, tspan);

	%Test some waves being formed
	Vsol(:,:,1) = [[0 0 0 0 0];[0 0 0 0 0];[0 0 0 0 0];[0 0 0 0 0];[0 0 0 0 0]];
	Vsol(:,:,2) = [[0 1 0 0 0];[0 0 0 0 0];[0 0 0 0 0];[0 0 0 0 0];[0 0 0 0 0]];
	Vsol(:,:,3) = [[1 0 1 0 0];[1 1 0 0 0];[0 0 0 0 0];[0 0 0 0 1];[0 0 0 0 1]];
	Vsol(:,:,4) = [[0 0 0 0 0];[1 0 0 0 0];[1 1 0 0 1];[0 0 0 0 1];[0 0 1 1 0]];
	Vsol(:,:,5) = [[1 1 1 1 1];[0 1 0 0 0];[0 0 0 0 0];[0 0 0 0 0];[1 0 0 0 0]];

	%Test a collision
	Vsol(:,:,1) = [[0 0 0 0 0];[0 0 0 0 0];[0 0 0 0 0];[0 0 0 0 0];[0 0 0 0 0]];
	Vsol(:,:,2) = [[0 0 0 0 0];[0 1 0 1 0];[0 0 0 0 0];[0 0 0 0 0];[0 0 0 1 0]];
	Vsol(:,:,3) = [[0 0 0 0 0];[0 1 0 1 0];[0 0 0 1 0];[0 0 0 0 0];[0 0 0 1 0]];
	Vsol(:,:,4) = [[0 0 0 0 0];[0 0 0 0 0];[0 0 0 1 0];[0 0 0 1 0];[0 0 0 0 0]];
	Vsol(:,:,5) = [[0 0 0 0 0];[0 1 0 0 0];[0 0 0 0 0];[0 0 0 0 0];[0 0 0 0 0]];

	%Test another collision
	Vsol(:,:,1) = [[0 0 0 0 0];[0 0 0 0 0];[0 0 0 0 0];[0 0 0 0 0];[0 0 0 0 0]];
	Vsol(:,:,2) = [[0 0 0 0 0];[0 0 0 0 0];[1 0 1 0 1];[0 0 0 0 0];[0 0 0 0 0]];
	Vsol(:,:,3) = [[0 0 0 0 0];[0 0 0 0 0];[0 1 1 1 0];[0 0 0 0 0];[0 0 0 0 0]];
	Vsol(:,:,4) = [[0 0 0 0 0];[0 0 0 0 0];[0 0 0 1 0];[0 0 0 1 0];[0 0 0 0 0]];
	Vsol(:,:,5) = [[0 0 0 0 0];[0 1 0 0 0];[0 0 0 0 0];[0 0 0 0 0];[0 0 0 0 0]];

        cts = zeros(nx, ny, tspan);
        curwaven = 1;
        %Keep track of which waves collide with one another and remove those later on from cts
        collidedwaves = [];
        %For each time step
        for k=1:tspan
                %Create a list to traverse of active grid points
                tmpcts = zeros(nx, ny);
                [is,js] = find(Vsol(:,:,k));
                tmpwaven = 1;
                totraverse = [is, js];
                while ~isempty(totraverse)
                        curpt = totraverse(1,:);
                        [tmpcts, totraverse] = traverse(tmpcts, tmpwaven, totraverse, curpt);
                        tmpwaven = tmpwaven + 1;
                end
		tmpcts
                %Now that current waves have been listed we need to relate these to previous waves
                %Create a list of mappings from tmp waves to permanent waves
                %For the moment, only look one step behind
		%Bursting behaviour may mean we have to look further back to avoid splitting waves into 
		%Different numbers...until model exhibits bursting this should be fine
		%This can be fixed by simply adding more pts in the prevpts array from earlier times.
		%That should be easy
		k
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
                                prevpts = [cts(i,j,k-1) cts(im1,j,k-1) cts(ip1,j,k-1) cts(i,jm1,k-1) cts(i,jp1,k-1)]
                                currpt = tmpcts(i,j)
                                for prevpt=prevpts
                                        if prevpt > 0
                                                if mappings(currpt) == 0
                                                        mappings(currpt) = prevpt;
                                                elseif (mappings(currpt) > 0) & (mappings(currpt) ~= prevpt)
                                                        collidedwaves = [collidedwaves prevpt mappings(currpt)];
                                                        %mappings(currpt) = -1;
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

			mappings

                        %Then add these to cts matrix thing
                        tmp = zeros(nx,ny);
                        for m = 1:length(mappings)
                                %if mappings(m) ~= -1
                                        tmp(tmpcts == m) = mappings(m);
                                %end
                        end
                        cts(:,:,k) = tmp;
			a = cts(:,:,k)
                %Or none if the case may be...
                else
                        cts(:,:,k) = tmpcts;
                        curwaven = tmpwaven;
                end
        end

        %Remove all collision labels from cts matrix
        collisions = unique(collidedwaves)
        %cts(cts == -1) = 0;
        for c = collisions
                cts(cts == c) = -1;
        end
end

function [tmpcts, totraverse] = traverse(tmpcts, tmpwaven, totraverse, curpt)
        i = curpt(1);, j = curpt(2);
        if ismember(curpt, totraverse, 'rows')
                tmpcts(i,j) = tmpwaven;
                %Remove current item from list
                totraverse = setdiff(totraverse, curpt, 'rows');
                %Then recursively travel through adjacent points, finding all adjacent active sites and
                %adding them to tmpcts
                [tmpcts, totraverse] = traverse(tmpcts, tmpwaven, totraverse, [i, j+1]);
                [tmpcts, totraverse] = traverse(tmpcts, tmpwaven, totraverse, [i, j-1]);
                [tmpcts, totraverse] = traverse(tmpcts, tmpwaven, totraverse, [i+1, j]);
                [tmpcts, totraverse] = traverse(tmpcts, tmpwaven, totraverse, [i-1, j]);
        end
end
