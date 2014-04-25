function rhs=ml_sahp_rhs_split(t,EVR,allpars)
	%Called by retinal2D with allpars = {nx,ny,h,lap,R2mask,params.modelps}
	nx = allpars{1}; ny = allpars{2}; params = allpars{3}; noise = allpars{4}; noisedt = allpars{5}; I_app = allpars{6};
	%Now things are in the order V,R,E
        V=EVR(:,:,1);
        R=EVR(:,:,2);
	S=EVR(:,:,3);
        E=EVR(:,:,4);
	
	%global variables
	global tfiring rg fevals nanproduced;
	
	Cm = params(1); VCa = params(2); VK = params(3); VL = params(4); Vsyn = params(5); gCaM = params(6); gKM = params(7); gLM = params(8); gAChM = params(9); V1 = params(10); V2 = params(11); V3 = params(12); V4 = params(13); tauR = params(14); tauACh = params(15); D = params(16); b = params(17); delta = params(18); k = params(19); kap = params(20); v0 = params(21); lambda = params(22); dur = params(23); Vnoise = params(24); alpha = params(25); tauS = params(26); c = params(27);

	G=1./(1+exp(-kap*(V-v0)));
	gCa = gCaM*(1+tanh((V-V1)/V2))/2;
	gK = gKM*R;
	gACh = gAChM*delta*E.^2./(1+delta*E.^2);
	Lambda = cosh((V-V3)/(2*V4));
	Rinf = (1+tanh((V-V3)/V4))/2;
	
	dVdt = (1000/Cm)*(-gCa.*(V-VCa)-gK.*(V-VK)-gLM*(V-VL)-gACh.*(V-Vsyn)-noise(:,:,round(t/noisedt)+1).*(V-Vnoise) + I_app(:,:,round(t/noisedt)+1));
	dRdt = (1/tauR)*(Lambda.*(Rinf-R) + alpha*S.*(1-R));
	dSdt = 0;
	dEdt = -E/tauACh + b*G;
	%display(['t=' num2str(t) ' max(V)=' num2str(max(V)) ' V=' num2str(V(64*30+30)) ' R=' num2str(R(64*30+30)) ' E=' num2str(E(64*30+30)) ' dVdt=' num2str(dVdt(64*30+30))  ' dRdt=' num2str(dRdt(64*30+30)) ' dEdt=' num2str(dEdt(64*30+30))])
	%display(['t=' num2str(t) ' max(E)=' num2str(max(E)) ' V=' num2str(V(64*30+30)) ' R=' num2str(R(64*30+30)) ' E=' num2str(E(64*30+30)) ' dVdt=' num2str(dVdt(64*30+30))  ' dRdt=' num2str(dRdt(64*30+30)) ' dEdt=' num2str(dEdt(64*30+30))])

        rhs = zeros(nx,ny,4);
        rhs(:,:,1) = dVdt;
        rhs(:,:,2) = dRdt;
	rhs(:,:,3) = dSdt;
        rhs(:,:,4) = dEdt;

        if any(isnan(V))
                throw(MException('Solution:NaN', 'NaN produced in solution, not continuing. Try a different numerical method'));
        end
	fevals = fevals + 1;
end
