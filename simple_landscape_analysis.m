figure(3)
N = 100;
x = [0:N];

loner_energy = -2.0;
min_interactions = 0;

all_K = 10.^[-2:0.05:1];
%all_K = [0.1 0.2 0.5 1 2 5 10 20 50 100]; % K_d's, in units of 1/pixel-size  -- for 20 particles, min_interact 4
%all_K = [0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10]; % K_d's, in units of 1/pixel-size  -- for 100 particles, min_interact 4
all_C = log( all_K*L*L/N )/n_neighbor;
E0 = 10; % penalty for bringing together particles (box size)

clear f;
for m = 1:length( all_C )
    tic
    C = all_C(m);
    E = E0 - C*x;
    E( 1: [min_interactions-1] ) = 0.0;

    E(1) = loner_energy; % loner energy is important
    boltzmann = exp( -E );
    f(m) = boltzmann(1)/sum( boltzmann )    

end
plot( all_K, f*N );
ylabel( 'num free' )
xlabel( 'K' )
