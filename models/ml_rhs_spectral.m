function rhs=ml_rhs_spec(t,EVRt,dummy,allpars)
        %Called by retinal2D_spec with allpars = {nx,ny,k2,R2mask,params.modelps}
        nx = allpars{1}; ny = allpars{2}; k2 = allpars{3}; R2mask = allpars{4}; params = allpars{5}; noise = allpars{6}; noisedt = allpars{7};
	%Now things are in the order V,R,E

        Vt=EVRt(1:nx*ny);
        Rt=EVRt(nx*ny+1:2*nx*ny);
        Et=EVRt(2*nx*ny+1:end);
        E=ifft2(reshape(Et,nx,ny));
        V=ifft2(reshape(Vt,nx,ny));
        R=ifft2(reshape(Rt,nx,ny));

	%global variables
	global fevals;
        Cm = params(1); VCa = params(2); VK = params(3); VL = params(4); Vsyn = params(5); gCaM = params(6); gKM = params(7); gLM = params(8); gAChM = params(9); V1 = params(10); V2 = params(11); V3 = params(12); V4 = params(13); tauR = params(14); tauACh = params(15); D = params(16); b = params(17); delta = params(18); k = params(19); kap = params(20); v0 = params(21); lambda = params(22); dur = params(23); Vnoise = params(24);

	G=1./(1+exp(-kap*(V-v0)));
	gCa = gCaM*(1+tanh((V-V1)/V2))/2;
	gK = gKM*R;
	gACh = gAChM*delta*E.^2./(1+delta*E.^2);
	gamma = cosh((V-V3)/(2*V4));
	Rinf = (1+tanh((V-V3)/V4))/2;
	
	rhs=[reshape(fft2((1000/Cm)*(-gCa.*(V-VCa)-gK.*(V-VK)-gLM*(V-VL)-gACh.*(V-Vsyn)-noise(:,:,round(t/noisedt)+1).*(V-Vnoise))),nx*ny,1);...
		reshape(fft2((1/tauR)*gamma.*(Rinf-R)),nx*ny,1);...
		reshape(fft2(-E/tauACh + b*G),nx*ny,1)-D*k2.*Et];
        if any(isnan(V))
                throw(MException('Solution:NaN', 'NaN produced in solution. Not continuing. Try a different numerical method. Failed at t=%f.', t));
        end

	fevals = fevals + 1;
end
