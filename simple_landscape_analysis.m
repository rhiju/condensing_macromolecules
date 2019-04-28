figure(3)
L = 15; % size of box
x = [0:N];
loner_energy = -2.0;
min_interactions = 0;

% scan through these equilibrium constants for particle-particle
% interactions
N = 100;  
all_K = 10.^[-2: 0.05: 1];

% use these parameters instead to see how fewer particles give a
%  less sharp transition --
N = 20;  
all_K = 10.^[-2: 0.05: 2.5];

% convert desired approximate equilibrium constant (K_d) for entering the
%  condensate (with n_neighbor bonds) to an energy per bond (C) --
%   note that kT = 1.0, and this is basically just a logarithm.
n_neighbor = 8;
all_C = log( all_K*L*L/N )/n_neighbor; 

% Further penalty for bringing together particles (expanding box size) --
%  this is kind of a fudge factor.
E0 = 10; 

clear f;
for m = 1:length( all_C )
    tic
    C = all_C(m);
    E = E0 - C*x;
    E( 1: [min_interactions-1] ) = 0.0;

    E(1) = loner_energy; % loner energy is important
    boltzmann = exp( -E );
    f(m) = boltzmann(1)/sum( boltzmann );  
end
plot( all_K, f*N );
xlabel( 'K (in k_B T)' );
ylabel( 'num free' );
title( sprintf( 'Condensation of %d particles in box. Loner bonus energy: %f',N,loner_energy) );
