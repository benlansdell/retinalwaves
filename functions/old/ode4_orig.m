%Source: https://github.com/pao/julia/commit/60c762cd3cc8ffc5b07182d0adc6e708c9900cbb
%Downloaded 15 November 2012

#ODE4    Solve non-stiff differential equations, fourth order
#   fixed-step Runge-Kutta method.
#
#   [T,X] = ODE4(ODEFUN, TSPAN, X0) with TSPAN = [T0:H:TFINAL]
#   integrates the system of differential equations x' = f(t,x) from time
#   T0 to TFINAL in steps of H with initial conditions X0. Function
#   ODEFUN(T,X) must return a column vector corresponding to f(t,x). Each
#   row in the solution array X corresponds to a time returned in the
#   column vector T.
function ode4(F::Function, tspan::AbstractVector, x0::AbstractVector)
    h = diff(tspan)
    x = Array(Float64, (length(tspan), length(x0)))
    x[1,:] = x0'

    midxdot = Array(Float64, (4, length(x0)))
    for i = 1:(length(tspan)-1)
        # Compute midstep derivatives
        midxdot[1,:] = F(tspan[i],         x[i,:]')
        midxdot[2,:] = F(tspan[i]+h[i]./2, x[i,:]' + midxdot[1,:]'.*h[i]./2)
        midxdot[3,:] = F(tspan[i]+h[i]./2, x[i,:]' + midxdot[2,:]'.*h[i]./2)
        midxdot[4,:] = F(tspan[i]+h[i],    x[i,:]' + midxdot[3,:]'.*h[i])

        # Integrate
        x[i+1,:] = x[i,:] + 1./6.*h[i].*[1 2 2 1]*midxdot
    end
    return (tspan, x)
end
