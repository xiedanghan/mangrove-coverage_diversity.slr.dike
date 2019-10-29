%% Pre-set the matrices size for speed
if  VegPres > 0 && ets ==2 
    flood_cumulative         = zeros(Ndim, Mdim); 
    flood_cumulative_prev    = zeros(Ndim, Mdim); 
    flood_cumulativeY1       = zeros(Ndim, Mdim,num_veg_types); 
    flood_cumulative_prevY1  = zeros(Ndim, Mdim,num_veg_types); 
elseif VegPres > 0 
    burial                      = zeros(Ndim, Mdim);
    scour                       = zeros(Ndim, Mdim);
    BedLevelDif                 = zeros(Ndim, Mdim);
end % end check dynamic vegetation presence