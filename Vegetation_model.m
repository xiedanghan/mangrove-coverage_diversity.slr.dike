%% Vegetation model coupled to hydromorphological model Delft3D

%% Preprocessing
% Set up D3D parameters from mdf-file
inid3d
% Set up vegetation parameters from txt-file
iniveg
% Set up working directory and run initial run to create trim file with initial parameters
ini_work

%% Start simulation
% Start year loop
for year = year_ini:years % years, total simulation years in ineger by ceil funtion
    % Create result folders per year for writing output
    mkdir(strcat(directory,'results_', num2str(year), '\'));
    
    %% Start loop over vegetation processes
    % Loop over ecological time-steps
    for ets = 1:t_eco_year % t_eco_year, number of ecological timesteps in one year = 10
        % Matrices pre-allocate size
        Matrices_pre_size
        
        % Handle Delft3D administration and read MDF and trimfiles -
        d3dadmin
        % Vegetation loop
        if VegPres > 0 % check if dynamic vegetation is present
            % Extract and calculate parameters from delft3D
            extract_par
            
            % Run mortality processes
            mortality_fract_av

            % Vegetation height and diameter start to update
            GrowthStrategy
            
            % Run colonisation module for seed dispersal and establishment
            colonisation
            
            % Vegetation is assigned to grid cells
            settlement
            
            % Save veg-file
            copyfile(strcat(directory, 'work\veg.trd'), strcat(directory,'results_', num2str(year), '\veg', num2str(ets), '.trd'));
            copyfile(strcat(directory, 'work\veg.trv'), strcat(directory,'results_', num2str(year), '\veg', num2str(ets), '.trv'));
        end % end of vegetation processes
        
        % save mdf-file
        copyfile(strcat(directory, 'work\',      ID1, '.mdf'), strcat(directory, 'results_', num2str(year),'/',ID1, '_', num2str(ets), '.mdf' ));
        
        %% Run model
        run_line =  strcat(directory, 'work\', 'Startrun.bat');
        cd(strcat(directory, 'work'));
        system(run_line);
        
        % Map file/output file type storing 28/12/2018
        f_storage
        
    end % end loop over ecological timesteps
    
    
    % Happy message if it worked over the whole time frame
    if year == years
        display('Yeah! You made it!!!');
    end
    
end % end year-loop




