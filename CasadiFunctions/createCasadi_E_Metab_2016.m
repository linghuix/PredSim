function [fgetMetabolicEnergySmooth2016all] = createCasadi_E_Metab_2016(S,model_info)
% --------------------------------------------------------------------------
% createCasadi_E_Metab
%   Function to create Casadi functions for metabolic energy.
%   
% INPUT:
%   - S -
%   * setting structure S
% 
%   - model_info -
%   * structure with all the model information based on the OpenSim model
%
% OUTPUT:
%   - fgetMetabolicEnergySmooth2010all -
%   * Casadi functions for metabolic energy based on Uchida (2016)
% 
% Original author: Minh Truong, KTH
% Original date: 09-10-2024
%
% Last edit by: 
% Last edit date: 
% --------------------------------------------------------------------------

import casadi.*
NMuscle = model_info.muscle_info.NMuscle;
lMo = struct_array_to_double_array(model_info.muscle_info.parameters,'lMo');
vMmax = struct_array_to_double_array(model_info.muscle_info.parameters,'vMmax');
%% Metabolic energy models
act_SX          = SX.sym('act_SX',NMuscle,1); % Muscle activations
exc_SX          = SX.sym('exc_SX',NMuscle,1); % Muscle excitations
lMtilde_SX      = SX.sym('lMtilde_SX',NMuscle,1); % N muscle fiber lengths
vM_SX           = SX.sym('vM_SX',NMuscle,1); % Muscle fiber velocities
Fce_SX          = SX.sym('FT_SX',NMuscle,1); % Contractile element forces
Fiso_SX         = SX.sym('Fiso_SX',NMuscle,1); % N forces (F-L curve)
musclemass_SX   = SX.sym('musclemass_SX',NMuscle,1); % Muscle mass
pctst_SX        = SX.sym('pctst_SX',NMuscle,1); % Slow twitch ratio
modelmass_SX    = SX.sym('modelmass_SX',1); % Model mass
b_SX            = SX.sym('b_SX',1); % Parameter determining tanh smoothness

% Uchida et al. (2016)
[energy_total_sm_SX,Adot_sm_SX,Sdot_sm_SX,Wdot_sm_SX,...
    energy_model_sm_SX] = getMetabolicEnergySmooth2016all(exc_SX,act_SX,...
    lMtilde_SX,vM_SX,Fce_SX,musclemass_SX,pctst_SX,vMmax,lMo,Fiso_SX,...
    modelmass_SX,b_SX);
       
fgetMetabolicEnergySmooth2016all = ...
    Function('fgetMetabolicEnergySmooth2016all',...
    {exc_SX,act_SX,lMtilde_SX,vM_SX,Fce_SX,musclemass_SX,...
    pctst_SX,Fiso_SX,modelmass_SX,b_SX},{energy_total_sm_SX,...
    Adot_sm_SX,Wdot_sm_SX,Sdot_sm_SX,energy_model_sm_SX});
end