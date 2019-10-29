%% Initialize and extract parameters from Delft3D for initial state

%% Read MDF and extract run-id fine grid
ini_mdf  = mdf('read',strcat(name_model_original1, '.mdf'));   
ID1      = strcat(name_model_original1); 

%% Extract static parameters from Delft3D
dimensions  = str2num(cell2mat(ini_mdf.mdf.Data{1,2}(strmatch('MNKmax', char(ini_mdf.mdf.Data{1,2}(:,1)), 'exact'),2)));
Mdim        = dimensions(1,1); 
Ndim        = dimensions(1,2); 
clear dimensions
if mor ==0 
    morfac = morf;
else
    morfac   = strmatch('MorFac', char(ini_mdf.mor.Data{2,2}(:,1)), 'exact'); 
    morfac   = ini_mdf.mor.Data{2,2}(morfac,2); 
    C        = strsplit(morfac{1}); 
    morfac   = str2double(C{1}); 
    clear C a morf
end
% extract time-scales and chezy from mdf
Lchezy                  = strmatch('Ccofu', char(ini_mdf.mdf.Data{1,2}(:,1)), 'exact'); 
chezy                   = str2double(ini_mdf.mdf.Data{1,2}(Lchezy,2)); 
Ltstep                  = strmatch('Flmap', char(ini_mdf.mdf.Data{1,2}(:,1)), 'exact'); 
tstep                   = str2num(cell2mat(ini_mdf.mdf.Data{1,2}(Ltstep,2))); 
tstep                   = tstep(2);
loc_start               = strmatch('Tstart', char(ini_mdf.mdf.Data{1,2}(:,1)), 'exact'); 
Tstart                  = str2double(ini_mdf.mdf.Data{1,2}(loc_start,2))*morfac; 
loc_stop                = strmatch('Tstop', char(ini_mdf.mdf.Data{1,2}(:,1)), 'exact');  
Tstop                   = str2double(ini_mdf.mdf.Data{1,2}(loc_stop,2))*morfac; 
Total_sim_time          = Tstop - Tstart; 
years                   = ceil(Total_sim_time/(365.25*24*60)); 
IT_date                 = ini_mdf.mdf.Data{1,2}(strmatch('Itdate', char(ini_mdf.mdf.Data{1,2}(:,1)), 'exact'),2); 
IT_date                 = cell2mat(IT_date); 
month                   = str2double(IT_date(7:8)); 
day                     = str2double(IT_date(10:11)); 
clear Lchezy Tstart Tstop loc_start loc_stop Total_sim_time Ltstep
if month>1
    IT_date_minutes = (sum(days_in_months(1,1:month-1))+(day-1)*24*60)*morfac; % minutes of IT date within a year
else
    IT_date_minutes = ((day-1)*24*60)*morfac; 
end
clear day month ini_mdf