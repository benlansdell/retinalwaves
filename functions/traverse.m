function [tmpcts, totraverse] = traverse(tmpcts, tmpwaven, totraverse)
	%Adapted from http://stackoverflow.com/questions/4002873/i-want-flood-fill-without-stack-and-without-recursion
	%Thanks!

	%tmpcts
	%tmpwaven
	%totraverse
	%pause
	curpt = totraverse(1,:);
	s = size(totraverse);
	a = zeros(s(1), 1);
        i = curpt(1);
	j = curpt(2);
	c = 1;
	while (c > 0)
		%Store breadcrumb trail, look to carry on
		c = c + 1;
		%Find location of curpt and update
		[~, idx] = ismember([i,j], totraverse, 'rows');
		a(idx) = c;
		%display(['Current point is i=' num2str(i) ' j=' num2str(j) ' c=' num2str(c) ' updated a at position ' num2str(idx)]);
		%Find the next adjacent 0 and move to that location
		[t, i, j] = hunt(a, i, j, 0, totraverse);
		if t
			[~, idx] = ismember([i,j], totraverse, 'rows');
			%display(['Found an adjacent 0 at i=' num2str(i) ', j=' num2str(j)]);
		else
	        	%If nowhere to go back-track by looking for breadcrumb
        		a(idx) = -1;
        		c = c - 1;
			%Look for previous step and move to there
        		[t, i, j] = hunt(a, i, j, c, totraverse);
			%display(['Found no adjacent 0. Backtracking to i=' num2str(i) ' j=' num2str(j) ' setting c=' num2str(c)])
			c = c- 1;
		end
		%pause
	end
	
	%Add all non-zero entries to tmpcts and remove from totraverse
	for i = 1:s
		if a(idx) ~= 0
			x = totraverse(i,1); y = totraverse(i,2);
			tmpcts(x,y) = tmpwaven;
		end
	end
	totraverse = totraverse(a == 0,:);
end

function [t, x, y] = hunt(a, x, y, v, totraverse)
    %display(['Hunting for: ' num2str(v) ' adjacent to i= ' num2str(x) ', j = ' num2str(y)]);
    t = 0;
    [~, idx1] = ismember([x-1,y], totraverse, 'rows');
    [~, idx2] = ismember([x+1,y], totraverse, 'rows');
    [~, idx3] = ismember([x,y-1], totraverse, 'rows');
    [~, idx4] = ismember([x,y+1], totraverse, 'rows');
    if idx1 & (a(idx1) == v)
	x = x - 1; t = 1; return;
    end
    if idx2 & (a(idx2) == v)
	x = x + 1; t = 1; return;
    end
    if idx3 & (a(idx3) == v)
	y = y - 1; t = 1; return;
    end
    if idx4 & (a(idx4) == v)
	y = y + 1; t = 1; return;
    end
end
