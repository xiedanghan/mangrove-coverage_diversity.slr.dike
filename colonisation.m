% Colonisation: determine the available cells that can be colonized according to strategies

clear SeedLoc
% check colonisation strategy of vegetation type
if general_veg_char(1,3,nv) == 1  % Colonisation strategy 1; on bare substrate = pioneer
    
    ColonisationStrategy_dh % check habitat area and evaluate the growth possibility by checking I and C
    
elseif general_veg_char(1,3,nv) == 2 % Colonistion strategy 2; on bare substrate in combination with morphodynamic activity = sedimentation above certain threshold)
    ColonisationStrategy2V2 % includes morph. activity required for settling
end