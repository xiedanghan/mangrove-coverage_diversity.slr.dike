%% Initialization of vegetation

eco_timestep = (t_days_year*24*60)/t_eco_year; 
if VegPres > 0 
    for nn = 1:20
        matFilename = sprintf('Veg%d.txt', nn);
        Check = exist(matFilename,'file');
        if Check ==2
            num_veg_types = nn; 
        else
            continue;
        end
    end
    clear Check nn matFilename
    days_in_months          = [30 30 30 30 30 30 30 30 30 30 30 30]; % matrix for days in each month (total 360 days)
    
    %% Read characteristics from vegetation input files     %%     read_vegetation
    % Initialisation - preparation of colonisation
    general_veg_char    = zeros(1, 13, num_veg_types); 
    life_veg_char       = cell(num_veg_types,1); 
    LocEco              = zeros(1,12,num_veg_types); 
    a                   = zeros(num_veg_types,1); % Stress inundation constant 1, a (-)
    b                   = zeros(num_veg_types,1); % Stress inundation constant 2, b (-)
    c                   = zeros(num_veg_types,1); % Stress inundation constant 3, c (-)
    xL                  = zeros(num_veg_types,1); % Lower limit habitat relative inundation period
    xR                  = zeros(num_veg_types,1); % Upper limit habitat relative inundation period
    % Competition stress parameters preallocate matrix size
    d                   = zeros(num_veg_types,1); % Stress competition constant 1, d (-)
    B_half              = zeros(num_veg_types,1); % Stress competition constant 2, B0.5 (kg/ha)
    ind_a               = zeros(num_veg_types,1); % Biomass above-ground index, ind_a(-)
    bio_a               = zeros(num_veg_types,1); % Biomass above-ground constant, bio_a(-)
    ind_b               = zeros(num_veg_types,1); % Biomass below-ground index, ind_b(-)
    bio_b               = zeros(num_veg_types,1); % Biomass below-ground constant, bio_b(-)
    % Initial vegetation parameters pre-allocate
    stem_diameter0      = zeros(num_veg_types,1);
    Shoot_height0       = zeros(num_veg_types,1);
    max_root            = zeros(num_veg_types,1);
    Cd_root             = zeros(num_veg_types,1);
    % Growth constants pre-allocate
    G                   = zeros(num_veg_types,1); % Growth constant 1, G (cm/year)
    b2                  = zeros(num_veg_types,1); % (-) Growth constant 2
    b3                  = zeros(num_veg_types,1); % (/cm)Growth constant 3
    Dmax                = zeros(num_veg_types,1); % Maximum stem diameter, Dmax (cm)
    Hmax                = zeros(num_veg_types,1); % Maximum shoot height, Hmax (cm)
    
    %% **** Create matrices with vegetation data ****
    for nv = 1:num_veg_types % start loop over vegetation types
        % ****** Load vegetation parameters from veg.txt files *******
        life_veg_temp   = []; % reset temporary characteristics per vegetation type
        
        % Read general data from vegetation-txt files
        FID                         = fopen(strcat(directory, '\initial files\', 'Veg', num2str(nv), '.txt'));
        datacell                    = textscan(FID, '%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f%7.3f/n%*f', 'HeaderLines', 37);
        fclose(FID);
        mat_veg                     = cell2mat(datacell); % put general vegetation characteristics in matrix
        general_veg_char(:, :, nv)  = mat_veg; % put data of vegetation type in total vegetation matrix
        num_ls                      = mat_veg(6); % count number of lifestages
        num_mon                     = mat_veg(2);% extract amount of months for seed dispersal
        clear FID datacell mat_veg
        
        % Construct matrix for seed dispersal months
        FID                         = fopen(strcat(directory, '\initial files\', 'Veg', num2str(nv), '.txt'));
        m=repmat('%f',1,num_mon);
        ColEco                      = textscan(FID, strcat(m, '/n%*f'), 'HeaderLines', 38); % ets that seed dispersal occurs, headerline help to jumt to line 37 directly
        fclose(FID);
        LocEco(:,1:num_mon,nv)      = cell2mat(ColEco); % ets that seed dispersal occurs
        clear FID m ColEco
        
        % Extract life-stage data
        for nls = 1:num_ls % loop over life stages
            FID                  = fopen(strcat(directory, '\initial files\', 'Veg', num2str(nv), '.txt'));
            data                 = textscan(FID,'%f%f%f%f%f%f%f%f%f%f%f%f%f%f/n%*f', 'HeaderLines', 38+nls);
            fclose(FID);
            mat_veg             = cell2mat(data); % put data in matrix
            life_veg_temp(nls, :) = mat_veg;
        end % end loop over life stages
        
        life_veg_char{nv,1}      = life_veg_temp; % fill matrix with data of current vegetation type from vegx.txt-file
        clear FID data mat_veg life_veg_temp
        
        % **** Creat veg matrices which will be frequently used afterwards *****
        % Inundation stress parameters/Fitness function parameters
        a(nv)               = life_veg_char{nv,1}(1,6);
        b(nv)               = life_veg_char{nv,1}(1,7);
        c(nv)               = life_veg_char{nv,1}(1,8);
        xL(nv)              = general_veg_char(1, 10, nv);
        xR(nv)              = general_veg_char(1, 11, nv);
        % Competition stress parameters/Biomass stress parameters
        d(nv)               = life_veg_char{nv,1}(1,9); % maybe change to d(nv)
        B_half(nv)          = life_veg_char{nv,1}(1,10);
        ind_a(nv)           = life_veg_char{nv,1}(1,11);
        bio_a(nv)           = life_veg_char{nv,1}(1,12);
        ind_b(nv)           = life_veg_char{nv,1}(1,13);
        bio_b(nv)           = life_veg_char{nv,1}(1,14);
        % Growth function: above-ground
        G(nv)               = life_veg_char{nv,1}(1,3); % Growth constant 1, G (cm/year)
        b2(nv)              = life_veg_char{nv,1}(1,4); % (-) Growth constant 2
        b3(nv)              = life_veg_char{nv,1}(1,5); % (/cm)Growth constant 3
        Dmax(nv)            = life_veg_char{nv,1}(1,1); % Maximum stem diameter, Dmax (cm)
        Hmax(nv)            = life_veg_char{nv,1}(1,2); % Maximum shoot height, Hmax (cm)
        % Vegetation characteristics
        stem_d0(nv)         = general_veg_char(1,7,nv);
        stem_diameter0(nv)  = stem_d0(nv)/100; % shoot diameter, (m)
        Shoot_height0(nv)   = (137+b2(nv)*stem_d0(nv)-b3(nv)*stem_d0(nv)^2)/100; % shoot height, (m).
        max_root(nv)        = general_veg_char(1,12,nv);
        Cd_root(nv)         = general_veg_char(1,13,nv);
    end
    clear stem_d0
end % end check if dynamic vegetation is present