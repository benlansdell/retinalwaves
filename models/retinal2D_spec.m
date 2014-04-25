function sol = retinal2D_spec(params, solver)
        % retinal2D             Run simulations of 2D retinal wave model with given model, parameters and initial conditions and
	%                       sequences of images of solution evaluated at specified times. Solve using spectral methods
        %
        % Usage:
        %                       sol = retinal2D_spec(params, solver)
        %
        % Input:
	%                       params = structure of parameters generally from output of parameters() function
        %                       solver = (optional, default = 'ode45') string specifying ODE solver to use. Choose from
        %                               one of MATLAB's in-built, or from ode4 (4th order Runge-Kutta) or ode1 (Forward Euler).
        %                               The latter two are fixed-step size solvers, and use a step size of 0.001
        %
	%
        % Output:
        %			sol = cell-array of solution data
	%
        % Example(s):
	%			model = 'fn';
	%			params = parameters(model, 'random');
        %                       sol = retinal2D_spec(params);
	%			plotsol(sol, 'test.gif', params);

	if (nargin < 1)
		throw(MException('Argin:Error', 'More input arguments expected'));
	elseif (nargin < 2)
		solver = 'ode45';
	end

	global fevals;
	fevals = 0;

	hsolver = str2func(solver);
	nx = params.nx;
	ics = params.ics;
	nbc = params.nbc;
	tspan = params.tspan;
	t_start = tspan(1);
	t_end = tspan(end);
	noisedt = params.noiseStepSize;

	%Setup to domain
	Lx=params.length; x2=linspace(-Lx/2,Lx/2,nx+1); x=x2(1:nx);  % space variables
	Ly=Lx; ny=nx; y2=linspace(-Ly/2,Ly/2,ny+1); y=y2(1:ny);

	kx=(2*pi/Lx)*[0:nx/2-1 -nx/2:-1].';
	ky=(2*pi/Ly)*[0:ny/2-1 -ny/2:-1].';

	[X,Y]=meshgrid(x,y);
	[KX,KY]=meshgrid(kx,ky);
	K=KX.^2+KY.^2;
	k2=reshape(K,nx*ny,1);

	%Boundary mask
	nbc=5;
	fx=0.*x; fy=0.*y; 
	fx(1:nbc)=ones(1,nbc);
	fx(end-nbc+1:end)=ones(1,nbc);
	fy(1:nbc)=ones(1,nbc);
	fy(end-nbc+1:end)=ones(1,nbc);
	[FX,FY]=meshgrid(fx,fy);
	%Why is this FX+FY?
	Rmask=fft2(FX+FY);
	R2mask=reshape(Rmask,nx*ny,1);

	%Add variable recovery. Not implemented yet
	%cvar=abs(c*(1+cnoise*randn(nx,ny)));
	%ifft(noiseV*(randn(nx,ny)+i*randn(nx,ny)));
	%cvar = c + c*abs(cnoise*real(ifft(rand(nx,ny)+i*rand(nx,ny))));

	initial = [];
	sol = {};
	for j=1:params.n
		ic = fft2(ics{j});
		initial = [initial, reshape(ic,1,nx*ny)];
		sol{j} = zeros(length(tspan),nx,ny);
	end

	%rng default;
        uniform = rand(nx,ny,length(t_start:noisedt:t_end)); %Generate all the noise for our simulation now
        noise = params.fnoise(uniform); %Transform it to the right form

	opts = odeset('RelTol', 0.001);
	opts.StepSize = 0.001;
	display(['Solving transformed PDE using ' solver])
	tic;
	[t,solt]=hsolver(params.spectralrhs,tspan,initial,opts,{nx,ny,k2,R2mask,params.modelps,noise, noisedt});
	toc

	display('Found solution. Transforming data back to spatial domain')
        for j=1:length(tspan)
		for k=1:params.n
        		%jsol=real(ifft2(reshape(solt(j,(k-1)*nx*ny+1:k*nx*ny),nx,ny)).');
        		jsol=real(ifft2(reshape(solt(j,(k-1)*nx*ny+1:k*nx*ny),nx,ny)));
			%Remove the mask?
        		%jjsol=real(jsol(nbc+1:end-nbc,nbc+1:end-nbc));
			sol{k}(j,:,:) = jsol;
		end
	end
	display(['Calls to rhs function: ' num2str(fevals)]);
end
