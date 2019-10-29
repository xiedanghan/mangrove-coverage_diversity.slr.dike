%% A module developed for reading mdf file and trim file
fid_mdf1 = fopen(strcat(directory,'work\',ID1,'.mdf'),'r');
mdf1     = textscan(fid_mdf1,'%s','delimiter','\n'); 
fclose(fid_mdf1);
NFS      = vs_use(strcat(directory, 'work\', 'trim-', ID1,'.dat'),'quiet'); 

% Run Delft3D administration function which adjusts mdf-file for further calculations
if  Static ~= 1 
    d3d_admin_v5(directory, ID1, (eco_timestep/morfac), ets, mdf1{1,1}, year, mor,tstep, Restart);
else 
    d3d_admin_v5(directory, ID1, (eco_timestep/morfac), ets, mdf, year, t_eco_year,mor,1, Restart,silt);
end
