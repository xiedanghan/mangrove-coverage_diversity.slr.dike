% Initial module 'general_input' calls veg module and defines run paths.
% Here different keywords need to be set to start a simulation with/without vegetation, with morphology, or from restart files.
% If restart, the trim-files are necessary (trim-*model name*.dat and trim-*model name*.def) as well as 
% matrice 'fraction_area_all_veg.m' and the 'veg.trv' with the locations of already settled vegetation. Moreover, random establishment can be chosen.

%% Initialisation
clear
close all
clc
% Define run directory
directory_head          = 'F:\MMM model\EquilibriumTest\1_1K\TR5m 2880min MorFac30 SSC0_10_30\'; % Link to the folders with modules and initial files
name_model_original1    = '280x1'; % original name of model grid coarse
% name_model_original2     = '600x2500x5v1'; % original name of model grid fine
name_model              = 'SSC30_veg_springneap_tide'; % folder of scenario run
directory = strcat(directory_head, name_model,'\'); % main directory
cd(strcat(directory, 'initial files\')); % directory initial files
% add paths with functions and scripts of modules
addpath(strcat(directory,'Matlab vegetation modules'));
addpath(strcat(directory,'Matlab functions'));
% turn this on in case of older matlab version (f.e. in GIS-lab)
addpath('C:\Program Files (x86)\Deltares\Delft3D 4.01.00\win32\delft3d_matlab')  % code for pcs with older version of matlab

%% User defined parameters for Vegetation model
% User defined parameters
VegPres             = 1; % 1 = vegetation present, 0 = no vegetation present
Root                = 1; % 1 = Mangrove root included, 0 = mangrove root excluded
Static              = 0; % 1 = static vegetation (no growth and mortality) but dynamic colonisation at certain timestep(a la Nicholas & Crosato)
random              = 0; % random establishment (1/rand of fraction that should remain)
Restart             = 0; % 1 = hot start from work file, 0 = run from pristine conditions
Storage             = 1; % 1 = save the user-defined output file, 0 = save the delft3D output file 
SedThres            = 0.01; % sedimentation threshold for ColonisationStrategy 2B (in m) - defined in veg.txt-file
mor                 = 1; % 1= include morphology, 0 = exclude morphology
morf                = 30; % give manual morfac in case without morphological development
fl_dr               = 0.1; % Boundary for water flooding/drying (m)
t_eco_year          = 12; % number of ecological time-steps (ets)  per year
t_days_year         = 360; % number days per year to guarantee no integers in time-scales
silt                = 0; % 1 = include silt, 0 = not include silt (not updated yet)
mort_grad           = 0; % switch for mortality interval;2 to use flooding per tide[fraction], 1 to use dts-steps for mortality; 0 uses ets
num0                = 750; % initial individuals of plants in one cell
num_all             = 2000000; % The max number of columns in one cell incl. plants and roots
S_cell              = 2500; % Cell size area
Mort_plant          = 10; % Number of plants need to be removed at one time
Grow_plant          = 10; % Number of plants need to be grown at one time
%% run vegetation model
Vegetation_model

