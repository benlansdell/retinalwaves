function sol = retinal2D(params, solver)
        % retinal2D             Run simulations of 2D retinal wave model with given model, parameters and initial conditions and
	%                       sequences of images of solution evaluated at specified times.
        %
        % Usage:
        %                       sol = retinal2D(params, solver)
        %
        % Input:
	%                       params = structure of parameters generally from output of parameters() function
	%			solver = (optional, default = 'ode45') string specifying ODE solver to use. Choose from
	%				one of MATLAB's in built, or from ode4 (4th order Runge-Kutta) or ode1 (Forward Euler).
	%				The latter two are fixed-step size solvers, and use a step size of 0.001
	%
        % Output:
        %			sol = cell-array of solution data
	%
        % Example(s):
	%			model = 'fn';
	%			params = parameters(model, 'random');
        %                       sol = retinal2D(params);
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

	%Setup domain
	Lx=params.length; x2=linspace(-Lx/2,Lx/2,nx); x=x2(1:nx);  % space variables
	Ly=Lx; ny=nx; y2=linspace(-Ly/2,Ly/2,ny); y=y2(1:ny);
	h = Lx/(nx-1);
	e = ones(nx,1);
	em1 = ones(nx-1,1);
	lap = (diag(em1,1) + diag(em1,-1) -2*diag(e,0))/h^2;
	
	rng default;
	uniform = rand(1,nx*ny,length(t_start:noisedt:t_end)); %Generate all the noise for our simulation now
	noise = params.fnoise(uniform);	%Transform it to the right form

	[X,Y]=meshgrid(x,y);

	%Boundary mask
	nbc=5;
	fx=0.*x; fy=0.*y; 
	fx(1:nbc)=ones(1,nbc);
	fx(end-nbc+1:end)=ones(1,nbc);
	fy(1:nbc)=ones(1,nbc);
	fy(end-nbc+1:end)=ones(1,nbc);
	[FX,FY]=meshgrid(fx,fy);
	%Why is this FX+FY?
	Rmask=FX+FY;
	R2mask=reshape(Rmask,nx*ny,1);

	%Add variable recovery. Not implemented yet
	%cvar=abs(c*(1+cnoise*randn(nx,ny)));
	%ifft(noiseV*(randn(nx,ny)+i*randn(nx,ny)));
	%cvar = c + c*abs(cnoise*real(ifft(rand(nx,ny)+i*rand(nx,ny))));

	initial = [];
	sol = {};
	for j=1:params.n
		ic = ics{j};
		initial = [initial, reshape(ic,1,nx*ny)];
		sol{j} = zeros(length(tspan),nx,ny);
	end
	opts = odeset();
	opts.StepSize = params.StepSize; %Fixed step size for ode1 and ode4
	display(['Solving spatially discretized PDE using ' solver])
	tic;
	[t,solt]=hsolver(params.rhs,tspan,initial,opts,{nx,ny,h,lap,R2mask,params.modelps,noise, noisedt});
	toc

	display('Found solution. Resorting data')
        for j=1:length(tspan)
		for k=1:params.n
        		jsol=reshape(solt(j,(k-1)*nx*ny+1:k*nx*ny),nx,ny).';
			%Remove the mask?
        		%jjsol=real(jsol(nbc+1:end-nbc,nbc+1:end-nbc));
			sol{k}(j,:,:) = jsol;
		end
	end

	display(['Calls to rhs function: ' num2str(fevals)])
end
