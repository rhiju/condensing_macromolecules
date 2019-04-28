function [s,num_free, num_loners] = score_box( B, K, min_interactions, max_interactions, loner_energy )
%if  ~exist( 'min_interactions','var') min_interactions = 0; end;
%if  ~exist( 'loner_energy','var') loner_energy = 0; end;
s = 0;
ints = 0*B;
ints = ints + B.*circshift( B, [1 0]);
ints = ints + B.*circshift( B, [-1 0]);
ints = ints + B.*circshift( B, [0 1] );
ints = ints + B.*circshift( B, [0 -1]);

ints = ints + B.*circshift( B, [1 1]);
ints = ints + B.*circshift( B, [1 -1]);
ints = ints + B.*circshift( B, [-1  1] );
ints = ints + B.*circshift( B, [-1 -1]);

num_loners = sum( ints(:)==0 & B(:)>0 );

if ( min_interactions > 0 ); ints( ints(:)<min_interactions ) = 0; end;
if ( max_interactions > 0 ); ints( ints(:)>max_interactions ) = 0; end;
s = -K * sum(sum(ints)) + loner_energy * num_loners;

num_free = length(find( (ints == 0) .* (B == 1) ));

