function params = parameters(model, ictype, tspan, nx, noisetype, centeronly)
        % parameters            Return all parameters needed to run a given model
        %
        % Usage:
        %                       params = parameters(model, ictype, tspan, nx, p)
        %
        % Input:
	%			model = one of 'fn' -- Fitzhugh-Nagumo model dynamics
	%				       'ml' -- Morris-Lecar based dynamics
	%				       'ml_sahp' -- Morris-Lecar with sAHP current
	%				       'ml_sahp_2time' -- Morris-Lecar with sAHP current and double the timescale
	%				       <filename> -- load previous parameters and sol data from savesol(). all other
	%						parameters are ignored if the first argument is a filename (contains
	%						a '.')
	%			ictype = one of 'random' -- white noise (gaussian noise in fourier domain)
	%					'homog' -- zero
	%					'bump' -- to start a single travelling wave across entire domain
	%			tspan = (optiona, default = 0:50) time points to output solution for
	%			nx = (optional, default = 64) dimension of grid to solve on
        %                       noisetype = (optional, default = 'exponential') type of noise to add every noiseStepSize seconds
	%					See noisehandle.m for options.
	%			centeronly = (optional, default = 0) whether to only spike in noise in center grid point. 1 or 0
        %
        % Output:
        %                       params = structure containing:
	%				modelps = vector of model specific parameters
	%				n = number of dynamic variables of model
	%				length = size of domain to solve PDE over (not the number of grid points)
	%				plus more.....
        %
        % Example(s):
	%			params = paramset('fn', 'random');
        %                       sol = retinal2D(params);

	if nargin < 1
		throw(MException('Argin:Error','Not enough arguments. See help parameters'));
	elseif (nargin < 2) | any(model == '.')
		s = load(model);
		params = s.params;
		%Load saved solution data as an initial condition...
		params.ics = {};
		for j = 1:params.n
			params.ics{j} = s.sol{j}(end,:,:);
		end
		params.ictype = 'prev';
		return
	elseif nargin < 3
		tspan = 0:50;
		nx = 64;
		noisetype = 'exponential';
		centeronly = 0;
	elseif nargin < 4
		noisetype = 'exponential';
		nx = 64;
		centeronly = 0;
	elseif nargin < 5
		noisetype = 'exponential';
		centeronly = 0;
	elseif nargin < 6
		centeronly = 0;
	end

	params.nx = nx;
	params.model = model;
	params.ictype = ictype;
	params.tspan = tspan;
	params.nbc = 5; %size of mask DEPRECATED
	params.StepSize = 0.001; %fixed time-step size for some numerics
	params.noiseStepSize = 0.1; %time-step on which noise process is updated

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Parameters for Fitzhugh-Nagumo (initial model made by Nathan and Eli and Kevin and I%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	if strcmp(model, 'fn')
		params.n = 3;
		params.ndiff = 3;
		params.length = 40;
		params.spectralrhs = 'fn_rhs_spectral';
		params.splitrhs = 'fn_rhs_split';
		params.jacobian = 'fn_jacobian';
		params.rhs = 'fn_rhs';
		params.names = {'V', 'R', 'A'};
		params.icoffset = 0;
		params.icscale = 0.7;
		params.threshold = 0.6; %threshold used for wave analysis -- voltages above this value are 'spikes'
		%Standard params
		kap=100; v0 = 0.3; D=1; a=0.15;  b=0.02; c=0.00001; beta=0.4; beta2=1; gamma = .7; lambda = 1/1200; dur = 0.1;
		%Setup noise parameters
		noiseparams = {};
		if strcmp(noisetype, 'bernoulli')
			p = params.noiseStepSize/1200; gnM = 1;
			noiseparams = {p, gnM};
		elseif strcmp(noisetype, 'exponential')
			lambda = 5;
			noiseparams = {lambda};
		elseif strcmp(noisetype, 'lognormal')
			mu = 0; sigma = 0;
			noiseparams = {mu, sigma};
		elseif ~strcmp(noisetype, 'none')
			throw(MException('Argin:Error', 'Not valid noisetype choice. Read source code for options'));
		end
		params.fnoise = noisehandle(noisetype, noiseparams, centeronly);
		params.diffusion_coeff = D;
		params.modelps = [D a b c beta beta2 gamma kap v0 lambda dur];

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	%Parameters for Morric-Lecar model (with ACh)%
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	elseif strcmp(model, 'ml')
		params.n = 3;
		params.ndiff = 3;
                params.spectralrhs = 'ml_rhs_spectral';
		params.splitrhs = 'ml_rhs_split';
		params.jacobian = 'ml_jacobian';
                params.rhs = 'ml_rhs';
		params.names = {'V', 'R', 'A'};
		params.icoffset = -70;
		params.icscale = 10;
		params.threshold = 0; %threshold used for wave analysis -- voltages above this value are 'spikes'
                %'Known' parameters
		Cm = 160; VCa = 50; VK = -90; Vsyn = 50; gCaM = 10; gKM = 30; gAChM = 2; V1 = -20; V2 = 20; tauR = 5;
		Vnoise = 50; lambda = 1/1200; dur = 0.1;
		%'Unknown' parameters
		%'Informed guesses
		V3 =-25; V4 = 40; tauACh = 0.2; k = 2; kap = .2; v0 = -40;
		params.length = 2;
		%Complete guesses
		D = 0.01; b = 5; delta = 800;
		gLM = 3; VL = -70;
                %Setup noise parameters
                noiseparams = {};
                if strcmp(noisetype, 'bernoulli')
			p = params.noiseStepSize/1200; gnM = 20;
                        noiseparams = {p, gnM};
                elseif strcmp(noisetype, 'exponential')
			lambda = 5;
                        noiseparams = {lambda};
                elseif strcmp(noisetype, 'lognormal')
			mu = 0; sigma = 0;
                        noiseparams = {mu, sigma};
                elseif ~strcmp(noisetype, 'none')
                        throw(MException('Argin:Error', 'Not valid noisetype choice. Read source code for options'));
                end
                params.fnoise = noisehandle(noisetype, noiseparams, centeronly);
		params.diffusion_coeff = D;
                params.modelps = [Cm VCa VK VL Vsyn gCaM gKM gLM gAChM V1 V2 V3 V4 tauR tauACh D b delta k kap v0 lambda dur Vnoise];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Parameters for Morric-Lecar model (with ACh)%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif strcmp(model, 'ml_sahp')
                params.n = 4;
                params.ndiff = 4;
                params.spectralrhs = 'ml_sahp_rhs_spectral';
                params.splitrhs = 'ml_sahp_rhs_split';
                params.jacobian = 'ml_sahp_jacobian';
                params.rhs = 'ml_sahp_rhs';
                params.names = {'V (mV)', 'R', 'S', 'A (nM)'};
                params.icoffset = -70;
                params.icscale = 20;
                params.threshold = -60; %threshold used for wave analysis -- voltages above this value are 'spikes'
                %'Known' parameters
                Cm = 160; VCa = 50; VK = -90; Vsyn = 50; gCaM = 10; gKM = 30; gAChM = 2; V1 = -20; V2 = 20; tauR = 5;
                Vnoise = 50; lambda = 1/1200; dur = 0.1;
                V3 =-25; V4 = 40; tauACh = 0.2; k = 2; kap = .2; v0 = -40;
                params.length = 2;
                D = 0.01; b = 5; delta = 800;
                gLM = 3; VL = -70;
		%sAHP parameters
		alpha = 2; c = 0.3; tauS = 60;
                %Setup noise parameters
                noiseparams = {};
                if strcmp(noisetype, 'bernoulli')
                        p = params.noiseStepSize/800; gnM = 20;
                        noiseparams = {p, gnM};
                elseif strcmp(noisetype, 'exponential')
                        lambda = 5;
                        noiseparams = {lambda};
                elseif strcmp(noisetype, 'lognormal')
                        mu = 0; sigma = 0;
                        noiseparams = {mu, sigma};
                elseif ~strcmp(noisetype, 'none')
                        throw(MException('Argin:Error', 'Not valid noisetype choice. Read source code for options'));
                end
                params.fnoise = noisehandle(noisetype, noiseparams, centeronly);
		%Add current at t = 1 for 0.5s, default amount is zero amps
		params.I_applied = 0; params.I_applied_dt = 1.5; params.I_applied_t = 1;
                params.diffusion_coeff = D;
                params.modelps = [Cm VCa VK VL Vsyn gCaM gKM gLM gAChM V1 V2 V3 V4 tauR tauACh D b delta k kap v0 lambda dur Vnoise alpha tauS c];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Parameters for Morric-Lecar model (with ACh) and with fixed S dynamics%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif strcmp(model, 'ml_sahp_fixed_s')
                params.n = 4;
                params.ndiff = 4;
                params.spectralrhs = 'ml_sahp_fixed_s_rhs_spectral';
                params.splitrhs = 'ml_sahp_fixed_s_rhs_split';
                params.jacobian = 'ml_sahp_fixed_s_jacobian';
                params.rhs = 'ml_sahp_fixed_s_rhs';
                params.names = {'V (mV)', 'R', 'S', 'A (nM)'};
                params.icoffset = -70;
                params.icscale = 20;
                params.threshold = -60; %threshold used for wave analysis -- voltages above this value are 'spikes'
                %'Known' parameters
                Cm = 160; VCa = 50; VK = -90; Vsyn = 50; gCaM = 10; gKM = 30; gAChM = 2; V1 = -20; V2 = 20; tauR = 5;
                Vnoise = 50; lambda = 1/1200; dur = 0.1;
                V3 =-25; V4 = 40; tauACh = 0.2; k = 2; kap = .2; v0 = -40;
                params.length = 2;
                D = 0.01; b = 5; delta = 800;
                gLM = 3; VL = -70;
		%sAHP parameters
		alpha = 2; c = 0.3; tauS = 60;
                %Setup noise parameters
                noiseparams = {};
                if strcmp(noisetype, 'bernoulli')
                        p = params.noiseStepSize/800; gnM = 20;
                        noiseparams = {p, gnM};
                elseif strcmp(noisetype, 'exponential')
                        lambda = 5;
                        noiseparams = {lambda};
                elseif strcmp(noisetype, 'lognormal')
                        mu = 0; sigma = 0;
                        noiseparams = {mu, sigma};
                elseif ~strcmp(noisetype, 'none')
                        throw(MException('Argin:Error', 'Not valid noisetype choice. Read source code for options'));
                end
                params.fnoise = noisehandle(noisetype, noiseparams, centeronly);
		%Add current at t = 1 for 0.5s, default amount is zero amps
		params.I_applied = 0; params.I_applied_dt = 1.5; params.I_applied_t = 1;
                params.diffusion_coeff = D;
                params.modelps = [Cm VCa VK VL Vsyn gCaM gKM gLM gAChM V1 V2 V3 V4 tauR tauACh D b delta k kap v0 lambda dur Vnoise alpha tauS c];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %Parameters for Morric-Lecar model (with ACh)%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        elseif strcmp(model, 'ml_sahp_2time')
                params.n = 4;
                params.ndiff = 4;
                params.spectralrhs = 'ml_sahp_rhs_spectral';
                params.splitrhs = 'ml_sahp_rhs_split';
                params.jacobian = 'ml_sahp_jacobian';
                params.rhs = 'ml_sahp_rhs';
                params.names = {'V (mV)', 'R', 'S', 'A (nM)'};
                params.icoffset = -70;
                params.icscale = 10;
                params.threshold = -60; %threshold used for wave analysis -- voltages above this value are 'spikes'
		params.noiseStepSize = 0.05; %time-step on which noise process is updated
		params.StepSize = 0.0005;
                %'Known' parameters
                Cm = 80; VCa = 50; VK = -90; Vsyn = 50; gCaM = 10; gKM = 30; gAChM = 2; V1 = -20; V2 = 20; tauR = 2.5;
                Vnoise = 50; lambda = 1/1200; dur = 0.1;
                V3 =-25; V4 = 40; tauACh = 0.1; k = 2; kap = .2; v0 = -40;
                params.length = 2;
                D = 0.02; b = 10; delta = 800;
                gLM = 3; VL = -70;
		%sAHP parameters
		alpha = 2; c = 0.6; tauS = 30;
                %Setup noise parameters
                noiseparams = {};
                if strcmp(noisetype, 'bernoulli')
                        p = params.noiseStepSize/800; gnM = 20;
                        noiseparams = {p, gnM};
                elseif strcmp(noisetype, 'exponential')
                        lambda = 5;
                        noiseparams = {lambda};
                elseif strcmp(noisetype, 'lognormal')
                        mu = 0; sigma = 0;
                        noiseparams = {mu, sigma};
                elseif ~strcmp(noisetype, 'none')
                        throw(MException('Argin:Error', 'Not valid noisetype choice. Read source code for options'));
                end
                params.fnoise = noisehandle(noisetype, noiseparams, centeronly);

                params.diffusion_coeff = D;
                params.modelps = [Cm VCa VK VL Vsyn gCaM gKM gLM gAChM V1 V2 V3 V4 tauR tauACh D b delta k kap v0 lambda dur Vnoise alpha tauS c];
	else
		throw(MException('Argin:Error', 'Not valid model choice. See help parameters'));
	end
	
	params.ics = loadics(params.ictype, params.n, params.nx, params.icoffset, params.icscale);
end
