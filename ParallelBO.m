

% Set a fixed random seed for reproducibility
rng(42);  % Choose any fixed seed value

% Start a parallel pool if not already active
if isempty(gcp('nocreate'))
    % Create a parallel pool with a specified number of workers
    numWorkers = 4; % Specify the number of workers you want
    parpool(numWorkers); % Create a parallel pool with 4 workers
end

% Open a log file to save output
logFile = 'bayesian_optimization_log.txt';
diary(logFile);  % Start logging to the file


% Define optimization variables
vars = [
    optimizableVariable('T1', [0, 99], 'Type', 'integer');
    optimizableVariable('Fmax', [0, 99], 'Type', 'real');
    optimizableVariable('T2', [0, 99], 'Type', 'integer');
    optimizableVariable('T3', [0, 99], 'Type', 'integer')
];

% Set up Bayesian Optimization
results = bayesopt(@Simulation, vars, ...
    'NumSeedPoints',20,...
    'IsObjectiveDeterministic', false, ...
    'MaxObjectiveEvaluations', 50, ...
    'UseParallel', true, ...
    'ParallelMethod','clipped-model-prediction',...
    'Verbose',1, ...
    'AcquisitionFunctionName', 'expected-improvement-plus');

% Display the best solution found
bestX = results.XAtMinObjective;
bestObjective = results.MinObjective;
disp(['Best x1: ', num2str(bestX.T1)]);
disp(['Best x2: ', num2str(bestX.Fmax)]);
disp(['Best x1: ', num2str(bestX.T2)]);
disp(['Best x2: ', num2str(bestX.T3)]);
disp(['Best Objective Value: ', num2str(bestObjective)]);



% diary off; % Stops logging to the file
% delete(gcp('nocreate'))



% Define a sample objective function
function objective = Simulation(w)

    % Check for input conditions
    if w.T2 <= w.T1 || w.T3 <= w.T2
        objective = 20;
        return;
    end

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

