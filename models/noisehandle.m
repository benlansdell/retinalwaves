function fnoise = noisehandle(type, params, centeronly)
        % fnoise                Return function handle for generating noisy RVs when given a matrix (of any size) of
	%			uniform RVs between 0 and 1. Returns the noisy conductance g_N used to generate noisy
	%			current g_N(V-V_N)
        %
        % Usage:
        %                       fnoise = noise(type, params)
        %
        % Input:
        %                       type = distribution the RV g_N follows. One of:
	%				'none': g_N ~ 0
	%			        'bernoulli': g_N ~ g_N^M Bernoulli(p)
	%			        'bernoulli_once': g_N ~ g_N^M Bernoulli(p) [only occur once, at start of simulation]
        %                               'exponential': g_N ~ exp(lambda) 
        %                               'log-normal' g_N ~ log-normal(mu, sigma)
        %                       params = cell array of parameters specific to distribution. See function definitions
	%			centeronly = (optional, default = 0) only add noise to the center grid point (for investigating
	%				intrinsic noise rate). 1 or 0
        %
        % Output:
        %                       fnoise = function handle to be used by rhs functions

	if nargin < 3
		centeronly = 0;
	end

	if strcmp(type, 'none')
		fnoise = @(X) zeros(size(X));
        elseif strcmp(type, 'bernoulli')
		fnoise = @(X) bernoulli(X, params, centeronly);
	elseif strcmp(type, 'bernoulli_once')
		fnoise = @(X) bernoulli_once(X, params, centeronly);
        elseif strcmp(type, 'exponential')
                fnoise = @(X) exponential(X, params, centeronly);
        elseif strcmp(type, 'lognormal')
                fnoise = @(X) lognormal(X, params, centeronly);
        else
                throw(MException('Argin:Error', 'Not valid noise type. See help noisehandle'));
        end

end

function Y = bernoulli(X, params, centeronly)
	p = params{1};
	gnM = params{2};
	Y = gnM*(X < p);
        if centeronly == 1
                a = size(X);
                nx = a(2);
                i = floor(0.5*nx); j = floor(0.5*nx);
                mask = zeros(a);
                mask(i,j,:) = 1;
                Y = Y.*mask;
        end
end

function Y = exponential(X, params, centeronly)
	%Use the inverse of the CDF for an exponential
        lambda = params{1};
        Y = -log(X)/lambda;
	if centeronly == 1
		a = size(X);
		nx = a(2);
		i = floor(0.5*nx); j = floor(0.5*nx);
		mask = zeros(a);
		mask(i,j,:) = 1;
		Y = Y.*mask;
	end
end

function Y = lognormal(X, params)
	throw(MException('Function:NotImplemented','Function not implemented yet, use another noise type. See help noisehandle.'));
	%The inverse of the CDF for lognormal....
        p = params{1};
        gnM = params{2};
        Y = gnM*(X < p);
end

