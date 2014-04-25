function jac=fn_jacobian(t,EVR,dummy,allpars)
	%Return Jacobian of Fitzhugh Nagumo model
	nx = allpars{1}; ny = allpars{2}; params = allpars{6};
	V=EVR(1,:,:); %nx*nx
	R=EVR(2,:,:); %nx*nx
	E=EVR(3,:,:); %nx*nx
	
	jacobian = zeros(3,3,nx,ny);

	%global variables
	global tfiring rg;
	
	D = params(1); a = params(2); b = params(3); c = params(4); beta = params(5); beta2 = params(6); gamma = params(7); cnoise = params(8); noise = params(9); kap = params(10); v0 = params(11); lambda = params(12); dur = params(13);

	%G=1./(1+exp(-kap*(V-v0)));
	Gprime = ;
	%dVdt = V.*(a-V).*(V-1) - R + beta2*E
	%dRdt = b*V - c*R;
	%dEdt = beta*G - gamma*E;

	df1dV = 2*a*V-3*V.^2+2*V-a;
	df1dR = -ones(nx,ny);
	df1dE = beta2*ones(nx,ny);
	df2dV = b*ones(nx,ny);
	df2dR = c*ones(nx,ny);
	df2dE = zeros(nx,ny);
	df3dV = beta*kap*exp(-kap*(V-v0))./((1+exp(-kap*(V-v0))).^2);
	df3dR = zeros(nx,ny);
	df3dE = -gamma*ones(nx,ny);
	
	jac(1,1,:,:) = df1dV;
	jac(1,2,:,:) = df1dR;
	jac(1,3,:,:) = df1dE;
	jac(2,1,:,:) = df2dV;
	jac(2,2,:,:) = df2dR;
	jac(2,3,:,:) = df2dE;
	jac(3,1,:,:) = df3dV;
	jac(3,2,:,:) = df3dR;
	jac(3,3,:,:) = df3dE;

	if any(isnan(V))
		throw(MException('Solution:NaN', 'NaN produced in solution. Not continuing. Try a different numerical method'));	
	end
end
