function [target,xArray,yArray,nArray,FArray] = solve(p)

n0 = p(1);
lambda = p(2);

global AVGPROD;

% Skill density described 
mu = -1;
sd = 0.39;
f = @(n) lognpdf(n,mu,sd);
F = @(n) logncdf(n,mu,sd);

% Initialize arrays to store solution
N = 150;
nStep = 0.01;
nArray = zeros(N,1);
uArray = zeros(N,1);                    % state variable
yArray = zeros(N,1);                    % control variable
xArray = zeros(N,1);
vArray = zeros(N,1);

% Partial derivatives of utility function
ux = @(x) 1/x;                                                  % see eq 97

% System of differential equations; let beta=0, alpha=1
x = @(u,y) exp(u - log(1-y));                                   % eq 97
v = @(u,y,n) (1-y)*(1-y-x(u,y)/n);                              % eq 49
dvdn = @(u,y,n) v(u,y,n)*log(n)/n - x(u,y)/n^2 + lambda/n^2;    % eq 50
dudn = @(y,n) y/(n*(1-y));                                      % eq 51

% Solve for initial (u0,v0), with p = [u;v]
nArray(1) = n0;
yArray(1) = 0;                          % by definition
vInit = @(u) F(n0)/(n0^2*f(n0))*(lambda - 1/ux(x(u,0)));        % eq 52
opts = optimset('display','none');
p0 = [-2.5;0]; % starting guess

% Solve system of equations 49 and 52 to find initial values of u and v
sol = fsolve(@(p) [p(2) - vInit(p(1)); p(2) - v(p(1),0,n0)],p0,opts);
uArray(1) = sol(1);
vArray(1) = sol(2);
xArray(1) = x(uArray(1),yArray(1));

% Iterate through skill levels, calculating the derivatives dudn and dvdn
% at each point, and using that derivative to project to the next value of
% u and v. (Like Runge-Kutta, but not quite as precise.)
for n=2:N
    nArray(n) = nArray(n-1) + nStep;
    
    dv = dvdn(uArray(n-1),yArray(n-1),nArray(n-1));
    vArray(n) = vArray(n-1) + dv*nStep;

    du = dudn(yArray(n-1),nArray(n-1));
    uArray(n) = uArray(n-1) + du*nStep;
    
    yArray(n) = fsolve(@(y) vArray(n) - ...
                       v(uArray(n),y,nArray(n)),yArray(n-1),opts);
    xArray(n) = x(uArray(n),yArray(n));
end

fArray = f(nArray);
FArray = F(nArray);

eq53 = vArray(N)*nArray(N)^2*f(nArray(N));                      % eq 53
X = fArray'*xArray;
Z = fArray'*(yArray.*nArray);
target = [eq53; X/Z - AVGPROD]; % should be [0; 0] at optimal (lambda, n0)
