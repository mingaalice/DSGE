/*
Gertler (1999) OLG model

Permanent increase in government spending/output:
Baseline:       gbar = 0.20
Counterfactual: gbar = 0.30

Compare steady states:
(Counterfactual - Baseline) / Baseline
*/


// variables & parameters
// All real quantities are divided by effective labor X_t N_t.
// Treat gbar, ebar, and bbar as long-run institutional parameters.
var k lambda pi eps Omega h c r s sw a tau y b;
parameters beta sigma omega gamma alpha delta n x q psi gbar ebar bbar;

beta  = 1;
sigma = 0.25;
omega = 0.977;
gamma = 0.9;
alpha = 0.667;
delta = 0.1;
n     = 0.01;
x     = 0.01;
q     = (1+n)*(1+x);
psi   = (1-omega)/(1+n-gamma);

//Other fiscal parameters
ebar = 0.05;
bbar = 0.60;

// model
model;
    // All real quantities are divided by effective labor X_t N_t.
    // q = (1+n)(1+x) is gross effective-labor growth.
    k(+1)*q = y - c - gbar*y + (1-delta)*k;
    lambda(+1) = omega*(1-eps*pi)*lambda*r*a/(q*a(+1))
                 + omega*(ebar*y-eps*pi*s)/(q*a(+1)) + (1-omega);
    pi = 1 - beta^sigma*(r(+1)*Omega(+1))^(sigma-1)*pi/pi(+1);
    eps*pi = 1 - beta^sigma*gamma*r(+1)^(sigma-1)
                    *(eps*pi)/(eps(+1)*pi(+1));
    Omega(+1) = omega + (1-omega)*eps(+1)^(1/(1-sigma));
    h = alpha*y - tau + (1+x)*omega*h(+1)/(r(+1)*Omega(+1));
    c = pi*((1-lambda)*r*a + h + sw + eps*(lambda*r*a+s));
    y = k^(1-alpha);
    r = (1-alpha)*y/k + (1-delta);
    a = k+b;
    b = bbar*y;
    // B_t = T_t-G_t-E_t+B_{t+1}/R_{t+1}; taxes adjust to the debt path.
    b = tau - gbar*y - ebar*y + q*b(+1)/r(+1);
    s = ebar*y + (1+x)*gamma*s(+1)/r(+1);
    sw = (1-omega)/psi * eps(+1)*(1+x)*s(+1)/(r(+1)*Omega(+1))
         + (1+x)*omega*sw(+1)/(r(+1)*Omega(+1));
end;
