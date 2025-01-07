

% Set a fixed random seed for reproducibility
Random_Seed = 76;
rng(Random_Seed);  % Choose any fixed seed value

% Start a parallel pool if not already active
if isempty(gcp('nocreate'))
    % Create a parallel pool with a specified number of workers
    numWorkers = 4; % Specify the number of workers you want
    parpool(numWorkers); % Create a parallel pool with 4 workers
end

global savedfilename 

pathRepo = 'C:\Users\lingh\OneDrive - KTH\MyFile\7-Doctor\Research\2-simulation';
results_folder = fullfile(pathRepo, 'PredSimResults\DHondt_2023_3seg_normalbilevel');
% Open a log file to save output
logFile = fullfile(results_folder, 'bo_rmse.txt');
savedfilename = fullfile(results_folder, 'bo_rmse.mat');
define_NumSeedPoints = 50;
define_MaxObjectiveEvaluations = 200;

diary(logFile);  % Start logging to the file

fprintf('Starting Bayesian Optimization Log\n');
fprintf('-----------------------------------\n');
fprintf('Random Seed: %d\n', Random_Seed);
fprintf('Number of Workers in Parallel Pool: %d\n', numWorkers);
fprintf('Results Folder: %s\n', results_folder);
fprintf('Optimization Variables:\n');
fprintf(' - w1: Real, range [0, 1]\n');
fprintf(' - w2: Real, range [0, 1]\n');
fprintf(' - w3: Real, range [0, 1]\n');
fprintf(' - w4: Real, range [0, 1]\n');
fprintf('Seed Points: %d\n', define_NumSeedPoints);
fprintf('Max Objective Evaluations: %d\n', define_MaxObjectiveEvaluations);
fprintf('\n');


% Define optimization variables
vars = [
    optimizableVariable('w1', [0, 1], 'Type', 'real');
    optimizableVariable('w2', [0, 1], 'Type', 'real');
    optimizableVariable('w3', [0, 1], 'Type', 'real');
    optimizableVariable('w4', [0, 1], 'Type', 'real')
];



% Check if a saved progress file exists
if isfile(savedfilename)
    % Load saved results
    load(savedfilename, 'results');
    fprintf('Resuming optimization from saved state...\n');

    figure()
    plot(results.ObjectiveTrace, '-*','DisplayName','previous iteration')
    hold on

    % Continue with bayesopt using the saved state as the starting point
    % Resume the optimization from the saved results state
    results = bayesopt(@Simulation, vars, ...
        'InitialX', results.XTrace, ...      % Use points already evaluated
        'InitialObjective', results.ObjectiveTrace, ... % Use corresponding objectives
        'UseParallel', true, ...     % Enable parallel evaluation
        'NumSeedPoints',define_NumSeedPoints,...
        'XConstraintFcn', @xconstraint,...
        'ParallelMethod','clipped-model-prediction',...
        'AcquisitionFunctionName', 'expected-improvement-plus', ...
        'ExplorationRatio', 0.5, ...
        'MaxObjectiveEvaluations', define_MaxObjectiveEvaluations, ...
        'IsObjectiveDeterministic', true, ...
        'Verbose',1, ...
        'OutputFcn', @saveProgress);
else
    % No saved file, start from scratch
    fprintf('No saved state found, starting new optimization...\n');
    results = bayesopt(@Simulation, vars, ...
        'UseParallel', true, ...     % Enable parallel evaluation
        'NumSeedPoints',define_NumSeedPoints,...
        'XConstraintFcn', @xconstraint,...
        'ParallelMethod','clipped-model-prediction',...
        'AcquisitionFunctionName', 'expected-improvement-plus', ...
        'ExplorationRatio', 0.5, ...
        'MaxObjectiveEvaluations', define_MaxObjectiveEvaluations, ...
        'IsObjectiveDeterministic', true, ...
        'Verbose',1, ...
        'OutputFcn', @saveProgress);
end


% Display the best solution found
figure()
plot(results.ObjectiveTrace, '-*', 'DisplayName','current iteration')
legend show

bestX = results.XAtMinObjective;
bestObjective = results.MinObjective;
disp(['Best w1: ', num2str(bestX.w1)]);
disp(['Best w2: ', num2str(bestX.w2)]);
disp(['Best w3: ', num2str(bestX.w3)]);
disp(['Best w4: ', num2str(bestX.w4)]);
disp(['Best Objective Value: ', num2str(bestObjective)]);


diary off; % Stops logging to the file
% delete(gcp('nocreate'))



% Define a sample objective function
function objective = Simulation(w)

    % Check for input conditions
%     if w.T2 <= w.T1 || w.T3 <= w.T2
%         objective = 20;
%         return;
%     end
%     objective = 1;
%     return 

    % Generate result folder path
%     w.w1=0.1;w.w2=0.2;w.w3=0.2;w.w4=0.1;
    w5 = 1- sum([w.w1, w.w2, w.w3, w.w4]);
    weights = [w.w1, w.w2, w.w3, w.w4 w5];
    formatted_numbers = cell(1, length(weights));
    % Loop through each number, convert to string, replace '.' with '_'
    for i = 1:length(weights)
        formatted_numbers{i} = strrep(sprintf('%.3f', weights(i)), '.', '_');
    end
    File.string = strjoin(formatted_numbers, '__');

    File.folder = [ File.string 'weight'];


    folder_path_1 = 'C:\Users\lingh\OneDrive - KTH\MyFile\7-Doctor\Research\2-simulation\PredSimResults';
    folder_path_2 = 'DHondt_2023_3seg_normalbilevel';
    folder_path_3 = 'DHondt_2023_3seg_v1.mat';
    File.path = fullfile(folder_path_1, folder_path_2, File.folder, folder_path_3);

    % Check if the result mat file exists or not
    if exist(File.path, 'file')
        disp('File exists.');
    else
        disp('File does not exist. run MATLAB code to generate it');
        func_predictiveSimulation_weight(weights);
    end

    % Get ROM of kinematics
    ROM = xlhobj_func(File.path, "DHondt_4seg_rmse");
    objective = ROM;
end


% contrants on feasbile region
function tf = xconstraint(w)
    % Check for input conditions
    tf =  w.w1+w.w2+w.w3+w.w4 < 1;
end

% Define the callback function for saving progress
% Specify filename for saving
function stop = saveProgress(results, state)
    global savedfilename;
%     if strcmp(state, 'iteration')
        % Save results at each iteration
        save(savedfilename, 'results');
%     end
    stop = false; % Continue optimization
end


