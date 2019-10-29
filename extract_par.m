% Extract and calculate delft3D parameters for colonisation, mortality and
% post-processing from second ets on - more description in technical overview (PDF)
%----------------Let's say, ets=1 here stores the results of last run -----------------------%

%% Calculate sedimentation/erosion for mortality
if mor == 1 % if morphology is included
    depth        = vs_get(NFS,'map-sed-series','DPS','quiet'); % bed topography with morphological changes
    depth_begin  = depth{1}; % Bed level matrix at begin of timestep trimmed to fit grid
    % Bedlevel difference in this ets
    BedLevelDif  = depth{numel(depth),:}-depth_begin;
    A            = find(BedLevelDif<0);
    burial(A)    = BedLevelDif(A); % burial, differences < 0
    A            = find(BedLevelDif>0);
    scour(A)     = BedLevelDif(A);  % scour, differences > 0
    clear A
else
    % In case of only hydrology
    depth        = vs_get(NFS,'map-const','DPS0','quiet'); % bed topography (without morphology) at zeta points trimmed to fit grid
end

%% Calculate flood/dry times for seed colonization
% Extract water levels
WL               = vs_get(NFS,'map-series','S1','quiet'); % Water level data at zeta points for all time-steps
% dh
waterdepth       = cellfun(@plus,depth,WL,'UniformOutput',false);
flood            = zeros(Ndim, Mdim); % preallocate matrix
%%>>MB 08/03/2018
% Calculate water depth from water levels and bathymetry
for dts = 1:numel(waterdepth) % determine water depth of all saved hydrol ts
    % Write flooded days to matrix
    b_mark          = zeros(Ndim, Mdim); % preallocate matrix
    fl              = find(waterdepth{dts,1}>fl_dr); % water depth has to be higher than fl-drying threshold
    if dts == 1
        flood(fl)   = 1; % for flooded cells set =1
    else
        b_mark(fl)  = 1;
        flood       = flood + b_mark; % sum of all time-steps flooded
    end
end
clear b_mark fl

%% Calculate max/min velocities for mortality
% Remain for future use
U1                      = vs_get(NFS,'map-series','U1','quiet'); % extract U velocity in U point
V1                      = vs_get(NFS,'map-series','V1','quiet'); % extract V velocity in V point
U1Mat                   = struct2mat(U1, 2); % putting U1 from d3d-output in 3D matrix
V1Mat                   = struct2mat(V1, 2); % putting V1 from d3d-output in 3D matrix
xy_velocity_new         = sqrt(U1Mat.^2 + V1Mat.^2); % calculate combined velocity in U and V direction using Pythagoras for each cell for both time-steps (ts)
velocity_max            = max(xy_velocity_new, [],3); % find maximum in combined velocities per cell from both ts and write to 2D-matrix
clear U1 V1 U1Mat V1Mat xy_velocity_new

%% Calculate flooded/dry cells for seedlings & mature vegetation
% First simulation results from ets =1:
if  ets >= 2
    % Determine matrices as 0
    flood_cumulative         = flood; % at first timestep, set flood cumulative to current flood
    flood_cumulative_prev    = flood_cumulative; % cumulative flood from previous ets equals this ets
    % Seedlings
    for nv = 1:num_veg_types % loop over number veg types to determine vegetation type dependent start of colonisation
        % dh: As soon as one veg colonize, flood periods will be recorded
        if ets >= LocEco(1,1,nv)% check if current vegetation type has colonized
            flood_cumulativeY1(:,:,nv)          = flood;  % fill matrix for first year with data of flooded vs. dry cells for each nv
            flood_cumulative_prevY1(:,:,nv)     = flood_cumulativeY1(:,:,nv); % fill matrix of previous year with data flooded vs. dry
        end % end if statement
    end % end loop veg types
elseif year ~= year_ini && ets == 1
    %% Every other ets within eco. year:
    flood_cumulative_prev    = flood_cumulative; % subsequent flood from cumulative matrices
    flood_cumulative         = flood_cumulative+ flood; % add up flood of this year (flood_current) and last year (flood_cumulative) so no. of ets its flooded in a row
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