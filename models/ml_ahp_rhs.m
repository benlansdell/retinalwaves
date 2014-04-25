function rhs=ml_ahp_rhs(t,EVR,dummy,allpars)
	%Called by retinal2D with allpars = {nx,ny,h,lap,R2mask,params.modelps}
	nx = allpars{1}; ny = allpars{2}; lap = allpars{4}; params = allpars{6};
	%Now things are in the order V,R,E
	ep = 1;
	V=EVR(1:nx*ny);
	R=EVR(nx*ny+1:2*nx*ny);
	E=EVR(2*nx*ny+1:end);
	Er=reshape(E,nx,ny);
	
	%global variables
	global noise_firing_start noise_firing_end rg;

	Cm = params(1); VCa = params(2); VK = params(3); VL = params(4); Vsyn = params(5); gCaM = params(6); gKM = params(7); gLM = params(8); gAChM = params(9); V1 = params(10); V2 = params(11); tauR = params(12); tauACh = params(13); D = params(14); b = params(15); delta = params(16); k = params(17); kap = params(18); v0 = params(19); lambda = params(20); dur = params(21); gNoiseM = params(22); Vnoise = params(23); alpha = params(24);

	%Add noise to voltage every so often....
	%The duration of noise added is random too....
	if t < 0.1
		rg = zeros(nx*ny,1);
		noise_firing = 0;
		noise_firing_start = 0;
		noise_firing_end = 0;
	elseif t < noise_firing_start
		noise_firing = 0;
	elseif t < noise_firing_end
		noise_firing = 1;
	else
		noise_firing = 0;
		t
		noise_firing_start = t + exprnd(1/(nx*ny*lambda));
		noise_firing_end = noise_firing_start + dur;
		rg = randgrid(nx*ny,1,1);
	end

	G=1./(1+exp(-kap*(V-v0)));
	gCa = gCaM*(1+tanh((V-V1)/V2))/2;
	gK = gKM*R;
	gACh = gAChM*delta*E.^2./(1+delta*E.^2);
	
	dVdt = (1000/Cm)*(-gCa.*(V-VCa)-gK.*(V-VK)-gLM*(V-VL)-gACh.*(V-Vsyn)-gNoiseM*noise_firing*rg.*(V-Vnoise));
	dRdt = (1/tauR)*(alpha*E.*(1-R)-R);
	dEdt = (1/tauACh)*(-E + D*reshape(lap*Er + Er*lap,nx*ny,1)+b*G);
	%display(['t=' num2str(t) ' max(V)=' num2str(max(V)) ' V=' num2str(V(64*30+30)) ' R=' num2str(R(64*30+30)) ' E=' num2str(E(64*30+30)) ' dVdt=' num2str(dVdt(64*30+30))  ' dRdt=' num2str(dRdt(64*30+30)) ' dEdt=' num2str(dEdt(64*30+30))])
	%display(['t=' num2str(t) ' max(E)=' num2str(max(E)) ' V=' num2str(V(64*30+30)) ' R=' num2str(R(64*30+30)) ' E=' num2str(E(64*30+30)) ' dVdt=' num2str(dVdt(64*30+30))  ' dRdt=' num2str(dRdt(64*30+30)) ' dEdt=' num2str(dEdt(64*30+30))])
	rhs=[dVdt;dRdt;dEdt];
        if any(isnan(V))
                throw(MException('Solution:NaN', 'NaN produced in solution. Not continuing. Try a different numerical method'));
        end
end
