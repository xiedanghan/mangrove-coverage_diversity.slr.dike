%% Settlement module. Vegetation is assigned to grid cells with certain area fraction.
% Find the cells with space for colonization and the fraction that can be colonized. Fills up the space with
% the new fraction from current ETS==1. Adds the trachytope ID to new fractions for each vegetation type and saves it in matrix output.
% Opens existing trv-file and adds the new fractions, sorted after the cell numbers.
%----------------Man, say sth--------------------**--------
%>>dh: I am a referee, so allocate area fraction when coexist
%>>dh: I am a donkey, area fraction always represents no. of plants by timing total no.
if year==1 && ets==1
    % Initial area fraction by pre-allocation
    rough_eq            = zeros(num_veg_types,1);
    height              = zeros(num_veg_types,1);
    dens                = zeros(num_veg_types,1);
    drag_coeff          = zeros(num_veg_types,1);
    chezy_coeff         = zeros(num_veg_types,1);
    vegtype             = zeros(num_veg_types,1);
    % Veg file
    for nv=1:num_veg_types
        % TRD
        rough_eq(nv,1)     = general_veg_char(1, 5, nv);
        height(nv,1)       = Shoot_height0(nv); % shoot height, (m)
        %         dens(nv,1)         = num0/S_cell*stem_diameter0(nv); % density (1/m)
        % 13/08/2018 consider roots
        dens(nv,1)         = num_all/S_cell*stem_diameter0(nv); % density (1/m)
        drag_coeff(nv,1)   = 1.5;
        chezy_coeff(nv,1)  = chezy;
        vegtype(nv,1)      = nv;
    end% end loop over plant coordinates

    % Preallocate trv_trd size
    %:: Content of trv_trd:
    % 1N| 2M| 3trachNo| 4Areafractioin| 5trachids| 6rougheq| 7h(m)| 8dens(1/m)| 9Cd| 10Cz| 11vegtype| 12vegnum|
    % 13vegdia(cm)|14IndS| 15SingleW| 16MultW| 17ComS| 18I*C| 19MortMark| 20MatrixNo| 21RootNum| 22StemRootNum
    trv_trd            = [];
    % Construct trv_trd
    M_mark             = find(Sum_area_mark>0); % cells that plants can grow, e.g. 2 = 2 species
    [row_M,col_M]      = ind2sub(size(Sum_area_mark),M_mark); % convert to 2-d coordinate
    for i = 1:size(M_mark,1)
        Growth_temp                      = []; % prescribe matrix size
        f_colonize_null_new
        trv_trd                          = [trv_trd; Growth_temp];
    end
    
    % Add the roots and Output the results on the basis of trv_trd
    f_output
    
    % format
    trvtrd_dh(year, ets)          = {trv_trd}; % Save for next mortality
else
    %% when ets>1
    f_output
    % format
    trvtrd_dh(year, ets)          = {trv_trd}; % Save for next mortality
end

% save file trv_trd
savefile = strcat('trv_trd',num2str(ets));
savefile = strcat(directory, 'results_', num2str(year),'\', savefile);
save(savefile, 'trv_trd');