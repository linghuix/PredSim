

% Set a fixed random seed for reproducibility
Random_Seed = 133;              % 78.0989   96.2554   59.7617   64.0274
rng(Random_Seed);  % Choose any fixed seed value

% Start a parallel pool if not already active
if isempty(gcp('nocreate'))
    % Create a parallel pool with a specified number of workers
    numWorkers = 4; % Specify the number of workers you want
    parpool(numWorkers); % Create a parallel pool with 4 workers
end

global savedfilename 

pathRepo = 'C:\Users\lingh\OneDrive - KTH\MyFile\7-Doctor\Research\2-simulation';
results_folder = fullfile(pathRepo, 'PredSimResults\DHondt_2023_3seg_0.1strengthbilevel');
% Open a log file to save output
logFile = fullfile(results_folder, 'bayesian_optimization_rmse_bilevel_trapezoid.txt');
savedfilename = fullfile(results_folder, 'bayesian_optimization_rmse_bilevel_trapezoid.mat');

define_NumSeedPoints = 50;
define_MaxObjectiveEvaluations = 200;

diary(logFile);  % Start logging to the file

fprintf('Starting Bayesian Optimization Log\n');
fprintf('-----------------------------------\n');
fprintf('Random Seed: %d\n', Random_Seed);
fprintf('Number of Workers in Parallel Pool: %d\n', numWorkers);
fprintf('Results Folder: %s\n', results_folder);
fprintf('Optimization Variables:\n');
fprintf(' - T1: Integer, range [0, 60]\n');
fprintf(' - Fmax: Real, range [1, 99]\n');
fprintf(' - T2: Integer, range [0, 60]\n');
fprintf(' - T3: Integer, range [0, 60]\n');
fprintf(' - T4: Integer, range [0, 60]\n');
fprintf('Seed Points: %d\n', define_NumSeedPoints);
fprintf('Max Objective Evaluations: %d\n', define_MaxObjectiveEvaluations);
fprintf('\n');


% Define optimization variables
vars = [
    optimizableVariable('T1', [0, 60], 'Type', 'integer');
    optimizableVariable('Fmax', [1, 99], 'Type', 'real');
    optimizableVariable('T2', [0, 60], 'Type', 'integer');
    optimizableVariable('T3', [0, 60], 'Type', 'integer');
    optimizableVariable('T4', [0, 60], 'Type', 'integer')
];



% Check if a saved progress file exists
if isfile(savedfilename)
    % Load saved results
    load(savedfilename, 'results');
    fprintf('Resuming optimization from saved state...\n');

    figure(1)
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
        'IsObjectiveDeterministic', false, ...
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
        'IsObjectiveDeterministic', false, ...
        'Verbose',1, ...
        'OutputFcn', @saveProgress);
end


% Display the best solution found
figure(1)
plot(results.ObjectiveTrace, '-*', 'DisplayName','current iteration')
legend show

bestX = results.XAtMinObjective;
bestObjective = results.MinObjective;
disp(['Best x: ', num2str(bestX.T1)]);
disp(['Best x: ', num2str(bestX.Fmax)]);
disp(['Best x: ', num2str(bestX.T2)]);
disp(['Best x: ', num2str(bestX.T3)]);
disp(['Best x: ', num2str(bestX.T4)]);
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
    assistance_input = [w.T1, w.Fmax, w.T2, w.T3 w.T4];
    formatted_numbers = cell(1, length(assistance_input));
    % Loop through each number, convert to string, replace '.' with '_'
    for i = 1:length(assistance_input)
        formatted_numbers{i} = strrep(sprintf('%.1f', assistance_input(i)), '.', '_');
    end
    File.string = strjoin(formatted_numbers, '__');

    File.folder = [ File.string 'hipAssistance'];

    folder_path_1 = 'C:\Users\lingh\OneDrive - KTH\MyFile\7-Doctor\Research\2-simulation\PredSimResults';
    folder_path_2 = 'DHondt_2023_3seg_0.1strengthbilevel_trapezoid';
    folder_path_3 = 'DHondt_2023_3seg_v1.mat';
    File.path = fullfile(folder_path_1, folder_path_2, File.folder, folder_path_3);

    % Check if the result mat file exists or not
    if exist(File.path, 'file')
        disp('File exists.');
    else
        disp('File does not exist. run MATLAB code to generate it');
        predictiveSimulation(assistance_input, 'trapezoid');
    end

    % Get ROM of kinematics
    ROM = xlhobj_func(File.path);
    objective = ROM;
end


% contrants on feasbile region
function tf = xconstraint(w)
    % Check for input conditions
    tf0 = w.T4 >0;
    tf3 = w.T1 >w.T4;
    tf1 =  w.T2 > w.T1;
    tf2 = w.T3 > w.T2;
    tf4 = w.T4 < 61;
    tf =   tf0& tf1 & tf2 & tf3 & tf4;
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


