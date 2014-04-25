function rg = randgrid(nx,ny,k)

	rg = rand(nx, ny);
	rns = sort(reshape(rg, 1, nx*ny));
	threshold = rns(k);
	rg = (rg <= threshold);
