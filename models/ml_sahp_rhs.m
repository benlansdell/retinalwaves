function rhs=ml_sahp_rhs(t,EVRS,dummy,allpars)
	%Called by retinal2D with allpars = {nx,ny,h,lap,R2mask,params.modelps}
	nx = allpars{1}; ny = allpars{2}; lap = allpars{4}; params = allpars{6}; noise = allpars{7}; noisedt = allpars{8};
	%Now things are in the order V,R,E
	ep = 1;
	V=EVRS(1:nx*ny);
	R=EVRS(nx*ny+1:2*nx*ny);
	S=EVRS(2*nx*ny+1:3*nx*ny);
	E=EVRS(3*nx*ny+1:end);
	Er=reshape(E,nx,ny);
	
	%global variables
	global tfiring rg fevals;
	
	Cm = params(1); VCa = params(2); VK = params(3); VL = params(4); Vsyn = params(5); gCaM = params(6); gKM = params(7); gLM = params(8); gAChM = params(9); V1 = params(10); V2 = params(11); V3 = params(12); V4 = params(13); tauR = params(14); tauACh = params(15); D = params(16); b = params(17); delta = params(18); k = params(19); kap = params(20); v0 = params(21); lambda = params(22); dur = params(23); Vnoise = params(24); alpha = params(25); tauS = params(26); c = params(27);

	G=1./(1+exp(-kap*(V-v0)));
	gCa = gCaM*(1+tanh((V-V1)/V2))/2;
	gK = gKM*R;
	gACh = gAChM*delta*E.^2./(1+delta*E.^2);
	Lambda = cosh((V-V3)/(2*V4));
	Rinf = (1+tanh((V-V3)/V4))/2;
	
	%rhs=[(1000/Cm)*(-gCa.*(V-VCa)-gK.*(V-VK)-gLM*(V-VL)-gACh.*(V-Vsyn)-gNoiseM*firing*rg.*(V-Vnoise));(1/tauR)*gamma.*(Rinf-R);-E/tauACh + D*reshape(lap*Er + Er*lap,nx*ny,1)+b*G];
	dVdt = (1000/Cm)*(-gCa.*(V-VCa)-gK.*(V-VK)-gLM*(V-VL)-gACh.*(V-Vsyn)-noise(:,:,round(t/noisedt)+1)'.*(V-Vnoise));
	dRdt = (1/tauR)*(Lambda.*(Rinf-R) + alpha*S.*(1-R));
	laplacian = reshape(lap*Er + Er*lap,nx*ny,1);
	dEdt = -E/tauACh + D*laplacian+b*G;
	dSdt = -S/tauS + c*G;
	%display(['t=' num2str(t) ' max(V)=' num2str(max(V)) ' V=' num2str(V(64*30+30)) ' R=' num2str(R(64*30+30)) ' E=' num2str(E(64*30+30)) ' dVdt=' num2str(dVdt(64*30+30))  ' dRdt=' num2str(dRdt(64*30+30)) ' dEdt=' num2str(dEdt(64*30+30))])
	%display(['t=' num2str(t) ' max(E)=' num2str(max(E)) ' V=' num2str(V(64*30+30)) ' R=' num2str(R(64*30+30)) ' E=' num2str(E(64*30+30)) ' dVdt=' num2str(dVdt(64*30+30))  ' dRdt=' num2str(dRdt(64*30+30)) ' dEdt=' num2str(dEdt(64*30+30))])
	rhs=[dVdt;dRdt;dSdt;dEdt];

        if any(isnan(V))
                throw(MException('Solution:NaN', 'NaN produced in solution. Not continuing. Try a different numerical method'));
        end
	fevals = fevals + 1;
end
