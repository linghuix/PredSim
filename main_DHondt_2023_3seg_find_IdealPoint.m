

%% Predictive Simulations of Human Gait

function [] = main_DHondt_2023_3seg_find_IdealPoint()
    % variables 
    
    % 1.weakness / 2.energy model / 3.initial guess / 4.assistance parameters 
    % / 5.walking speed / 6.folderName / 7.adapt_IG_pelvis_y / 8.weight (E, q_dotdot, e_arm, pass_torq, a, slack) 
    % / 9.S.solver.tol_ipopt
    Setting = { {1.0, 'Bhargava2004', {1},  {false}, 1.33, 'IdealPoint\e_arm', 0, {0, 0, 1, 0, 0, 0.000001}, 4},...                                                                     %1  min e_arm
                {1.0, 'Bhargava2004', {2, 'OCP\IK_Guess_Full_GC.mot'}, {false}, 1.33, 'IdealPoint\e_arm', 1, {0, 0, 1, 0, 0, 0.000001}, 4},...                                          %2  min e_arm
                {1.0, 'Bhargava2004', {2, 'PredSimResults\DHondt_2023_3seg_1strength\DHondt_2023_3seg_v2.mot'}, {false}, 1.33, 'IdealPoint\e_arm', 1, {0, 0, 1, 0, 0, 0.000001}, 4},... %3 Optimal Solution at the closest level of strength
                {1.0, 'Bhargava2004', {1},  {false}, 1.33, 'IdealPoint\e_arm', 0, {0, 0, 1, 0, 0, 0.000001}, 5},...                                                                     %4  min e_arm
                {1.0, 'Bhargava2004', {2, 'OCP\IK_Guess_Full_GC.mot'}, {false}, 1.33, 'IdealPoint\e_arm', 1, {0, 0, 1, 0, 0, 0.000001}, 5},...                                          %5  min e_arm
                {1.0, 'Bhargava2004', {2, 'PredSimResults\DHondt_2023_3seg_1strength\DHondt_2023_3seg_v2.mot'}, {false}, 1.33, 'IdealPoint\e_arm', 1, {0, 0, 1, 0, 0, 0.000001}, 5},... %6 Optimal Solution at the closest level of strength
                {1.0, 'Bhargava2004', {1},  {false}, 1.33, 'IdealPoint\e_arm', 0, {0, 0, 1, 0, 0, 0.000001}, 7},...                                                                     %7  min e_arm
                {1.0, 'Bhargava2004', {2, 'OCP\IK_Guess_Full_GC.mot'}, {false}, 1.33, 'IdealPoint\e_arm', 1, {0, 0, 1, 0, 0, 0.000001}, 7},...                                          %8  min e_arm
                {1.0, 'Bhargava2004', {2, 'PredSimResults\DHondt_2023_3seg_1strength\DHondt_2023_3seg_v2.mot'}, {false}, 1.33, 'IdealPoint\e_arm', 1, {0, 0, 1, 0, 0, 0.000001}, 7},... %9 Optimal Solution at the closest level of strength
                {1.0, 'Bhargava2004', {1},  {false}, 1.33, 'IdealPoint\e_arm', 0, {0, 0, 1, 0, 0, 0.000001}, 8},...                                                                     %10  min e_arm
                {1.0, 'Bhargava2004', {2, 'OCP\IK_Guess_Full_GC.mot'}, {false}, 1.33, 'IdealPoint\e_arm', 1, {0, 0, 1, 0, 0, 0.000001}, 8},...                                          %11  min e_arm
                {1.0, 'Bhargava2004', {2, 'PredSimResults\DHondt_2023_3seg_1strength\DHondt_2023_3seg_v2.mot'}, {false}, 1.33, 'IdealPoint\e_arm', 1, {0, 0, 1, 0, 0, 0.000001}, 8},... %12 Optimal Solution at the closest level of strength
                {1.0, 'Bhargava2004', {1},  {false}, 1.33, 'IdealPoint\E', 0, {1, 0, 0, 0, 0, 0.000001}, 7},...                                                                         %13  min E
                {1.0, 'Bhargava2004', {2, 'OCP\IK_Guess_Full_GC.mot'}, {false}, 1.33, 'IdealPoint\E', 1, {1, 0, 0, 0, 0, 0.000001}, 7},...                                              %14  min E
                {1.0, 'Bhargava2004', {2, 'PredSimResults\DHondt_2023_3seg_1strength\DHondt_2023_3seg_v2.mot'}, {false}, 1.33, 'IdealPoint\E', 1, {1, 0, 0, 0, 0, 0.000001}, 7},...     %15 Optimal Solution at the closest level of strength
                {1.0, 'Bhargava2004', {1},  {false}, 1.33, 'IdealPoint\E', 0, {1, 0, 0.001, 0, 0, 0.000001}, 7},...                                                                     %16  min E
                {1.0, 'Bhargava2004', {2, 'OCP\IK_Guess_Full_GC.mot'}, {false}, 1.33, 'IdealPoint\E', 1, {1, 0, 0.001, 0, 0, 0.000001}, 7},...                                          %17  min E
                {1.0, 'Bhargava2004', {2, 'PredSimResults\DHondt_2023_3seg_1strength\DHondt_2023_3seg_v2.mot'}, {false}, 1.33, 'IdealPoint\E', 1, {1, 0, 0.001, 0, 0, 0.000001}, 7},... %18 Optimal Solution at the closest level of strength
                {1.0, 'Bhargava2004', {1},  {false}, 1.33, 'IdealPoint\q_dotdot', 0, {0, 1, 0.00, 0, 0, 0.000001}, 7},...                                                              %19  min q_dotdot
                {1.0, 'Bhargava2004', {2, 'OCP\IK_Guess_Full_GC.mot'}, {false}, 1.33, 'IdealPoint\q_dotdot', 1, {0, 1, 0.00, 0, 0, 0.000001}, 7},...                                   %20  min q_dotdot
                {1.0, 'Bhargava2004', {2, 'PredSimResults\DHondt_2023_3seg_1strength\DHondt_2023_3seg_v2.mot'}, {false}, 1.33, 'IdealPoint\q_dotdot', 1, {0, 1, 0.00, 0, 0, 0.000001}, 7},... %21 OS min q_dotdot
                {1.0, 'Bhargava2004', {1},  {false}, 1.33, 'IdealPoint\pass_torq', 0, {0, 0, 0.00, 1, 0, 0.000001}, 7},...                                                             %22  min pass_torq
                {1.0, 'Bhargava2004', {2, 'OCP\IK_Guess_Full_GC.mot'}, {false}, 1.33, 'IdealPoint\pass_torq', 1, {0, 0, 0.00, 1, 0, 0.000001}, 7},...                                  %23  min pass_torq
                {1.0, 'Bhargava2004', {2, 'PredSimResults\DHondt_2023_3seg_1strength\DHondt_2023_3seg_v2.mot'}, {false}, 1.33, 'IdealPoint\pass_torq', 1, {0, 0, 0.00, 1, 0, 0.000001}, 7},... %24 OS min pass_torq
                {1.0, 'Bhargava2004', {1},  {false}, 1.33, 'IdealPoint\a', 0, {0, 0, 0.00, 0, 1, 0.000001}, 7},...                                                                     %25  min a
                {1.0, 'Bhargava2004', {2, 'OCP\IK_Guess_Full_GC.mot'}, {false}, 1.33, 'IdealPoint\a', 1, {0, 0, 0.00, 0, 1, 0.000001}, 7},...                                          %26  min a
                {1.0, 'Bhargava2004', {2, 'PredSimResults\DHondt_2023_3seg_1strength\DHondt_2023_3seg_v2.mot'}, {false}, 1.33, 'IdealPoint\a', 1, {0, 0, 0.00, 0, 1, 0.000001}, 7},... %27 OS min a

    };
    
    for index = 19:27
        % This script starts the predictive simulation of human movement. The
        % required inputs are necessary to start the simulations. Optional inputs,
        % if left empty, will be taken from getDefaultSettings.m.
     
    
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
        
        my_abductor_strength = Setting{index}{1};
        
        % Exoskeleton simulation
        S.Exo.Hip.available = Setting{index}{4}{1};    %% true if assistance is offered
        S.Exo.Hip.type = [];
    
        % % path to folder where you want to store the results of the OCP
        S.subject.save_folder  = fullfile(pathRepo,'PredSimResults', Setting{index}{6}, [S.subject.name '_' num2str(my_abductor_strength) 'strength' S.Exo.Hip.type]); 
        if S.Exo.Hip.available
            S.subject.save_folder = fullfile(S.subject.save_folder, ['_' num2str(S.Exo.Hip.maxTor) 'hipAssistance'] );
        end
        
        
        % % either choose "quasi-random" or give the path to a .mot file you want to use as initial guess
    
        switch(Setting{index}{3}{1})
        % Quasi-random
            case 1 
                S.subject.IG_selection = 'quasi-random';
        % Data-informed from Falisse’s model[1]
            case 2
                S.subject.IG_selection = fullfile(S.misc.main_path, Setting{index}{3}{2}); 
                S.subject.IG_selection_gaitCyclePercent = 100;
        % Sub Optmial solution at closest level of strength 
            case 3
                
                while true
                    filePaths = getFilePaths(Setting{index}{3}{2}, '*.mat');
                    % Check if the number of files is equal to the target count
                    if numel(filePaths) == 4
                        disp('Found the target number of files.');
                        break; % Exit the loop if the condition is met
                    else
                        disp(['Current file count: ', num2str(numel(filePaths)), '. Waiting for 10 minutes...']);
                        pause(600); % Wait for 5 minute before checking again
                    end
                end

                obejctiveValue = zeros(1,4);
                % Loop over each file path and load the .mat file
                for i = 1:length(filePaths)
                    filePath = filePaths{i}; % Get the current file path
                    data = load(filePath);   % Load the .mat file
                    disp(['Loaded file: ', filePath]);
                    obejctiveValue(i) = sum(data.R.objective.absoluteValues);
                    disp(['Objective value is: ', num2str(obejctiveValue(i))]);
                end
                [idx1_lowest, idx2] = findTwoLowestWithDifferenceOrRandom(obejctiveValue, 2);
                
                % 使用 regexprep 更改文件后缀
                newFilePath = regexprep(filePaths{idx2}, '\.mat$', '.mot');
                disp(['Loaded file For inital Guess: ', newFilePath]);
                S.subject.IG_selection = fullfile(S.misc.main_path, newFilePath); 
                S.subject.IG_selection_gaitCyclePercent = 100;
        % Optmial Solution at closest level of strength
            case 4
                
                while true
                    filePaths = getFilePaths(Setting{index}{3}{2}, '*.mat');

                    % Check if the number of files is equal to the target count
                    if numel(filePaths) == 4
                        disp('Found the target number of files.');
                        break; % Exit the loop if the condition is met
                    else
                        disp(['Current file count: ', num2str(numel(filePaths)), '. Waiting for 10 minutes...']);
                        pause(300); % Wait for 5 minute before checking again
                    end
                end

                obejctiveValue = zeros(1,4);
                % Loop over each file path and load the .mat file
                for i = 1:length(filePaths)
                    filePath = filePaths{i}; % Get the current file path
                    data = load(filePath);   % Load the .mat file
                    disp(['Loaded file: ', filePath]);
                    obejctiveValue(i) = sum(data.R.objective.absoluteValues);
                    disp(['Objective value is: ', num2str(obejctiveValue(i))]);
                end
                [idx1_lowest, idx2] = findTwoLowestWithDifferenceOrRandom(obejctiveValue, 2);

                % 使用 regexprep 更改文件后缀
                newFilePath = regexprep(filePaths{idx1_lowest}, '\.mat$', '.mot');
                disp(['Loaded file For inital Guess: ', newFilePath]);
                S.subject.IG_selection = fullfile(S.misc.main_path, newFilePath); 
                S.subject.IG_selection_gaitCyclePercent = 100;
        end
    
        
        % % give the path to the osim model of your subject
        osim_path = fullfile(pathRepo,'Subjects',S.subject.name,[S.subject.name '.osim']);
        
        % % Do you want to run the simulation as a batch job (parallel computing toolbox)
        S.solver.run_as_batch_job = 1;
        
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
    %     S.metabolicE.model = 'Bhargava2004';
    %    S.metabolicE.model = 'Umberger2010';
    %      S.metabolicE.model = 'Uchida2016';
        S.metabolicE.model = Setting{index}{2};
        
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
        S.misc.gaitmotion_type = 'HalfGaitCycle';     %% reduce compute time and results are symmetric
        
        % % S.post_process
        S.post_process.make_plot = 0;
        % S.post_process.savename  = 'datetime';
        % S.post_process.load_prev_opti_vars = 1;
        % S.post_process.rerun   = 1;
        % S.post_process.result_filename = '';
        
        % % S.solver
        % S.solver.linear_solver  = '';
        S.solver.tol_ipopt      = Setting{index}{9};
        % S.solver.max_iter       = 5;
        S.solver.parallel_mode  = 'thread';
        S.solver.N_threads      = 16;
        S.solver.N_meshes       = 50;                                                       %% so that the full gait cycle has 100 points
        % S.solver.par_cluster_name = ;
        S.solver.CasADi_path    = 'C:\Users\lingh\Documents\Matlab\casadi-windows-matlabR2016a-v3.5.5';
        
        
        % % S.subject
        % S.subject.mass              = ;
        % S.subject.IG_pelvis_y       = ; 
        S.subject.adapt_IG_pelvis_y = Setting{index}{7};
        S.subject.v_pelvis_x_trgt   = Setting{index}{5};                                    %% experimental walking speed  1.33 
    
        if my_abductor_strength < 1 
            S.subject.muscle_strength   =  {
                 {
                 'glut_med1_r', 'glut_med1_l',  ...
                 'glut_med2_r', 'glut_med2_l', 'glut_med3_r', 'glut_med3_l',  ...
                 'glut_min1_r', 'glut_min1_l', 'glut_min2_r', 'glut_min2_l',  ...
                 'glut_min3_r', 'glut_min3_l',...
                 }, ...
                 my_abductor_strength};
        end
    
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
        
        % % S.weights   (E, q_dotdot, e_arm, pass_torq, a, slack)
        % S.weights.E         = 0;
        % S.weights.E_exp     = ;
        % S.weights.q_dotdot  = 0;
        % S.weights.e_arm     = 10;
        % S.weights.pass_torq = 1;
        % S.weights.a         = 10*18;
        % S.weights.slack_ctrl = ;
        % S.weights.pass_torq_includes_damping = ;
        S.weights.E             = Setting{index}{8}{1};
        S.weights.q_dotdot      = Setting{index}{8}{2};
        S.weights.e_arm         = Setting{index}{8}{3};
        S.weights.pass_torq     = Setting{index}{8}{4};
        S.weights.a             = Setting{index}{8}{5};
        S.weights.slack_ctrl    = Setting{index}{8}{6};
        
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
%% choose lowest optimal value one

