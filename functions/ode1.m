%ODE1    Solve non-stiff differential equations with Forward Euler
%
%   [T,X] = ODE1(ODEFUN, TSPAN, X0) with TSPAN = [T0:H:TFINAL]
%   integrates the system of differential equations x' = f(t,x) from time
%   T0 to TFINAL in steps of H with initial conditions X0. Function
%   ODEFUN(T,X) must return a column vector corresponding to f(t,x). Each
%   row in the solution array X corresponds to a time returned in the
%   column vector T.
function [tspan, x] = ode1(Fstr, tspan, x0, opts, params)
    F = str2func(Fstr);
    dt = opts.StepSize;
    ttspan = tspan(1):dt:tspan(2);
    x = zeros(length(tspan), length(x0)); 
    xtemp = zeros(length(ttspan), length(x0));
    x(1,:) = x0';
    dummy = 0;
    
    for j = 1:(length(tspan)-1)
	ttspan = tspan(j):dt:tspan(j+1);
	xtemp(1,:) = x(j,:);
        for i = 1:(length(ttspan)-1)
	    %Integrate
            xtemp(i+1,:) = xtemp(i,:) + dt*F(ttspan(i), xtemp(i,:)',dummy,params)';
        end
	x(j+1,:) = xtemp(end,:);
    end
end

