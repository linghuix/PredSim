

% Set a fixed random seed for reproducibility
rng(42);  % Choose any fixed seed value

% Start a parallel pool if not already active
if isempty(gcp('nocreate'))
    % Create a parallel pool with a specified number of workers
    numWorkers = 4; % Specify the number of workers you want
    parpool(numWorkers); % Create a parallel pool with 4 workers
end

% Open a log file to save output
logFile = 'bayesian_optimization_test1.txt';
global savedfilename 

savedfilename = 'bayesian_optimization_test1.mat';

diary(logFile);  % Start logging to the file


% Define optimization variables
vars = [
    optimizableVariable('T1', [0, 99], 'Type', 'integer');
    optimizableVariable('Fmax', [0, 99], 'Type', 'real');
    optimizableVariable('T2', [0, 99], 'Type', 'integer');
    optimizableVariable('T3', [0, 99], 'Type', 'integer')
];

define_NumSeedPoints = 20;
define_MaxObjectiveEvaluations = 8;

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
disp(['Best x1: ', num2str(bestX.T1)]);
disp(['Best x2: ', num2str(bestX.Fmax)]);
disp(['Best x1: ', num2str(bestX.T2)]);
disp(['Best x2: ', num2str(bestX.T3)]);
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
    assistance_input = [w.T1, w.Fmax, w.T2, w.T3];
    formatted_numbers = cell(1, length(assistance_input));
    % Loop through each number, convert to string, replace '.' with '_'
    for i = 1:length(assistance_input)
        formatted_numbers{i} = strrep(sprintf('%.1f', assistance_input(i)), '.', '_');
    end
    File.string = strjoin(formatted_numbers, '__');

    File.folder = [ File.string 'hipAssistance'];

    folder_path_1 = 'C:\Users\lingh\OneDrive - KTH\MyFile\7-Doctor\Research\2-simulation\PredSimResults';
    folder_path_2 = 'DHondt_2023_3seg_0.1strengthbilevel';
    folder_path_3 = 'DHondt_2023_3seg_v1.mat';
    File.path = fullfile(folder_path_1, folder_path_2, File.folder, folder_path_3);

    % Check if the result mat file exists or not
    if exist(File.path, 'file')
        disp('File exists.');
    else
        disp('File does not exist. run MATLAB code to generate it');
        predictiveSimulation(assistance_input);
    end

    % Get ROM of kinematics
    ROM = xlhobj_func(File.path);
    objective = ROM;
end


% contrants on feasbile region
function tf = xconstraint(w)
    % Check for input conditions
    tf1 =  w.T2 > w.T1;
    tf2 = w.T3 > w.T2;
    tf = tf1 & tf2;
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


