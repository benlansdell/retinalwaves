function rhs=fn_rhs(t,EVR,dummy,allpars)
	%Now things are in the order V,R,E
	nx = allpars{1}; ny = allpars{2}; lap = allpars{4}; R2mask = allpars{5}; params = allpars{6}; noise = allpars{7}; noisedt = allpars{8};
	ep = 1;
	V=EVR(1:nx*ny);
	R=EVR(nx*ny+1:2*nx*ny);
	E=EVR(2*nx*ny+1:end);
	Er=reshape(E,nx,ny);
	
	%global variables
	global fevals;
	
	D = params(1); a = params(2); b = params(3); c = params(4); beta = params(5); beta2 = params(6); gamma = params(7); kap = params(8); v0 = params(9); lambda = params(10); dur = params(11);

	G=1./(1+exp(-kap*(V-v0)));
	rhs=[ep*(V.*(a-V).*(V-1) + noise(:,:,round(t/noisedt)+1)'.*(1-V)-R - R2mask + beta2*E);  ep*(b*V-c*R); ep*(D*reshape(lap*Er + Er*lap,nx*ny,1) + beta*G - gamma*E)];

	if any(isnan(V))
		throw(MException('Solution:NaN', 'NaN produced in solution. Not continuing. Try a different numerical method'));	
	end
	fevals = fevals + 1;
end
