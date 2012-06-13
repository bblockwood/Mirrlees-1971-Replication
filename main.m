% Ben Lockwood, lockwood@fas.harvard.edu
% This code replicates the results in Mirrlees (1971), "An Exploration in
% the Theory of Optimum Income Taxation", ReStud 38(2).

clear all;
clc;

% Setup described in Section 8 (Case 1) and Section 9.
global AVGPROD;
AVGPROD = 0.93;             % set average productivity

% Find n0 that best satisfies equation (53)
opts = optimset('Display','iter');
sol = fsolve(@(p) solve(p),[0.06;0.155],opts);

n0 = sol(1);
lambda = sol(2);

[~,xArray,yArray,nArray,FArray] = solve(sol);
zArray = yArray.*nArray;    % earnings

% Display results
table = [xArray zArray FArray]
plot(nArray,[xArray zArray]);
legend('Consumption (x)','Earnings (z)','Location','NorthWest');
xlabel('Skill (n)');

pause;
tArray = zArray - xArray;
plot(zArray,tArray);
xlabel('Earnings (z)');
ylabel('Taxes paid (z-x)');
axis([0; 1; min(tArray); 1.1*max(tArray)]);
