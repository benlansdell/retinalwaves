function output_sol = retinal2D_split(params, dt)
        % retinal2D             Run simulations of 2D retinal wave model with given model, parameters and initial conditions and
	%                       sequences of images of solution evaluated at specified times. Solve by splitting diffusion and
	%			reaction terms and solving separately. Solves with Neumann boundary conditions
        %
        % Usage:
        %                       sol = retinal2D_split(params, dt)
        %
        % Input:
	%                       params = structure of parameters, generally from output of parameters() function.
	%			dt = (optional, default specified in parameters.m) stepsize for time integration. 
	%	         		Reads value from params	structure if not specifiied. Probably this is set to 0.001
	%
        % Output:
        %			sol = cell-array of solution data
	%
        % Example(s):
	%			model = 'fn';
	%			params = parameters(model, 'random');
        %                       sol = retinal2D_split(params);
	%			plotsol(sol, 'test.gif', params);

	if (nargin < 1)
		throw(MException('Argin:Error', 'More input arguments expected'));
	elseif (nargin < 2)
		dt = params.StepSize;
	end

	global fevals;
	fevals = 0;

	f = str2func(params.splitrhs);
	fprime = str2func(params.jacobian);
	nx = params.nx;
	ics = params.ics;
	tspan = params.tspan;
	t_start = tspan(1);
	t_end = tspan(end);
	noisedt = params.noiseStepSize;
	D = params.diffusion_coeff;
	ndiff = params.ndiff; %index of variable to apply diffusion to

	%Setup domain: nx is the number of interior points
	Lx=params.length; x2=linspace(-Lx/2,Lx/2,nx); x=x2;  % space variables
	Ly=Lx; ny=nx; y2=linspace(-Ly/2,Ly/2,ny); y=y2;
	h = Lx/(nx-1);
	[X,Y]=meshgrid(x,y);

	%Setup initial solution data
	U = zeros(nx,ny,params.n);
	v = zeros(nx,ny);
	U_output = zeros(nx,ny,params.n,length(tspan));
	for j = 1:params.n
        	U_output(:,:,j,1) = ics{j};
	end

	%Setup noise for simulation
	%rng default;
        uniform = rand(nx,ny,length(t_start:noisedt:t_end)); %Generate all the noise for our simulation now
        noise = params.fnoise(uniform); %Transform it to the right form
	forcing = zeros(nx,ny,length(t_start:noisedt:t_end));
	fstart = round((params.I_applied_t-t_start)/noisedt)+1; fend = round((params.I_applied_t+params.I_applied_dt-t_start)/noisedt)+1;
	forcing(floor(nx/2), floor(ny/2), fstart:fend) = params.I_applied;

	%Setup matrices used for diffusion step
        ex = ones(nx,1);
        Tx = spdiags([ex -2*ex ex],[-1 0 1],nx,nx);
        Tx(1,2) = 2;
        Tx(nx,nx-1) = 2;
        Tx = D/h^2 * Tx;
        A1x = speye((nx)) - dt/2 * Tx;
        A2x = speye((nx)) + dt/2 * Tx;

        ey = ones(ny,1);
        Ty = spdiags([ey -2*ey ey],[-1 0 1],ny,ny);
        Ty(1,2) = 2;
        Ty(ny,ny-1) = 2;
        Ty = D/h^2 * Ty;
        A1y = speye((ny)) - dt/2 * Ty;
        A2y = speye((ny)) + dt/2 * Ty;

	display(['Solving spatially discretized PDE using fractional time-stepping method: Crank-Nicolson for diffusion step and 2-stage Runge Kutta for reaction step'])
	diff_time = 0;
	reac_time = 0;
        for j = 1:(length(tspan)-1)
    		T = tspan(j):dt:tspan(j+1);
        	Ui(:,:,:) = U_output(:,:,:,j);
        	for i = 1:(length(T)-1)
			t = T(i);
			tic;
			%%%%%%%%%%%%%%%%
			%Diffusion term%
			%%%%%%%%%%%%%%%%
			v(:,:) = Ui(:,:,ndiff);
			%Crank Nicolson
 		        rhs = A2x*v;
		        v = A1x\rhs;
		        % y-sweeps.
		        % in second step, apply on rows:
		        rhs = A2y*v';
			if i == 2
				rhs;
			end
		        Ui(:,:,ndiff) = (A1y\rhs)';
			diff_time = diff_time + toc;
			%%%%%%%%%%%%%%%
			%Reaction term%
			%%%%%%%%%%%%%%%
			tic;
			%%%%%%%%%%%%%%%%%%%%%
			%2-stage Runge Kutta%
			%%%%%%%%%%%%%%%%%%%%%

			Us = Ui + dt*f(t,Ui,{nx,ny,params.modelps,noise,noisedt,forcing})/2;
			Ui = Ui + dt*f(t,Us,{nx,ny,params.modelps,noise,noisedt,forcing});
			
			%%%%%%%%%%%%%%%%%%%%%
			%Use Newton's method%
			%%%%%%%%%%%%%%%%%%%%%
			%Initial guess for Newton
			%Ui1 = Ui;
			%Reaction term: use Newton iteration unless doesn't converge after 10 iterations
 		        %for inewton=1:10
			%	%This is just backward Euler, we want to solve for Ui1
			%	%%This is the 1D version, we need a vector version....
			%        g = Ui + dt * f(Ui1) - Ui1;
			%        gprime = dt * fprime(Ui1) - 1;
		        %	dU = g ./ gprime;
		        %	Ui1 = Ui1 - dU;
			%        maxg = max(abs(g));
		        %        if maxg < 1e-6
        	        %		% convergence at all grid points
        	        %		break
                	%	end
             		%end
		        %ibad = find(abs(g) > 1e-6);   % indices of bad points
		        %if length(ibad) > 0
			%        % use fzero at the points where Newton didn't converge:
			%        for idx=ibad'
			%                % solve ODE at i'th grid point
			%                Ui_idx = Ui(idx);
			%                F = @(x) Ui_idx + dt * f(x) - x;
			%                Ui1(idx) = fzero(F,Ui_idx);
			%        end
		        %end 
			%Ui = Ui1;
			reac_time = reac_time + toc;
        	end
        	U_output(:,:,:,j+1) = Ui(:,:,:);
	end

	%(nx,ny,n,t)->(t,nx,ny,n)

	U_output = permute(U_output,[4 1 2 3]);
	output_sol = {};
	for j=1:params.n
		output_sol{j} = U_output(:,:,:,j);
	end
	display(['CPU time spent on diffusion step: ' num2str(diff_time)]);
	display(['CPU time spent on reaction step: ' num2str(reac_time)]);
	display(['Total time: ' num2str(diff_time + reac_time)]);
	display(['Calls to rhs function: ' num2str(fevals)]);
end
