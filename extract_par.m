% Extract and calculate delft3D parameters for colonisation, mortality and
% post-processing from second ets on - more description in technical overview (PDF)

%% Calculate sedimentation/erosion for mortality
if mor == 1 
    depth        = vs_get(NFS,'map-sed-series','DPS','quiet'); 
    depth_begin  = depth{1}; 
    BedLevelDif  = depth{numel(depth),:}-depth_begin;
    A            = find(BedLevelDif<0);
    burial(A)    = BedLevelDif(A); 
    A            = find(BedLevelDif>0);
    scour(A)     = BedLevelDif(A);  
    clear A
else
    depth        = vs_get(NFS,'map-const','DPS0','quiet'); % bed topography (without morphology) at zeta points trimmed to fit grid
end

%% Calculate flood/dry times for seed colonization
WL               = vs_get(NFS,'map-series','S1','quiet'); % Water level data at zeta points for all time-steps
waterdepth       = cellfun(@plus,depth,WL,'UniformOutput',false);
flood            = zeros(Ndim, Mdim); 
for dts = 1:numel(waterdepth) 
    b_mark          = zeros(Ndim, Mdim); 
    fl              = find(waterdepth{dts,1}>fl_dr); 
    if dts == 1
        flood(fl)   = 1; % for flooded cells set =1
    else
        b_mark(fl)  = 1;
        flood       = flood + b_mark;
    end
end
clear b_mark fl

%% Calculate max/min velocities for mortality
% Remain for future use
U1                      = vs_get(NFS,'map-series','U1','quiet'); 
V1                      = vs_get(NFS,'map-series','V1','quiet'); 
U1Mat                   = struct2mat(U1, 2); 
V1Mat                   = struct2mat(V1, 2); 
xy_velocity_new         = sqrt(U1Mat.^2 + V1Mat.^2); 
velocity_max            = max(xy_velocity_new, [],3); 
clear U1 V1 U1Mat V1Mat xy_velocity_new

%% Calculate flooded/dry cells for seedlings & mature vegetation
% First simulation results from ets =1:
if  ets >= 2
    % Determine matrices as 0
    flood_cumulative         = flood; 
    flood_cumulative_prev    = flood_cumulative; 
    % Seedlings
    for nv = 1:num_veg_types 
        if ets >= LocEco(1,1,nv)
            flood_cumulativeY1(:,:,nv)          = flood;  
            flood_cumulative_prevY1(:,:,nv)     = flood_cumulativeY1(:,:,nv); 
        end % end if statement
    end % end loop veg types
elseif year ~= year_ini && ets == 1
    %% Every other ets within eco. year:
    flood_cumulative_prev    = flood_cumulative; 
    flood_cumulative         = flood_cumulative+ flood;
    % seedlings
    for nv = 1:num_veg_types % loop over number veg types to determine vegetation type dependent start of colonisation
        if ets >= LocEco(1,1,nv) % check if current vegetation type is colonizing
            flood_cumulative_prevY1(:,:,nv)     = flood_cumulativeY1(:,:,nv);    % remember cumulative flood from previous year
            flood_cumulativeY1(:,:,nv)          = flood_cumulative_prevY1(:,:,nv) + flood; % add up subsequent flood
        end
    end % end loop veg types
end  % end if statement to calculate subsequent flood and drying of cells

if year == 1 && ets==1 && Restart == 0 % Cold start from pristine
    Relative_flood0                                                = flood./max(max(flood)); % relative value to seek colonization location
elseif year == year_ini && ets == 1 && Restart == 1 % Hot start
    d3dparameters.Flood(year-1).PerYear(t_eco_year,1)              = {flood./max(max(flood))}; % relative value to seek colonization location
elseif ets==1
    d3dparameters.Burial(year-1).PerYear(t_eco_year,1)             = {burial};
    d3dparameters.Scour(year-1).PerYear(t_eco_year,1)              = {scour};
    d3dparameters.Flood(year-1).PerYear(t_eco_year,1)              = {flood./max(max(flood))}; % relative value to seek colonization location
    d3dparameters.VelocityMax(year-1).PerYear(t_eco_year,1)        = {velocity_max};
    d3dparameters.FloodSeedlings(year-1).PerYear(t_eco_year,1)     = {flood_cumulativeY1};
    d3dparameters.FloodCumulative(year-1).PerYear(t_eco_year,1)    = {flood_cumulative};
else
    d3dparameters.Burial(year).PerYear(ets-1,1)                    = {burial};
    d3dparameters.Scour(year).PerYear(ets-1,1)                     = {scour};
    d3dparameters.Flood(year).PerYear(ets-1,1)                     = {flood./max(max(flood))}; % relative value to seek colonization location
    d3dparameters.VelocityMax(year).PerYear(ets-1,1)               = {velocity_max};
    d3dparameters.FloodSeedlings(year).PerYear(ets-1,1)            = {flood_cumulativeY1};
end
clear flood NFS