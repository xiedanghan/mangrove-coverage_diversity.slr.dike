%% Pre-set the matrices size for speed
if  VegPres > 0 && ets ==2 
    % Reset temporary matrices at 2nd ets every year
    flood_cumulative         = zeros(Ndim, Mdim); % reset matrix for subsequent flooding
    flood_cumulative_prev    = zeros(Ndim, Mdim); % reset subsequent flooding matrix previous year
    flood_cumulativeY1       = zeros(Ndim, Mdim,num_veg_types); % reset matrix for subsequent flooding of one year plants per veg type
    flood_cumulative_prevY1  = zeros(Ndim, Mdim,num_veg_types); % reset subsequent flooding matrix previous year of one year plants per veg type
elseif VegPres > 0 % check if dynamic vegetation is present then reset matrices after ets
    burial                      = zeros(Ndim, Mdim);% reset year matrix for burial
    scour                       = zeros(Ndim, Mdim); % reset year matrix for scour
    BedLevelDif                 = zeros(Ndim, Mdim);
end % end check dynamic vegetation presence