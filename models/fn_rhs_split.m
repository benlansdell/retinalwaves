function rhs=fn_rhs_split(t,EVR,allpars)

	nx = allpars{1}; ny = allpars{2}; params = allpars{3}; noise = allpars{4}; noisedt = allpars{5};
	V=EVR(:,:,1);
	R=EVR(:,:,2);
	E=EVR(:,:,3);
	
	%global variables
	global fevals;
	
	D = params(1); a = params(2); b = params(3); c = params(4); beta = params(5); beta2 = params(6); gamma = params(7); kap = params(8); v0 = params(9); lambda = params(10); dur = params(11);

	G=1./(1+exp(-kap*(V-v0)));
	dVdt = V.*(a-V).*(V-1) + noise(:,:,round(t/noisedt)+1).*(1-V)-R +beta2*E;
	dRdt = b*V - c*R;
	dEdt = beta*G - gamma*E;
	rhs = zeros(nx,ny,3);
	rhs(:,:,1) = dVdt;
	rhs(:,:,2) = dRdt;
	rhs(:,:,3) = dEdt;

	if any(isnan(V))
		throw(MException('Solution:NaN', 'NaN produced in solution. Not continuing. Try a different numerical method'));	
	end
	fevals = fevals + 1;
end