% Here’s a MATLAB code snippet that searches a specified folder for files
% of a specific type and retrieves their paths. You can specify the folder
% path and the file type you want to search for.

% ### Usage
% 
% To use this function, call it by passing the folder path and file type:
% 
% ```matlab
% % Example usage: Get all .txt files in a specified folder
% folderPath = 'C:\your\folder\path';
% fileType = '*.txt';
% paths = getFilePaths(folderPath, fileType);
% 
% % Display the file paths
% disp(paths);
% ```
% 
% This code will return a cell array `paths` containing the full paths of
% all files matching the specified type in the given folder.


function filePaths = getFilePaths(folderPath, fileType)
    % folderPath: The folder where you want to search for files
    % fileType: The type of files to search for, e.g., '*.txt', '*.jpg', etc.

    % Get a list of all files of the specified type in the folder
    fileList = dir(fullfile(folderPath, fileType));
    
    % Preallocate a cell array to store file paths
    filePaths = cell(length(fileList), 1);

    % Loop through the files and store each path
    for k = 1:length(fileList)
        filePaths{k} = fullfile(folderPath, fileList(k).name);
    end
end



% Here’s the updated MATLAB function to select the second lowest index
% randomly if no such pair with the required difference is found:

% ### Usage
% 
% You can use this function the same way:
% 
% ```matlab
% % Example array
% numbers = [5, 3, 8, 1];
% 
% [idx1, idx2] = findTwoLowestWithDifferenceOrRandom(numbers);
% 
% % Display the indices
% disp(['Index of the lowest number: ', num2str(idx1)]);
% disp(['Index of the second lowest number: ', num2str(idx2)]);
% ```
% 
% In this version, if no second-lowest number meets the difference
% requirement, the function selects a random index from the remaining
% values, ensuring `idx2` is different from `idx1`.

function [idx1, idx2] = findTwoLowestWithDifferenceOrRandom(numbers, minDiff_two_lowest)
    % numbers: Array of four numbers
    % idx1: Index of the lowest number
    % idx2: Index of the second lowest number, either with a difference of at least 2
    %       or chosen randomly if no such difference is found

    % Sort the numbers in ascending order and get the original indices
    [sortedNumbers, originalIndices] = sort(numbers);

    % Find the lowest number and its index
    idx1 = originalIndices(1);
    lowestValue = sortedNumbers(1);

    % Loop to find the second lowest with the required difference
    for i = 2:length(sortedNumbers)
        if abs(sortedNumbers(i) - lowestValue) >= minDiff_two_lowest
            idx2 = originalIndices(i);
            return;
        end
    end

    % If no valid pair with the required difference, select a random index for idx2
    remainingIndices = originalIndices(2:end); % Indices excluding the lowest
    idx2 = remainingIndices(randi(length(remainingIndices))); % Random selection

    % Display a warning if no valid pair was found with a difference of at least minDiff_two_lowest
    warning('No valid pair found with a difference of at least 2. Second lowest chosen randomly.');
end


