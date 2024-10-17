
%% Predictive Simulations of Human Gait

% variables muscle weakness/assistive torque/optimal fiber length/
% /walking speed/

function [] = predictiveSimulation(assistance_input)

    for ww = 0.1
    
        
            % This script starts the predictive simulation of human movement. The
            % required inputs are necessary to start the simulations. Optional inputs,
            % if left empty, will be taken from getDefaultSettings.m.
        
            cd ('C:\Users\lingh\OneDrive - KTH\ExMaterials\7-Doctor\Research\2-simulation')
        
            % path to the repository folder
            [pathRepo,~,~] = fileparts(mfilename('fullpath'));
            % path to the folder that contains the repository folder
            [pathRepoFolder,~,~] = fileparts(pathRepo);
            
            %% Initialize user-defined settings structure S
            pathDefaultSettings = fullfile(pathRepo,'DefaultSettings');
            addpath(pathDefaultSettings)
            
            [S] = initializeSettings('DHondt_2023_3seg');
            S.misc.main_path = pathRepo;
            
            addpath(fullfile(S.misc.main_path,'VariousFunctions'))
            
            %% Required inputs
            % name of the subject
            S.subject.name = 'DHondt_2023_3seg';
            
            my_abductor_strength = ww;
            
            % Exoskeleton simulation
            S.Exo.Hip.available = true;    %% true if assistance is offered
            S.Exo.Hip.type = [''];
        
            if S.Exo.Hip.available
                S.Exo.Hip.assist.parameter = assistance_input;
                S.Exo.Hip.assist.label = {'T1', 'Fmax', 'T2', 'T3'};

                formatted_numbers = cell(1, length(assistance_input));
                % Loop through each number, convert to string, replace '.' with '_'
                for i = 1:length(assistance_input)
                    formatted_numbers{i} = strrep(sprintf('%.1f', assistance_input(i)), '.', '_');
                end
                S.Exo.Hip.assist.string = strjoin(formatted_numbers, '__');

                S.Exo.Hip.type = ['bilevel']
        
                S.Exo.Hip.TorLeft = zeros(1,50);S.Exo.Hip.TorRight=zeros(1,50);
                [S.Exo.Hip.TorLeft,S.Exo.Hip.TorRight] = Torque_pattern_T(assistance_input,0);
                S.Exo.Hip.TorBack = (S.Exo.Hip.TorLeft - S.Exo.Hip.TorRight)*3/13;

            end
        
            % % path to folder where you want to store the results of the OCP
            S.subject.save_folder  = fullfile(pathRepo,'PredSimResults',[S.subject.name '_' num2str(my_abductor_strength) 'strength' S.Exo.Hip.type]); 
            if S.Exo.Hip.available
                S.subject.save_folder = fullfile(S.subject.save_folder, [ S.Exo.Hip.assist.string 'hipAssistance'] );
            end
            
            
            % % either choose "quasi-random" or give the path to a .mot file you want to use as initial guess
        %     S.subject.IG_selection = 'quasi-random';
            S.subject.IG_selection = fullfile(S.misc.main_path,'PredSimResults\DHondt_2023_3seg_1strength','DHondt_2023_3seg_v1.mot');               %% intial guess 
            S.subject.IG_selection_gaitCyclePercent = 200;
            
            % % give the path to the osim model of your subject
            osim_path = fullfile(pathRepo,'Subjects',S.subject.name,[S.subject.name '.osim']);
            
            % % Do you want to run the simulation as a batch job (parallel computing toolbox)
            S.solver.run_as_batch_job = 0;
            
            %% Optional inputs
            % see README.md in the main folder for information about these optional
            % inputs.
            
            % % S.bounds
            % S.bounds.a.lower            = ;
            % S.bounds.SLL.upper          = ;
            % S.bounds.SLR.upper          = ;
            % S.bounds.dist_trav.lower    = ;
            % S.bounds.t_final.upper      = ;
            % S.bounds.t_final.lower      = ;
            % S.bounds.Qs                 = {'pelvis_tilt',-30,30,'pelvis_list',-30,30};
            
            
            % S.metabolicE - metabolic energy
            % S.metabolicE.tanh_b = 100;
            S.metabolicE.model = 'Bhargava2004';
        %    S.metabolicE.model = 'Umberger2010';
        %      S.metabolicE.model = 'Uchida2016';
            
            % % S.misc - miscellanious
            % S.misc.v_max_s             = ;
            % S.misc.visualize_bounds    = 1;
            % S.misc.gaitmotion_type     = '';
            % S.misc.msk_geom_eq         = '';
            % S.misc.poly_order.lower    = ;
            % S.misc.poly_order.upper    = ;
            % S.misc.msk_geom_bounds      = {{'knee_angle_r'},0,90,{'mtp_angle_'},-50,20};
            % S.misc.default_msk_geom_bound = ;
            % S.misc.msk_geom_bounds      = {{'knee_angle_r','knee_angle_l'},-120,10,'lumbar_extension',nan,30};
        %     S.misc.gaitmotion_type = 'FullGaitCycle';
            S.misc.gaitmotion_type = 'HalfGaitCycle';                                               %% reduce compute time and results are symmetric
            
            % % S.post_process
            S.post_process.make_plot = 0;
            % S.post_process.savename  = 'datetime';
            % S.post_process.load_prev_opti_vars = 1;
            % S.post_process.rerun   = 1;
            % S.post_process.result_filename = '';
            
            % % S.solver
            % S.solver.linear_solver  = '';
            S.solver.tol_ipopt      = 4;
            % S.solver.max_iter       = 5;
            S.solver.parallel_mode  = 'thread';
            S.solver.N_threads      = 4;
            S.solver.N_meshes       = 50;                                                       %% so that the full gait cycle has 100 points
            % S.solver.par_cluster_name = ;
            S.solver.CasADi_path    = 'C:\Users\lingh\Documents\Matlab\casadi-windows-matlabR2016a-v3.5.5';
            
            
            % % S.subject
            % S.subject.mass              = ;
            % S.subject.IG_pelvis_y       = ; 
            S.subject.adapt_IG_pelvis_y = 1;
            S.subject.v_pelvis_x_trgt   = 1.33;                                                 %% walking speed  1.33 
            S.subject.muscle_strength   =  {
                 {
                 'glut_med1_r', 'glut_med1_l',  ...
                 'glut_med2_r', 'glut_med2_l', 'glut_med3_r', 'glut_med3_l',  ...
                 'glut_min1_r', 'glut_min1_l', 'glut_min2_r', 'glut_min2_l',  ...
                 'glut_min3_r', 'glut_min3_l',...
                 }, ...
                 my_abductor_strength};
        
            % S.subject.muscle_pass_stiff_shift = {{'soleus','_gas','per_','tib_','_dig_','_hal_','FDB'},0.9}; %,'FDB'
            % S.subject.muscle_pass_stiff_scale = ;
            % S.subject.tendon_stiff_scale      = {{'soleus','_gas'},0.5};
            % S.subject.scale_MT_params = {{'soleus_l'},'FMo',0.9,{'soleus_l'},'alphao',1.1};
            % increase passive force
        %     S.subject.scale_MT_params = {   {'glut_med1_r'},'lMo',2.0,{'glut_med2_r'},'lMo',2.0,{'glut_med3_r'},'lMo',2.0,...
        %                                     {'glut_min1_r'},'lMo',2.0,{'glut_min2_r'},'lMo',2.0,{'glut_min3_r'},'lMo',2.0,...
        %                                     {'glut_med1_l'},'lMo',2.0,{'glut_med2_l'},'lMo',2.0,{'glut_med3_l'},'lMo',2.0,...
        %                                     {'glut_min1_l'},'lMo',2.0,{'glut_min2_l'},'lMo',2.0,{'glut_min3_l'},'lMo',2.0,...
        %                                     };
            % S.subject.spasticity        = ;
            % S.subject.muscle_coordination = ;
            % S.subject.set_stiffness_coefficient_selected_dofs = {{'mtp_angle_l','mtp_angle_r'},25};
            % S.subject.set_damping_coefficient_selected_dofs = {{'mtp_angle_l','mtp_angle_r'},2};
            % S.subject.set_limit_torque_coefficients_selected_dofs = ...
            %     {{'knee_angle_r','knee_angle_l'},-[11.03 -11.33 -6.09 33.94]',-[0.13 -2.4]',...
            %     {'mtp_angle_r','mtp_angle_l'},-[0.18 -70.08 -0.9 14.87]',-[65/180*pi 0]'};
            % S.subject.base_joints_legs = 'hip';
            % S.subject.base_joints_arms = [];
            % S.subject.mtp_type          = '2022paper';
            
            % % S.weights
            % S.weights.E         = 0;
            % S.weights.E_exp     = ;
            % S.weights.q_dotdot  = 0;
            % S.weights.e_arm     = 10;
            % S.weights.pass_torq = 1;
            % S.weights.a         = 10*18;
            % S.weights.slack_ctrl = ;
            % S.weights.pass_torq_includes_damping = ;
            
            % %S.OpenSimADOptions: required inputs to convert .osim to .dll
            % S.OpenSimADOptions.compiler = 'Visual Studio 17 2022';
            S.OpenSimADOptions.verbose_mode = 1;    % 0 for no outputs from cmake
            
        
            % set constraints on step width  
        %     S.bounds.distanceConstraints(1).point1 = 'calcn_r';
        %     S.bounds.distanceConstraints(1).point2 = 'calcn_l';
        %     S.bounds.distanceConstraints(1).direction = 'z';
        %     S.bounds.distanceConstraints(1).lower_bound = 0.095;
        %     S.bounds.distanceConstraints(1).upper_bound = 0.110;
             
            %% Run predictive simulations
            
            % warning wrt pelvis heigt for IG
            if S.subject.adapt_IG_pelvis_y == 0 && S.subject.IG_selection ~= "quasi-random"
                uiwait(msgbox(["Pelvis height of the IG will not be changed.";"Set S.subject.adapt_IG_pelvis_y to 1 if you want to use the model's pelvis height."],"Warning","warn"));
            end
               
            % Start simulation
            if S.solver.run_as_batch_job
                add_pred_sim_to_batch(S,osim_path)
            else
                [savename] = run_pred_sim(S,osim_path);
            end
            
            %% Plot results
            if S.post_process.make_plot && ~S.solver.run_as_batch_job
                % set path to saved result
                result_paths{2} = fullfile(S.subject.save_folder,[savename '.mat']);
                % add path to subfolder with plotting functions
                addpath(fullfile(S.misc.main_path,'PlotFigures'))
                % call plotting script
                run_this_file_to_plot_figures
            end
        
    end

