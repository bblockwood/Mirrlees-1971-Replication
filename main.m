% Ben Lockwood, benlockwood.com
% This code replicates the results in Mirrlees (1971), "An Exploration in
% the Theory of Optimum Income Taxation", ReStud 38(2).
% Thanks to Pan Liu (www.econ.iastate.edu/people/graduate-students/liu-pan) for
% valuable contributions.

clear all;
clc;

% Setup described in Section 8 (Case 1) and Section 9.
global AVGPROD;

% % Settings for Tables I and II
% AVGPROD = 0.93;             % avg productivity target (caption of Table I)
% startpt = [0.0487;.1941];   % note: start with small N, use resulting point, ratchet N

% Settings for Tables III and IV
AVGPROD = 1.1;             % caption of Table III
startpt = [0.0487;.1941];

% Find the lambda and n0 that best satisfy equation (53) and the avg
% productivity target
opts = optimset('Display','iter');
sol = fsolve(@(p) solve(p),startpt,opts);

n0 = sol(1);
lambda = sol(2);

% Store results
[~,xArray,yArray,nArray,fArray,FArray] = solve(sol);
zArray = yArray.*nArray;    % earnings

% Plot income and consumption by ability
plot(nArray,[xArray AVGPROD*zArray]);
legend('Consumption (x)','Earnings (w*z)','Location','NorthWest');
xlabel('Skill (n)');

disp('Table I/III:');
table1or3 = [xArray yArray xArray.*(1-yArray) zArray];
reportF = [min(FArray) 0.1 0.5 0.9 0.99]';
reportTable1or3 = interp1(FArray,table1or3,reportF); % vlookup rows to report
[[0; reportF(2:end)] reportTable1or3] 

% Plot income tax schedule
tArray = AVGPROD*zArray - xArray;
plot(AVGPROD*zArray,tArray);
xlabel('Earnings (w*z)');
ylabel('Taxes paid (w*z-x)');
axis([0; 1.1*max(AVGPROD*zArray); min(tArray); 1.1*max(tArray)]);

nStep = 0.001;
X = fArray'*xArray*nStep + FArray(1)* xArray(1);
Z = fArray'*(yArray.*nArray)*nStep;

% Calculate the Average tax rate and Marginal tax rate
IncomeArray = AVGPROD*zArray;
AvgtArray = tArray./IncomeArray;  % Average tax rate
N = 2000;
MartArray = zeros(N,1);
for n=1:N-1
    MartArray(n) = (tArray(n+1)-tArray(n))/(IncomeArray(n+1)-IncomeArray(n));
end
MartArray(N)= nan;

disp('Table II/IV:');
table2or4 = [xArray AvgtArray MartArray];
reportz = [0 0.05 0.1 0.2 0.3 0.4 0.5]';
reportTable2or4 = interp1(zArray,table2or4,reportz); % vlookup rows to report
[reportz reportTable2or4] 

