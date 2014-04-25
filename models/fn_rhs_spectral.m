function rhs=fn_rhs_spectral(t,EVRt,dummy,allpars)
	%Called by retinal2D_spec with allpars = {nx,ny,k2,R2mask,params.modelps}
	nx = allpars{1}; ny = allpars{2}; k2 = allpars{3}; R2mask = allpars{4}; params = allpars{5}; noise = allpars{6}; noisedt = allpars{7};
	%Now things are in the order V,R,E
	ep = 1;
	Vt=EVRt(1:nx*ny);
	Rt=EVRt(nx*ny+1:2*nx*ny);
	Et=EVRt(2*nx*ny+1:end);
	E=ifft2(reshape(Et,nx,ny));
	V=ifft2(reshape(Vt,nx,ny));
	R=ifft2(reshape(Rt,nx,ny));
	
	%global variables
	global fevals;
	
	D = params(1); a = params(2); b = params(3); c = params(4); beta = params(5); beta2 = params(6); gamma = params(7); kap = params(8); v0 = params(9); lambda = params(10); dur = params(11);

	Gt=reshape(fft2(1./(1+exp(-kap*(V-v0)))),nx*ny,1);
	rhs=[ep*(reshape(fft2(V.*(a-V).*(V-1) + noise(:,:,round(t/noisedt)+1)'.*(1-V)),nx*ny,1)-Rt - R2mask + beta2*Et);  ep*(b*Vt-c*Rt); ep*(-D*k2.*Et + beta*Gt - gamma*Et)];

        if any(isnan(V))
                throw(MException('Solution:NaN', 'NaN produced in solution. Not continuing. Try a different numerical method'));
        end
	fevals = fevals + 1;
end
