function test_filters()

% Copyright (C) 2012 Jean-Pierre de la Croix
% see the LICENSE file included with this software

% 1. Define non-linear system with initial conditions.
x_0 = 0.1;          % initial state
sigma_2_w = 1;      % state noise variance
sigma_2_n = 1;      % measurement noise variance

Ds = 1;             % dimension of state space
Dm = 1;             % dimension of measurement space

sys = mcodekit.system.StochasticSystem(sigma_2_w, sigma_2_n, Ds, Dm);

% 2. Define filter.
N = 20;                             % total # of steps
sigma_P_0 = 2;                      % initial error variance
P_0 = sqrt(sigma_P_0)*eye(Ds);      % initial error covariance matrix
Ns = 100;                           % # of particles

fltr = mcodekit.algorithm.ExtendedKalmanFilter(sys, P_0, N);
% fltr = mcodekit.algorithm.ParticleFilter(sys, sigma_P_0, N, Ns);


% 3. Define and simulate filtered system.
fsys = mcodekit.system.FilteredSystem(sys, fltr, N, x_0, x_0);
fsys.simulate();
fsys.print();

end