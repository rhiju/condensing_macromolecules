%
% Extremely simply Monte Carlo of particles in a 2D box
%   to get a feel for condensation behavior.
%
% Particle can form 'bonds' with immediate neigbors and diagonal neighbors
% (max 8 bonds)
%
%  N = number of particles
%  L = box size (15)
%  C = energy per bond. 
%
% (C) R. Das, Stanford University 2019

% 'canonical simulations'

NITER = 500000; 
L = 15; % size of box
N = 20; % number of particles
all_K = [0.1 0.2 0.5 1 2 5 10 20 30 40 45 50 60 70 80 90 100 200 500]; % K_d's, in units of 1/pixel-size
loner_energy = -2.5; % cooperativity 'enforcement'
min_interactions = 0; % any particle with fewer than this number of bonds does not get a bonus
max_interactions = 0;

% big runs -- will take overnight on a laptop
%NITER = 10000000; 
%L = 40; % size of box
%N = 100; % number of particles
%all_K = [0.1 0.2 0.5 1 2 5 10 20 30 40 45 50 60 70 80 90 100 150 200 500]; % K_d's, in units of 1/pixel-size
%loner_energy = -2.5; % cooperativity 'enforcement'
%min_interactions = 0; % any particle with fewer than this number of bonds does not get a bonus
%max_interactions = 0;

% quick runs with max_interactions=3, which enforces that multimers don't
% grow beyond little squares.
%NITER = 500000; 
%L = 40; % size of box
%N = 100; % number of particles
%all_K = 1000*[0.1 0.2 0.5 1 2 5 10 20 30 40 45 50 60 70 80 90 100 150 200 500]; % K_d's, in units of 1/pixel-size
%loner_energy = -2.5; % cooperativity 'enforcement'
%min_interactions = 0; 
%max_interactions = 3;

% How to scan through condensation transition:
% K_d ~ exp( C * n_neighbor ) * L * L 
n_neighbor = 8; % if interactions to neighbors and diagonal neighbors are allowed.
all_C = log( all_K*L*L/N )/n_neighbor;

set( figure(1), 'Position', [33   783   416   530])
for m = 1:length( all_C )
    tic
    C = all_C(m);
    fprintf( 'Running %d of %d simulations for C = %f ...\n', m, length(all_C),C );

    B = zeros(L); % the box of particles, LXL
    
    r = randperm( L*L );
    [xg,yg] =  ndgrid( 1:L, 1:L );
    x = xg( r(1:N) );
    y = yg( r(1:N) );
    B(r(1:N)) = 1;
    
    colormap( 1 - gray(100));
    set(gcf, 'PaperPositionMode','auto','color','white');
    axis off
    
    moves = [1,0; 1,-1; 0,-1; -1,-1; -1,0; -1,1; 0,1; 1,1];
    nmoves = size( moves, 1 );
    [s,num_free] = score_box( B, C, min_interactions, max_interactions, loner_energy );
    
    all_num_free = [];
    all_s = [];
    all_B = {};
    for i = 1:NITER
        all_s(i) = s;
        all_num_free(i) = num_free;
        if mod(i,1000) == 0 | i==NITER; all_B = [all_B,B]; end;
        
        % set up the trial
        n = randi( N ); % which particle to move
        q = randi( nmoves ); % which way to move;
        B_trial = B;
        x_trial = mod( x(n) + moves(q,1) - 1, L ) + 1;
        y_trial = mod( y(n) + moves(q,2) - 1, L ) + 1;
        if ( B_trial( x_trial, y_trial ) == 1 ) continue; end;
        B_trial( x(n), y(n) ) = 0;
        B_trial( x_trial, y_trial ) = 1;
        [s_trial, num_free_trial] = score_box( B_trial, C, min_interactions, max_interactions, loner_energy );
        assert( length( find(B) ) == N )
        
        % Metropolis-Hastings
        if ( s_trial > s && exp( s - s_trial ) < rand(1) ) continue; end;
        
        % accept
        B = B_trial;
        x(n) = x_trial;
        y(n) = y_trial;
        s = s_trial;
        num_free = num_free_trial;
        
        if mod(i,1000) == 1
            subplot(2,1,1);
            imagesc( B );axis equal; axis off
            
            subplot(2,2,3); plot( all_num_free); xlabel( 'time'); ylabel('num free')
            subplot(2,2,4); plot( all_s );xlabel( 'time'); ylabel('score')
            drawnow();
        end
    end
    all_num_free_save{m} = all_num_free;
    all_s_save{m} = all_s;
    B_save{m} = B;
    all_B_save{m} = all_B; % to make movies
    toc
end

figure(2)
clf;
set(gcf, 'PaperPositionMode','auto','color','white');
subplot(2,1,1);
for m = 1:length( all_num_free_save );
    plot( all_num_free_save{m} )
    mean_num_free_save(m) = mean(   all_num_free_save{m}(500:end) );
    hold on;    
end
legend( num2str(all_C' ) )
xlabel( 'Cycles')
ylabel( 'num free' );
hold off

subplot(2,1,2);
plot( all_K, mean_num_free_save,'o' );
ylabel( 'num free' );
xlabel( 'K' );

save save_simulate_box.mat

    
set( figure(3), 'Position', [233   783   416   530])
colormap( 1 - gray(100));
set(gcf, 'PaperPositionMode','auto','color','white');
axis off
for m = 1:length( all_C )
    subplot(4,5,m)
    imagesc( B_save{m} ); axis equal; axis off
end

%%
set( figure(4), 'Position', [333   883   400   400])
m = find( all_K == 20.0 );
colormap( 1 - gray(100));
set(gcf, 'PaperPositionMode','auto','color','white');
axis off
v = VideoWriter( 'movie.mp4','MPEG-4' );
set(v,'FrameRate',8);
open(v);
for i = 1:20:length( all_B_save{m} )
    imagesc( circshift(all_B_save{m}{i},50) )
    axis equal; axis off
    drawnow()
    writeVideo(v, getframe(gcf) );
end
close(v);



