%ODE4    Solve non-stiff differential equations, fourth order
%   fixed-step Runge-Kutta method.
%
%   [T,X] = ODE4(ODEFUN, TSPAN, X0) with TSPAN = [T0:H:TFINAL]
%   integrates the system of differential equations x' = f(t,x) from time
%   T0 to TFINAL in steps of H with initial conditions X0. Function
%   ODEFUN(T,X) must return a column vector corresponding to f(t,x). Each
%   row in the solution array X corresponds to a time returned in the
%   column vector T.
function [tspan, x] = ode4(Fstr, tspan, x0, opts, params)
    F = str2func(Fstr);
    dt = opts.StepSize;
    ttspan = tspan(1):dt:tspan(2);
    x = zeros(length(tspan), length(x0)); 
    xtemp = zeros(length(ttspan), length(x0));
    x(1,:) = x0';
    dummy = 0;

    midxdot = zeros(4,length(x0));
    
    for j = 1:(length(tspan)-1)
	ttspan = tspan(j):dt:tspan(j+1);
	xtemp(1,:) = x(j,:);
        for i = 1:(length(ttspan)-1)
            % Compute midstep derivatives

            midxdot(1,:) = F(ttspan(i),       xtemp(i,:)',dummy, params);
            midxdot(2,:) = F(ttspan(i)+dt./2, xtemp(i,:)' + midxdot(1,:)'.*dt./2,dummy, params);
            midxdot(3,:) = F(ttspan(i)+dt./2, xtemp(i,:)' + midxdot(2,:)'.*dt./2,dummy, params);
            midxdot(4,:) = F(ttspan(i)+dt,    xtemp(i,:)' + midxdot(3,:)'.*dt,dummy, params);
  
            % Integrate
            xtemp(i+1,:) = xtemp(i,:) + 1./6.*dt*[1 2 2 1]*midxdot;
        end
	x(j+1,:) = xtemp(end,:);
    end
end

