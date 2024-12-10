
% The function xlh_kneeMomArm calculates the external knee moment arm for multiple scenarios and optionally plots the results.

% Inputs:
% scenario_List (optional):
    % {'Scenario_Folder', 'MAT_File', 'Legend_Name', [Plot_Color]}
    % Scenario_Folder: Name of the folder containing scenario data.
    % MAT_File: Name of the .mat file with simulation results.
    % Legend_Name: String for the plot legend.
    % Plot_Color: RGB triplet or color string for the plot line.
    % If empty or not provided, a default list of scenarios is used.
% plotFlag (optional):
    % A boolean (true/false) that specifies whether to plot the results.
    % Defaults to false.

% Outputs:
% moment_arm_results:
    % A structure array where each entry corresponds to a scenario with fields:
    % name: The name/legend of the scenario.
    % moment_arm: Calculated moment arm values for the given scenario.

function [moment_arm_results] = xlh_kneeMomArm(scenario_List, plotFlag)

    
    %% Default Input Handling
    if nargin < 1 || isempty(scenario_List)
        scenario_List = {   'weakness\DHondt_2023_3seg_0.1strength', 'DHondt_2023_3seg_job64.mat', '10% strength', [0, 0.4470, 0.7410];
                        'DHondt_2023_3seg_1strength',  'DHondt_2023_3seg_v2.mat', '100% strength', 'black';
                      };
        warning('Input scenario_List is empty. Using default empty list.');
    end
    
    if nargin < 2 || isempty(plotFlag)
        plotFlag = true; % Default to plotting
    end
    
    %% keen joint center
    
    root_folder = 'C:\Users\lingh\OneDrive - KTH\MyFile\7-Doctor\Research\2-simulation\PredSimResults';
    
    numScenario = size(scenario_List,1);
    
    mat_paths = cell(1, numScenario);
    metric_path = cell(1, numScenario);
    legend_names = cell(1, numScenario);
    plot_colors = cell(1, numScenario); % Store colors for each scenario
    
    % Prepare paths and names
    for i = 1:numScenario
        mat_paths{i} = fullfile(root_folder, scenario_List{i,1}, scenario_List{i,2});
        metric_path{i} = fullfile(root_folder, scenario_List{i,1}, 'metric.mat');
    
	    legend_names{i} = scenario_List{i,3};
        plot_colors{i} = scenario_List{i, 4}; % Extract color
    end
     moment_arm_results = struct; % Store results for all scenarios
    
    
    % Process each scenario
    for j = 1:numScenario
        load(mat_paths{j});
        load(metric_path{j});
        
        
        % load('PredSimResults\DHondt_2023_3seg_1strength\DHondt_2023_3seg_v1.mat')
        % load('PredSimResults\DHondt_2023_3seg_1strength\metric.mat')
        
        knee = (S.rknee.xyz + S.rkneemed.xyz)/2;
        knee = knee(1:100,:);
        
        % load R
        vector_cop_toknee = knee - R.ground_reaction.COP_r;
        
        vector_F = R.ground_reaction.GRF_r;
        th = []; moment_arm = [];
        for i = R.ground_reaction.idx_stance_r'
        
            vector_kne = vector_cop_toknee(i,2:3);
            vector_f = vector_F(i,2:3);
        
            dot_product = dot(vector_kne, vector_f);
            
        %     % 计算模
            norm_A = norm(vector_kne);
            norm_B = norm(vector_f);
        
            
            % 计算夹角（以度为单位）
            theta_f = get_angle([0 1], vector_f);
            theta_kne = get_angle([0 1], vector_kne);
        
            theta_knef = theta_f-theta_kne;
            moment_arm_i = norm_A * sind(theta_knef);
        
            th = [th theta_knef];
            moment_arm = [moment_arm moment_arm_i];
    
        end
    
        % Store results
        moment_arm_results(j).name = legend_names{j};
        moment_arm_results(j).moment_arm = moment_arm;
    
        % Plot if enabled
        if plotFlag
            legendName = replace(legend_names{j}, '_', ' ');
            plot(moment_arm, 'DisplayName', legendName, 'Color', plot_colors{j}, 'LineWidth', 2); 
            hold on
        end
    
    end
    
    % Finalize plot if enabled
    if plotFlag
        legend show; 
        title('External knee moment arm (+ ADD - ABD)');
        hold off;
    end

end

