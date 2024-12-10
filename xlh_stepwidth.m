
% xlh_stepWidth calculates and optionally plots the step width for different scenarios.
%
% This function computes the step width (difference in lateral positions of the 
% right and left foot markers at landing) for each scenario provided in the input 
% list. Optionally, it can plot the results using customizable colors for each scenario.
%
% Inputs:
%   - scenario_List: A cell array where each row defines a scenario with the following columns:
%       1. Scenario folder name (string)
%       2. metric MAT file name (string)
%       3. Legend name for labeling the plot (string)
%       4. RGB color triplet for plotting (1x3 numeric array)
%   - plotFlag: A boolean flag to enable (true) or disable (false) plotting. Default is false.
%
% Outputs:
%   - step_width_results: A structured array with the following fields:
%       1. name: The legend name of the scenario.
%       2. step_width: The computed step width for the scenario.
%
% Example Usage:
%   % Run with default scenarios and enable plotting:
%   results = xlh_stepWidth([], true);
%
%   % Run with a custom scenario list and disable plotting:
%   scenario_List = {
%       'Scenario1', 'file1.mat', 'Scenario 1', [0.5, 0.7, 0.9];
%       'Scenario2', 'file2.mat', 'Scenario 2', [0.9, 0.3, 0.5];
%   };
%   results = xlh_stepWidth(scenario_List, false);
%
% Author: [linghui]
% Date: [01/12/2024]

function [step_width_results] = xlh_stepwidth(scenario_List, plotFlag)

    %% Default Input Handling
    if nargin < 1 || isempty(scenario_List)
        scenario_List = {   'DHondt_2023_3seg_0.1strengthfixStepWidth', 'metric.mat', '10% strength fix', [0.2, 0.6, 0.8];
                            'DHondt_2023_3seg_0.1strength', 'metric.mat', '10% strength', [0.8, 0.2, 0.2];
                            'DHondt_2023_3seg_1strength', 'metric.mat', 'Normal', [0, 0, 0];
                        };
        warning('Input scenario_List is empty. Using default list.');
    end

    if nargin < 2 || isempty(plotFlag)
        plotFlag = true; % Default to no plotting
    end

    %% Initialize Variables
    root_folder = 'C:\Users\lingh\OneDrive - KTH\MyFile\7-Doctor\Research\2-simulation\PredSimResults';

    numScenario = size(scenario_List, 1);
    result_paths = cell(1, numScenario);
    legend_names = cell(1, numScenario);
    plot_colors = cell(1, numScenario);
    step_width_results = struct; % Store results for all scenarios

    % Prepare paths, names, and colors
    for i = 1:numScenario
        result_paths{i} = fullfile(root_folder, scenario_List{i, 1}, scenario_List{i, 2});
        legend_names{i} = scenario_List{i, 3};
        plot_colors{i} = scenario_List{i, 4};
    end

    %% Process Each Scenario
    step_widths = zeros(1, numScenario); % Preallocate step widths
    for i = 1:numScenario
        R = load(result_paths{i});

        % Get marker Foot_r2's lateral location when landing
        [~, loca_r] = min(R.S.Foot_r2.xyz(:, 2)); % Vertical min (landing)
        lateral_r = R.S.Foot_r2.xyz(loca_r, 3); % Lateral position

        % Get marker Foot_l2's lateral location when landing
        [~, loca_l] = min(R.S.Foot_l2.xyz(:, 2)); % Vertical min (landing)
        lateral_l = R.S.Foot_l2.xyz(loca_l, 3); % Lateral position

        % Compute Step Width
        step_width = lateral_r - lateral_l;
        step_widths(i) = step_width;

        % Store Results
        step_width_results(i).name = legend_names{i};
        step_width_results(i).step_width = step_width;
    end

    %% Plot Results if Enabled
    if plotFlag
        figure;
        for i = 1:numScenario
            bar(i, step_widths(i), 'FaceColor', plot_colors{i}, 'DisplayName', legend_names{i});
            hold on;
        end
        set(gca, 'XTick', 1:numScenario, 'XTickLabel', legend_names, 'XTickLabelRotation', 45);
        ylabel('Step Width (m)');
        title('Step Width for Different Scenarios');
        legend show;
        hold off;
    end

end
