function ics = loadics(type, n, nx, offset, scale)
        % loadics               Setup initial conditions of a given type and given grid size to solve PDE on
	%			Called by parameters()
        %
        % Usage:
        %                       ics = loadics(type, n, nx)
        %
        % Input:
        %                       type = one of 'random' -- white noise initial conditions for V, zero for all others
	%				'homog' -- zero initial conditions for all
	%				'bump' -- wave inducing bump in center of domain, for V, zero for all else
	%				'bump1D' -- wave inducing bump across center stripe of domain, for V, zero for all else
	%			n = dimension of dynamical system
	%			nx = X dimension (ny dimension is set to = nx)
	%			offset = resting potential to base initial data at
	%			scale = scale of initial data
        %
        % Output:
        %                       ics = cell array containing n matrices of size nx*ny, one for each dynamica variable

	ny = nx;
        if strcmp(type, 'random')
		ics = random(nx, ny, n, offset, scale);
        elseif strcmp(type, 'homog')
		ics = homog(nx, ny, n, offset, scale);
        elseif strcmp(type, 'bump')
		ics = bump(nx, ny, n, offset, scale);
        elseif strcmp(type, 'bump1D')
		ics = bump1D(nx, ny, n, offset, scale);
        else
                throw(MException('Argin:Error', 'Not valid IC type. See help loadics'));
        end
end

function ics = random(nx,ny,n,offset,scale)
        % random initial conditions
        V=scale*real(ifft((randn(nx,ny)+i*randn(nx,ny))));
	z = zeros(nx,ny);
        ics = {V+offset};
	for j=2:n
		ics = {ics{:}, z};
	end
end

function ics = homog(nx,ny,n,offset,scale)
	%Set to zero
        z=zeros(nx,ny);
        ics = {z};
	for j=2:n
		ics = {ics{:}, z};
	end
	%Set voltage to resting potential...
	ics{1} = z + offset;
end

function ics = bump(nx,ny,n,offset,scale)
        % bump in center
	Lx = 2; Ly = 2;
        x=linspace(-Lx/2,Lx/2,nx);  % space variables
        y=linspace(-Ly/2,Ly/2,ny);
	[X,Y] = meshgrid(x,y);
        V=3*scale*exp(-((X-Lx/2).^2+Y.^2)*100);
	z = zeros(nx,ny);
        ics = {V+offset};
        for j=2:n
                ics = {ics{:}, z};
        end
end

function ics = bump1D(nx,ny,n,offset,scale)
        % bump in center in Y coords
	Lx = 2; Ly = 2; %why is this hard coded???
        x=linspace(-Lx/2,Lx/2,nx);  % space variables
        y=linspace(-Ly/2,Ly/2,ny);
	[X,Y] = meshgrid(x,y);
        %V=3*scale*exp(-((X-Lx/2).^2+Y.^2)*100);
        V=3*scale*exp(-((X-Lx/2).^2)*100);
	z = zeros(nx,ny);
        ics = {V+offset};
        for j=2:n
                ics = {ics{:}, z};
        end
end
