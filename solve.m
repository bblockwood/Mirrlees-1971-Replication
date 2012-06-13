function [target,xArray,yArray,nArray,FArray] = solve(p)

n0 = p(1);
LAMBDA = p(2);

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
ux = @(x) 1/x;

% System of differential equations
x = @(u,y) exp(u - log(1-y));
v = @(u,y,n) (1-y)*(1-y-x(u,y)/n);
dvdn = @(u,y,n) v(u,y,n)*log(n)/n - x(u,y)/n^2 + LAMBDA/n^2;
dudn = @(y,n) y/(n*(1-y));

% Solve for initial (u0,v0), with p = [u;v]
nArray(1) = n0;
yArray(1) = 0;                          % by definition
vInit = @(u) F(n0)/(n0^2*f(n0))*(LAMBDA - 1/ux(x(u,0)));
opts = optimset('display','none');
p0 = [-2.5;0]; % starting guess

sol = fsolve(@(p) [p(2) - vInit(p(1)); p(2) - v(p(1),0,n0)],p0,opts);
uArray(1) = sol(1);
vArray(1) = sol(2);
xArray(1) = x(uArray(1),yArray(1));

% Iterate through skill levels
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

eq53 = vArray(N)*nArray(N)^2*f(nArray(N));
X = fArray'*xArray;
Z = fArray'*(yArray.*nArray);
target = [eq53; X/Z - AVGPROD];
