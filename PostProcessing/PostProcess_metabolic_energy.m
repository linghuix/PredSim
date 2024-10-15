function [R] = PostProcess_metabolic_energy(model_info,f_casadi,R)
% --------------------------------------------------------------------------
% PostProcess_metabolic_energy
%   This function computes the metabolic energy expenditure for the predicted
%   gait, according to different metabolic models.
%   Implemented models are:
%       * Bhargava et al. (2004)
% 
% INPUT:
%   - S -
%   * setting structure S
%
%   - model_info -
%   * structure with all the model information based on the OpenSim model
% 
%   - f_casadi -
%   * Struct containing all casadi functions.
%
%   - R -
%   * struct with simulation results
%
% OUTPUT:
%   - R -
%   * struct with simulation results
% 
% Original author: Lars D'Hondt
% Original date: 19/May/2022
%
% Last edit by: Minh Truong
% Last edit date: 
% --------------------------------------------------------------------------

N = size(R.kinematics.Qs,1);
NMuscle = model_info.muscle_info.NMuscle;
pctsts = struct_array_to_double_array(model_info.muscle_info.parameters,'slow_twitch_fiber_ratio');
MuscleMass = struct_array_to_double_array(model_info.muscle_info.parameters,'muscle_mass');
%% Bhargava et al. (2004)
% Get metabolic energy rate 
if strcmp(R.S.metabolicE.model,'Bhargava2004')

R.metabolics.Bhargava2004.Edot_gait = zeros(N,NMuscle);
R.metabolics.Bhargava2004.Adot = zeros(N,NMuscle);
R.metabolics.Bhargava2004.Mdot = zeros(N,NMuscle);
R.metabolics.Bhargava2004.Sdot = zeros(N,NMuscle);
R.metabolics.Bhargava2004.Wdot = zeros(N,NMuscle);
R.metabolics.Bhargava2004.Edot_incl_basal = zeros(N,1);

for i=1:N
    [Edot_tot_i,Adot_i,Mdot_i,Sdot_i,Wdot_i,Edot_b_i] = f_casadi.getMetabolicEnergySmooth2004all(...
            R.muscles.a(i,:)',R.muscles.a(i,:)',R.muscles.lMtilde(i,:)',R.muscles.vM(i,:)',...
            R.muscles.Fce(i,:)',R.muscles.Fpass(i,:)',MuscleMass',pctsts,R.muscles.Fiso(i,:)',...
            R.misc.body_mass,R.S.metabolicE.tanh_b);

    R.metabolics.Bhargava2004.Edot_gait(i,:) = full(Edot_tot_i)';
    R.metabolics.Bhargava2004.Adot(i,:) = full(Adot_i)';
    R.metabolics.Bhargava2004.Mdot(i,:) = full(Mdot_i)';
    R.metabolics.Bhargava2004.Sdot(i,:) = full(Sdot_i)';
    R.metabolics.Bhargava2004.Wdot(i,:) = full(Wdot_i)';
    R.metabolics.Bhargava2004.Edot_incl_basal(i) = full(Edot_b_i)';

end

% cost of transport
E_sum_GC = trapz(R.time.mesh_GC(1:end-1),R.metabolics.Bhargava2004.Edot_incl_basal);
R.metabolics.Bhargava2004.COT = E_sum_GC/R.misc.body_mass/R.spatiotemp.dist_trav;

%% ...
% Please add other energy models below. 
% Add the different terms to the struct with results R under the field
% "R.metabolics.(metabolic_model_name).(term_name)"

%% Umberger et al. (2010)
elseif strcmp(R.S.metabolicE.model,'Umberger2010')

    R.metabolics.Umberger2010.Edot_gait = zeros(N,NMuscle);
    R.metabolics.Umberger2010.Adot = zeros(N,NMuscle);
    R.metabolics.Umberger2010.Wdot = zeros(N,NMuscle);
    R.metabolics.Umberger2010.Sdot = zeros(N,NMuscle);
    R.metabolics.Umberger2010.Edot_incl_basal = zeros(N,1);

    for i=1:N
        [Edot_tot_i,Adot_i,Sdot_i,Wdot_i,Edot_b_i] = f_casadi.getMetabolicEnergySmooth2010all(...
                R.muscles.a(i,:)',R.muscles.a(i,:)',R.muscles.lMtilde(i,:)',R.muscles.vM(i,:)',...
                R.muscles.Fce(i,:)',MuscleMass',pctsts,R.muscles.Fiso(i,:)',...
                R.misc.body_mass,R.S.metabolicE.tanh_b);
    
        R.metabolics.Umberger2010.Edot_gait(i,:) = full(Edot_tot_i)';
        R.metabolics.Umberger2010.Adot(i,:) = full(Adot_i)';
        R.metabolics.Umberger2010.Wdot(i,:) = full(Wdot_i)';
        R.metabolics.Umberger2010.Sdot(i,:) = full(Sdot_i)';
        R.metabolics.Umberger2010.Edot_incl_basal(i) = full(Edot_b_i)';
    
    end

    % cost of transport
    E_sum_GC = trapz(R.time.mesh_GC(1:end-1),R.metabolics.Umberger2010.Edot_incl_basal);
    R.metabolics.Umberger2010.COT = E_sum_GC/R.misc.body_mass/R.spatiotemp.dist_trav;

%% Uchida et al. (2016)
else

    R.metabolics.Uchida2016.Edot_gait = zeros(N,NMuscle);
    R.metabolics.Uchida2016.Adot = zeros(N,NMuscle);
    R.metabolics.Uchida2016.Wdot = zeros(N,NMuscle);
    R.metabolics.Uchida2016.Sdot = zeros(N,NMuscle);
    R.metabolics.Uchida2016.Edot_incl_basal = zeros(N,1);

    for i=1:N
        [Edot_tot_i,Adot_i,Sdot_i,Wdot_i,Edot_b_i] = f_casadi.getMetabolicEnergySmooth2016all(...
                R.muscles.a(i,:)',R.muscles.a(i,:)',R.muscles.lMtilde(i,:)',R.muscles.vM(i,:)',...
                R.muscles.Fce(i,:)',MuscleMass',pctsts,R.muscles.Fiso(i,:)',...
                R.misc.body_mass,R.S.metabolicE.tanh_b);
    
        R.metabolics.Uchida2016.Edot_gait(i,:) = full(Edot_tot_i)';
        R.metabolics.Uchida2016.Adot(i,:) = full(Adot_i)';
        R.metabolics.Uchida2016.Wdot(i,:) = full(Wdot_i)';
        R.metabolics.Uchida2016.Sdot(i,:) = full(Sdot_i)';
        R.metabolics.Uchida2016.Edot_incl_basal(i) = full(Edot_b_i)';
    
    end
    
    % cost of transport
    E_sum_GC = trapz(R.time.mesh_GC(1:end-1),R.metabolics.Uchida2016.Edot_incl_basal);
    R.metabolics.Uchida2016.COT = E_sum_GC/R.misc.body_mass/R.spatiotemp.dist_trav;
end


