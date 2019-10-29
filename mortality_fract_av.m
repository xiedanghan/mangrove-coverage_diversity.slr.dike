%% Initialisation - loading matrices from extract_par
%---------------------------Man, I am Grove--------------------------------------%
%-----If I die, then I*C should consecutively smaller than 0.5 for 5 years-------%
%----------------After I die, no new life forms at my place----------------------%
%----------------Remember, a yearly death, so I should be the yearly I-----------%

%% Cache clean - remove all the roots
if ~(year == 1 && ets ==1) && ~isempty(trv_trd)
    trv_trd(trv_trd(:,11)==900,:) = [];
end
clear Root_mark
%% Mortality starts
% If mortality occurs, change this value to 1, colonization will negelect the mort cells
Mortality = 0; % No mortality occurs

% Acquire relative flood hydroperiod of last ets for growth only
if year==1 && ets==1 && Restart==0
    display(['Vegetation will be assigned to the corresponding cells at the Year ' num2str(year) ' with a Total Num. of ' num2str(num0) ' each!' ]);
    Relative_flood     = Relative_flood0;
elseif ets ==1
    Relative_flood     = cell2mat(d3dparameters.Flood(year-1).PerYear(t_eco_year,1));
else
    Relative_flood     = cell2mat(d3dparameters.Flood(year).PerYear(ets-1,1));
end
P                      = Relative_flood; % relative hydro-period
% Update inundation stress and competition stress
if ~(year == 1 && ets ==1) && ~isempty(trv_trd)  % 09/10/2018 exclude null trv_trd
    %>>based on Trim file of last ets, I will be updated here
    trv_trd_addIC      = trv_trd;
    f_add_I_C % Add inundation stress and competition stress
    trv_trd            = trv_trd_addIC;
end
clear Relative_flood
%>>now diameter, height and I, C ... are the real parameters of last ets
%::Save trv_trd after every run or before every new run
if ets==1 && year==1
    display(['In Year ' num2str(year) ' and ETS' num2str(ets) ', vegetation has no effect!' ]);
elseif ets==1
    trv_trd_dh(year-1,t_eco_year) = {trv_trd}; 
else
    trv_trd_dh(year,ets-1)        = {trv_trd}; 
end

%% < Mortality Process >
if year==1 && Restart==0 
    fprintf(['Vegetation starts to colonize in Year ' num2str(year) ', NO vegetation dies at the very beginning!']);
elseif ets==1 && ~isempty(trv_trd) % 09/10/2018 exclude null trv_trd
    trv_trd_temp              = mean(cat(3, trv_trd_dh{year-1,:}),3);
    Ave_Inundation_temp       = trv_trd_temp(:,14); 
    trv_trd_temp              = trv_trd; 
    trv_trd_temp(:,6)         = trv_trd_temp(:,14);
    trv_trd_temp(:,14)        = Ave_Inundation_temp;
    trv_trd_temp(:,18)        = Ave_Inundation_temp.*trv_trd_temp(:,17); 
    Mort_mark                 = zeros(size(trv_trd_temp,1),1);
    Mort_mark(trv_trd_temp(:,18)<=0.5) = 1; 
    trv_trd_temp(:,19)        = trv_trd_temp(:,19).*Mort_mark(:,1)+ Mort_mark(:,1); 
    trv_trd_temp(:,20)        = 1:1:size(trv_trd_temp,1);

    if ismember(5,trv_trd_temp(:,19))
        fprintf(['Vegetation starts to die in Year ' num2str(year) ', ETS ' num2str(ets) '!']);
        f_mortality 
        Mortality = 1; 
    end
    trv_trd_temp(:,14)  = trv_trd_temp(:,6); 
    trv_trd_temp(:,6)   = rough_eq(1);
    trv_trd             = trv_trd_temp; 
end
clear Mort_mark Mort_Loc Mort_temp Mort_rc_temp Mort_cell
clear Death_mark j Bio_total_cell trv_trd_temp Ave_Inundation_temp