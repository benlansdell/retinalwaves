function roots = root_find(f, xmin,xmax)

%Try this many initial values
niter = 40;

%Treat roots within tol as the same
tol = 1e-3;

%Find roots
roots = [];
for x = xmin:(1/niter):xmax
    [Vs,FVAL,EXITFLAG,OUTPUT,JACOB] = fsolve(f,x, optimset('Display', 'none'));
    if (EXITFLAG == 1) & (FVAL < 1e-5) & ~any(abs(roots-Vs) < tol)
        roots = [roots Vs];
    end
end;

end
