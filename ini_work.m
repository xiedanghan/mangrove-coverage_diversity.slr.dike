%% The initial start of model without vegetation
%% Copy + adjust + model
if Restart==0
    copyfile(strcat(directory, 'initial files'),strcat(directory, 'work'));
    ets     = 0;
    MDF1    = mdf('read',(strcat(directory, 'initial files\', ID1,'.mdf')));
    % Determine the start and stop time from mdf
    Time_start  = str2double(cell2mat(MDF1.mdf.Data{1,2}(strmatch('Tstart', char(MDF1.mdf.Data{1,2}(:,1)), 'exact'),2)));
    Time_stop   = str2double(cell2mat(MDF1.mdf.Data{1,2}(strmatch('Tstop', char(MDF1.mdf.Data{1,2}(:,1)), 'exact'),2)));
    
    % Adjust runtime in mdf-file for ecological timestep
    MDF1.mdf.Data{1,2}(strmatch('Tstart', char(MDF1.mdf.Data{1,2}(:,1)), 'exact'),2) = {sprintf('%2.8g',(Time_start))};
    MDF1.mdf.Data{1,2}(strmatch('Tstop', char(MDF1.mdf.Data{1,2}(:,1)), 'exact'),2) = {sprintf('%2.8g',(Time_start +eco_timestep/morfac))};
    %>>DH: 03/12/2018 Update Flmap
    MDF1.mdf.Data{1,2}(strmatch('Flmap', char(MDF1.mdf.Data{1,2}(:,1)), 'exact'),2) = {sprintf('%2.8g  %2.8g  %2.8g',Time_start,tstep,Time_start+eco_timestep/morfac)};
    
    % Vegetation availability
    Trtrou   = cell2mat(MDF1.mdf.Data{1,2}(strmatch('Trtrou', char(MDF1.mdf.Data{1,2}(:,1)), 'exact'),2));
    if VegPres == 0 && ismember('Y',Trtrou)
        MDF1.mdf.Data{1,2}(strmatch('Trtrou', char(MDF1.mdf.Data{1,2}(:,1)), 'exact'),2) = {sprintf('%s','#N#')};
    end
    mdf('write',MDF1, strcat(ID1), strcat(directory,'work\')); 
    
    run_line =  strcat(directory, 'work\', 'Startrun.bat');
    cd(strcat(directory, 'work'));
    system(run_line);
    clear mdf MDF1
    year_ini = 1;
else
    % Copy a new BCC file from initial to work folder
    copyfile(strcat(directory, 'initial files\', name_model_original1,'.bcc'),strcat(directory, 'work'));
    % Look for the last results file and read the year no. when ets == 12
    filefolder  = fullfile(directory);
    diroutput   = dir(fullfile(filefolder,'*'));
    year_temp   = zeros(length(diroutput),1);
    for i = 1 : length(diroutput)
        filename = diroutput(i,1).name;
        if ismember('results',filename)
            year_loc     = strfind(filename,'results'); % SSC location
            year_temp(i) = str2double(filename(year_loc+8:end)); % The value of SSC
        end
    end
    % Check the folder validity
    File_check       = fullfile(strcat(directory,'results_',num2str(max(year_temp)),'\'));
    diroutput_check  = dir(fullfile(File_check,strcat('*',num2str(t_eco_year),'.mat'))); % if finish, should contain maximum ets
    filename_check   = {diroutput_check.name};
    if isempty(filename_check)
        error('Error .\Original simulation should complete');
    else
        year_ini    = max(year_temp)+1; % Start a new year
        % Map file: Update the dat and def file into the work folder
        %>Delete the old dat and def files from work folder
        delete(strcat(directory, 'work\trim-', ID1, '.def'));
        delete(strcat(directory, 'work\trim-', ID1, '.dat'));
        %>Delete old veg files TRV and TRD
        delete(strcat(directory, 'work\veg.trd'));
        delete(strcat(directory, 'work\veg.trv'));
        %>Delete old mdf files from work folder
        delete(strcat(directory, 'work\', ID1, '.mdf'));
        %>Delete old tri-diag files
        delete(strcat(directory,'work\tri-diag.',ID1));
        
        %>Copy the dat and def from the very last simulation
        copyfile(strcat(directory, 'results_', num2str(max(year_temp)), '/trim-', ID1, '_', num2str(t_eco_year),'.def'),...
            strcat(directory, 'work\trim-', ID1, '.def'));
        copyfile(strcat(directory, 'results_', num2str(max(year_temp)), '/trim-', ID1, '_', num2str(t_eco_year),'.dat'),...
            strcat(directory, 'work\trim-', ID1, '.dat'));
        %>Copy the mdf file from the very last simulation
        copyfile(strcat(directory, 'results_', num2str(max(year_temp)), '/', ID1, '_', num2str(t_eco_year),'.mdf'),...
            strcat(directory, 'work\', ID1, '.mdf'));
        
        % Refreh vegetation information
        if VegPres ~= 0
            %>Add vegetation files
            try
                %>Copy the TRV and TRD file from the very last simulation
                copyfile(strcat(directory,'results_', num2str(max(year_temp)), '\veg', num2str(t_eco_year), '.trd'),...
                    strcat(directory, 'work\veg.trd'));
                copyfile(strcat(directory,'results_', num2str(max(year_temp)), '\veg', num2str(t_eco_year), '.trv'),...
                    strcat(directory, 'work\veg.trv'));
            catch
                % If results files don't have veg files, turn to initial files for help
                copyfile(strcat(directory,'\initial files\veg.trd'), strcat(directory, 'work\veg.trd'));
                copyfile(strcat(directory,'\initial files\veg.trv'), strcat(directory, 'work\veg.trv'));
            end
            
            for ets = 1 : t_eco_year
                try 
                    load(strcat(directory,'results_',num2str(max(year_temp)),'\','trv_trd',num2str(ets),'.mat')); % load trv_trd
                    trv_trd(trv_trd(:,11)==900,:) = []; % delete all the information about root
                catch 
                    trv_trd = [];
                end
                trv_trd_dh(year_ini-1,ets) = {trv_trd}; % for mortality, roots are not included
            end
            
            rough_eq            = zeros(num_veg_types,1);
            height              = zeros(num_veg_types,1);
            dens                = zeros(num_veg_types,1);
            drag_coeff          = zeros(num_veg_types,1);
            chezy_coeff         = zeros(num_veg_types,1);
            vegtype             = zeros(num_veg_types,1);

            for nv=1:num_veg_types
                % TRD
                rough_eq(nv,1)     = general_veg_char(1, 5, nv);
                height(nv,1)       = Shoot_height0(nv); % shoot height, (m)
                dens(nv,1)         = num_all/S_cell*stem_diameter0(nv); % density (1/m)
                drag_coeff(nv,1)   = 1.5;
                chezy_coeff(nv,1)  = chezy;
                vegtype(nv,1)      = nv;
            end% end loop over plant coordinates
            
            % if vegetation exists
            fid_mdf = fopen(strcat(directory,'work\',ID1,'.mdf'),'r');
            mdf     = textscan(fid_mdf,'%s','delimiter','\n'); % delimit the numbers and remove the comma in between
            fclose(fid_mdf);
            try
                av                = strmatch('Trtrou',mdf{1,1});
                mdf{1,1}{av,1}    = strcat('Trtrou = ',sprintf('%s',' #Y#'));
                % Write new mdf-file
                fid_mdf = fopen(strcat(directory,'work\',ID1,'.mdf'),'w');
                for k=1:numel(mdf{1,1})
                    fprintf(fid_mdf,'%s\r\n',mdf{1,1}{k,1});
                end
                fclose(fid_mdf);
            catch
                % 'do nothing'
            end
            
            
        else % if vegetation doexn't exist, delete vegetation information from mdf
            fid_mdf = fopen(strcat(directory,'work\',ID1,'.mdf'),'r');
            mdf     = textscan(fid_mdf,'%s','delimiter','\n'); % delimit the numbers and remove the comma in between
            fclose(fid_mdf);
            try
                av                = strmatch('Trtrou',mdf{1,1});
                mdf{1,1}{av,1}    = strcat('Trtrou = ',sprintf('%s',' #N#'));
                % Write new mdf-file
                fid_mdf = fopen(strcat(directory,'work\',ID1,'.mdf'),'w');
                for k=1:numel(mdf{1,1})
                    fprintf(fid_mdf,'%s\r\n',mdf{1,1}{k,1});
                end
                fclose(fid_mdf);
            end
            
        end

    end
    clear filefolder diroutput year_temp i filename year_loc File
    clear File_check diroutput_check filename_check ets av
    
end