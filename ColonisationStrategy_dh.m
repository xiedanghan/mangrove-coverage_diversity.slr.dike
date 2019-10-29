% Script for colonisation of plants with strategy 1 (on bare substrate between max and min water levels);
% Determines the cells where settling possibility for the ETS in colonization window.
% Find cells that are dry at the end of ETS and maximum water depth over the whole ETS.
% This assumes that seedlings are distributed with the tides. A window of opportunity is indirectly
% established as the cell is dry if>50% of the tidal cycle dry which equals one week.
% Is that value realistic? Here random colonization alters locations if turned on.
%% Relative hydroperiod, yearly or last ets?
%>>: Last ets. Because Last ets has a larger influence on the next ets when the seed start to disperse
Sum_area_mark   = zeros(Ndim, Mdim);
SeedLoc         = cell(num_veg_types,1);

%% Step 1: Look for cells where plants are going to colonize
for nv = 1: num_veg_types
    % if within colonization window:
    if   ismember(ets,LocEco(1,:,nv))
        % To avoid plants being assigned to permanent flood/dry cell
        if xL(nv) == 0
            xL(nv)   = xL(nv) + 0.001;
        elseif xR(nv) == 1
            xR(nv)   = xR(nv) - 0.001;
        end
        
        SeedLoc{nv}= find(P >  xL(nv) & P < xR(nv));
        
        % delete the mortality cells where plants can not grow
        if Mortality == 1
            for i=1:size(Mort_list,1)
                SeedLoc{nv}(SeedLoc{nv} == Mort_list(i),:) = [];
            end
        end
        
        %>>CS: random establishment
        if random>0
            rng(1)
            SeedLoc{nv} = randsample(SeedLoc{nv,:},round(length(SeedLoc{nv,:})/random));
        end
        Area_mark              = zeros(Ndim, Mdim);
        Area_mark(SeedLoc{nv}) = 1;
        Sum_area_mark          = Sum_area_mark+Area_mark;
    end % end statement seed dispersal window checking
end
clear i Area_mark Mort_list

%% Step2: Evaluate colonization probability and allocate the number of plants
if year~=1 && sum(sum(Sum_area_mark))~=0 % the 2nd year and cells available, need to consider I*C
%     veg0_mark          = []; % cells temporarily without growing vegetation
    row_new            = [];
    col_new            = [];
    M_mark             = find(Sum_area_mark>0); % cells that plants can grow, e.g. 2 = 2 species
    [row_M,col_M]      = ind2sub(size(Sum_area_mark),M_mark); % convert to 2-d coordinate
%     j=1;
    for i = 1:size(M_mark,1)
        tr_mark        = []; % prescribe matrix
        if ~isempty(trv_trd)
            tr_mark        = find(trv_trd(:,1) == row_M(i) & trv_trd(:,2) == col_M(i)); % exist in trv_trd or not?
        end
        if isempty(tr_mark) % vegetation doesn't exist
            Growth_temp                      = []; % prescribe matrix size
            f_colonize_null_new
            trv_trd                          = [trv_trd; Growth_temp];
%             j          = j+1;
        elseif sum(trv_trd(tr_mark,12)) < num0 % vegetation exists and cells can still take in new vegetation
            Growth_temp                      = []; % prescribe matrix size
            Growth_temp(1:size(tr_mark,1),:) = trv_trd(tr_mark,:); % the original parameters from trv_trd
            trv_trd(tr_mark,:) = []; % delete the original rows in the trv_trd
            % colonization on the cells which vegetation already exist
            f_colonize_new
            trv_trd            = [trv_trd; Growth_temp];
        end
    end
    trv_trd           = sortrows(trv_trd,1:2); % sortrows
    trv_trd(:,20)     = 1:1:size(trv_trd,1); % update matrix sequence
    clear tr_mark Growth_temp i
end