end


% Function: Torque_pattern_T
% 
% Purpose:
% This function generates left and right hip torque patterns based on 
% user-defined gait phases and peak torque. The function interpolates 
% the torque values for a given gait cycle and creates torque profiles 
% for the left and right legs, typically for use in an exoskeleton 
% assistance system.
%
% Inputs:
%   assistance_input - A vector containing four elements:
%                      assistance_input(1) - int. Gait phase 1 (T1), the start of the assistance (0-100% gait cycle)
%                      assistance_input(2) - float. Peak torque (Fmax), the maximum torque to apply
%                      assistance_input(3) - int. Gait phase 2 (T2), the phase where the peak torque is maintained
%                      assistance_input(4) - int. Gait phase 3 (T3), the phase where the torque  decline to zero
%   fullgaitcycle    - A binary flag (1 or 0):
%                      If 1, the function will return torque patterns over a full gait cycle (0-100%)
%                      If 0, the function will return torque patterns for only half of the gait cycle (0-50%)
%
% Outputs:
%   TorLeft  - A vector containing the interpolated torque profile for the left leg
%   TorRight - A vector containing the interpolated torque profile for the right leg
%
% Methodology:
% - The function starts by extracting the gait phase times (T1, T2, T3) and peak torque (Fmax) from the 
%   input vector.
% - It then defines the torque profile points with zero torque at the start and end, and the peak torque 
%   maintained between T1 and T2.
% - Linear interpolation (`interp1`) is used to generate torque values over the entire gait phase.
% - The function ensures the torque is aligned to a 100-point gait cycle by adding zeros for the phases 
%   outside the defined times.
% - The torque profile is then adjusted for left and right legs, where the left leg torque is shifted by 
%   half a gait cycle.
% - Depending on the `fullgaitcycle` flag, the function either returns a torque profile for the full gait 
%   cycle (0-100%) or for half a gait cycle (0-50%).
%
% Usage Example:
%   [TorLeft, TorRight] = Torque_pattern_T([20, 50, 60, 80], 1);
%   This will generate the left and right torque patterns for a full gait cycle based on the input parameters.
%
% Notes:
% - The function assumes a 100-point gait cycle, where each point corresponds to 1% of the cycle.
% - The torque profile is symmetric between the left and right legs, but the left leg's profile is shifted 
%   by 50% of the gait cycle to account for typical human walking patterns (where the right leg leads).

function [TorLeft, TorRight] = Torque_pattern_T(assistance_input, fullgaitcycle)
    % T is int type, Fmax is float type
    % S.Exo.Hip.assist.label = {'T1', 'Fmax', 'T2', 'T3'};
    gaitPhase_1 = assistance_input(1);
    peakTor = assistance_input(2);
    gaitPhase_2 = assistance_input(3);
    gaitPhase_3 = assistance_input(4);
    
    % 输入数据点
    gaitPhase = [0, gaitPhase_1, gaitPhase_2, gaitPhase_3];
    tor = [0, peakTor, peakTor, 0];


    GaitPhase = linspace(min(gaitPhase), max(gaitPhase), max(gaitPhase)-min(gaitPhase)+1);
    Tor = interp1(gaitPhase, tor, GaitPhase, 'linear');
    
    GaitPhase = 1:100;
    Tor = [zeros(1,(min(gaitPhase)-1)) Tor zeros(1, 100-(max(gaitPhase)))];

    TorLeft = [Tor(51:end) Tor(1:50)];      % right leg is first in exp
    TorRight = Tor;
    
    
    if fullgaitcycle == 1
        pass
    else
        TorLeft = TorLeft(1:50);
        TorRight = TorRight(1:50);
    end
end