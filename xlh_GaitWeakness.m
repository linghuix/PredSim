

clc
clear
close all

%%
dataStack = [];
dataStack_relative = [];

% Construct a cell array with full paths to files with saved results for
% which you want to appear on the plotted figures.
% Define the folder where result files are stored
pathRepo = 'C:\Users\lingh\OneDrive - KTH\MyFile\7-Doctor\Research\2-simulation';
results_folder = fullfile(pathRepo, 'PredSimResults');


% model_subject = 'Falisse_et_al_2022';
model_subject = 'DHondt_2023_3seg';
% Define file paths for different result scenarios
scenario_List = { 'weakness\DHondt_2023_3seg_0.9strength', [model_subject '_v2.mat'], '90% strength';
                  'weakness\DHondt_2023_3seg_0.8strength', [model_subject '_v3.mat'], '80% strength';
                  'weakness\DHondt_2023_3seg_0.7strength', [model_subject '_v3.mat'], '70% strength';
                  'weakness\DHondt_2023_3seg_0.6strength', [model_subject '_job38.mat'], '60% strength';
                  'weakness\DHondt_2023_3seg_0.5strength', [model_subject '_job44.mat'], '50% strength';
                  'weakness\DHondt_2023_3seg_0.4strength', [model_subject '_job46.mat'], '40% strength';
                  'weakness\DHondt_2023_3seg_0.3strength', [model_subject '_job59.mat'], '30% strength';
                  'weakness\DHondt_2023_3seg_0.2strength', [model_subject '_job60.mat'], '20% strength';
                  'weakness\DHondt_2023_3seg_0.1strength', [model_subject '_job64.mat'], '10% strength';
                  'weakness\DHondt_2023_3seg_0.05strength', [model_subject '_job86.mat'], '5% strength';
                  [model_subject '_1strength'], [model_subject '_v2.mat'], 'Normal';
                  };


% Construct full file paths for each scenario
numScenario = size(scenario_List,1);
result_paths = cell(1, numScenario);
BodyKinematics_paths = cell(1, numScenario); BodyV_paths = cell(1, numScenario);
legend_names = cell(1, numScenario);
for i = 1:numScenario
    result_paths{i} = fullfile(results_folder, scenario_List{i,1}, scenario_List{i,2});
    BodyKinematics_paths{i} = fullfile(results_folder, scenario_List{i}, ['_3-segment_foot_model_fixed_knee_axis_BodyKinematics_pos_global.sto']);
    BodyV_paths{i} = fullfile(results_folder, scenario_List{i}, ['_3-segment_foot_model_fixed_knee_axis_BodyKinematics_vel_global.sto']);
	legend_names{i} = scenario_List{i,3};
end


% loop over results
trunk_ang_toGRD = [];
colors = hsv(length(result_paths));
colorIndex = 1;
colors_lines = [];
for i=1:length(result_paths)
    % load selected result
    load(result_paths{i},'R','model_info');

    if strcmp(scenario_List{i, 3}, 'Normal')
        colors(colorIndex,:) = [0 0 0];
    end
    colors_lines = [colors_lines; colors(colorIndex,:)];


    % load absolute value
    objective_V = R.objective.absoluteValues;
    E_cost = objective_V(1);
    MuscleActivity_cost = objective_V(2);
    ArmExciation_cost = objective_V(3);
    LowerJointAcc_cost = objective_V(4);
    PassiveTor_cost = objective_V(5);

    data = [E_cost, MuscleActivity_cost, ArmExciation_cost, LowerJointAcc_cost, PassiveTor_cost];
    dataStack = [dataStack;data];

    % load relative value
    objective_V = R.objective.relativeValues;
    E_cost = objective_V(1);
    MuscleActivity_cost = objective_V(2);
    ArmExciation_cost = objective_V(3);
    LowerJointAcc_cost = objective_V(4);
    PassiveTor_cost = objective_V(5);

    data = [E_cost, MuscleActivity_cost, ArmExciation_cost, LowerJointAcc_cost, PassiveTor_cost];
    dataStack_relative = [dataStack_relative;data];

    % load bodyKinematics
    Data_bodyKinematics = readtable(BodyKinematics_paths{i}, 'FileType', 'text');
    Data_bodyV = readtable(BodyV_paths{i}, 'FileType', 'text');

    legendName = replace(legend_names{i},'_',' ');

    disp([legendName ' / ' R.S.misc.gaitmotion_type ' / MeshPoint：' num2str(R.S.solver.N_meshes) ' / kinematicsSize: ', num2str(size(R.kinematics.Qs))]);
    

    % trunk angle
    figure(1)
        trunk_ang_toGRDi = R.kinematics.Qs(:,model_info.ExtFunIO.coordi.pelvis_list) + R.kinematics.Qs(:,model_info.ExtFunIO.coordi.lumbar_bending);
        
        % 200 length -> 100 length
        if length(trunk_ang_toGRDi) > 100
            trunk_ang_toGRDi = trunk_ang_toGRDi(1:2:end);
        end
        
        % store
        trunk_ang_toGRD(i,:) = trunk_ang_toGRDi;
        
        % plot
        hold on
        plot(trunk_ang_toGRD(i,:),'color',colors(colorIndex,:), 'DisplayName',legendName,'LineWidth',2)
        hold off
        legend()

        title('trunk bending relative to ground')
        xlabel('gait cycle (%)');
        ylabel('angle (degree)');

        
    % step width
    figure(2)
        stepwidth_cop_i = R.spatiotemp.step_width_COP;

        % store
        stepwidth_cop(i) = stepwidth_cop_i;
        
        % plot
        hold on
        plot(i, stepwidth_cop(i),'*', 'MarkerSize', 10, 'LineWidth',3, 'color',colors(colorIndex,:), 'DisplayName',legendName)
        
        hold off
        legend()

        title('step width based on cop')
        xlabel('gait cycle (%)');
        ylabel('distance (meter)');


    % metabolic cost
   figure(3)
        COT_i = R.metabolics.Bhargava2004.COT;

        % store
        COT(i) = COT_i;
        
        % plot
        hold on
        plot(i, COT(i),'*', 'MarkerSize', 10, 'LineWidth',3, 'color',colors(colorIndex,:), 'DisplayName',legendName)

        hold off
        legend()

        title('cost of transport based on Bhargava2004')
        xlabel('gait cycle (%)');
        ylabel('cost of transport (J/m)');


   % pelvis obliquity
   figure(4)
        pelvis_i = R.kinematics.Qs(:,model_info.ExtFunIO.coordi.pelvis_list);

        % 200 length -> 100 length
        if length(pelvis_i) > 100
            pelvis_i = pelvis_i(1:2:end);
        end

        % store
        pelvis(i,:) = pelvis_i;
        
        % plot
        hold on
        plot(pelvis(i,:),'color',colors(colorIndex,:), 'DisplayName',legendName,'LineWidth',2) 
        hold off
        legend()

        title('pelvis obliquity')
        xlabel('gait cycle (%)');
        ylabel('angle (degree)');


   % CoM displacement
   figure(5)

        % plot
        subplot(311)
        hold on
        plot(Data_bodyKinematics.time, Data_bodyKinematics.center_of_mass_Z,'color',colors(colorIndex,:), 'DisplayName',legendName,'LineWidth',2) 
        hold off
        xlabel('time (second)');
        ylabel('displacement (meter)');
        legend()
        
        title('Z CoM displacement')

        subplot(312)
        hold on
        plot(Data_bodyKinematics.time, Data_bodyKinematics.center_of_mass_X,'color',colors(colorIndex,:), 'DisplayName',legendName,'LineWidth',2) 
        hold off
        xlabel('time (second)');
        ylabel('displacement (meter)');

        title('X CoM displacement')

        subplot(313)
        hold on
        plot(Data_bodyKinematics.time, Data_bodyKinematics.center_of_mass_Y,'color',colors(colorIndex,:), 'DisplayName',legendName,'LineWidth',2) 
        hold off
        xlabel('time (second)');
        ylabel('displacement (meter)');
        

        title('Y CoM displacement')


   % Extrapolated CoM displacement
   figure(6)

        eigenfrequency = sqrt(9.8/(1.34*0.91));    % g/(1.34*L)
        XCoM = Data_bodyKinematics.center_of_mass_Z + Data_bodyV.center_of_mass_Z/eigenfrequency;
        plot(Data_bodyKinematics.time, XCoM, 'color',colors(colorIndex,:), 'DisplayName',legendName,'LineWidth',2) 
        hold off
        xlabel('time (second)');
        ylabel('displacement (meter)');
        legend()
        hold on
        
        title('Extrapolated CoM displacement')


    colorIndex = colorIndex+1;
end


%%  out of loop

% figure for external Knee moment arm
figure(100)
MomArm_scenario_List = cell(size(scenario_List,1), size(scenario_List,2) + 1 );
for i = 1:length(result_paths)
    MomArm_scenario_List{i, 1} = scenario_List{i, 1};
    MomArm_scenario_List{i, 2} = scenario_List{i, 2};
    MomArm_scenario_List{i, 3} = scenario_List{i, 3};
    MomArm_scenario_List{i, 4} = colors_lines(i,:);
end

xlh_kneeMomArm(MomArm_scenario_List, true);


% figure for step width
Step_scenario_List = cell(size(scenario_List,1), size(scenario_List,2) + 1 );
for i = 1:length(result_paths)
    Step_scenario_List{i, 1} = scenario_List{i, 1};
    Step_scenario_List{i, 2} = 'metric.mat';
    Step_scenario_List{i, 3} = scenario_List{i, 3};
    Step_scenario_List{i, 4} = colors_lines(i,:);
end
xlh_stepwidth(Step_scenario_List, true)



% figure for ROM of trunck swing during walking
figure(10)

	data = trunk_ang_toGRD';

	% Create a box plot with customized appearance
	boxplot(data, 'Labels', legend_names, 'BoxStyle', 'outline', 'Colors', 'k', 'Symbol', 'k+', 'Widths', 0.5);

	% Add title and labels
	title('trunk bending relative to ground ROM');
	ylabel('angle (degree)');

	% Set grid and adjust axes properties
	set(gca, 'FontName', 'Arial', 'FontSize', 12);


% figure for ROM of trunck swing during walking
figure(11)

	data = pelvis';

	% Create a box plot with customized appearance
	boxplot(data, 'Labels', legend_names, 'BoxStyle', 'outline', 'Colors', 'k', 'Symbol', 'k+', 'Widths', 0.5);

	% Add title and labels
	title('pelvis obliquity ROM');
	ylabel('angle (degree)');

	% Set grid and adjust axes properties
	set(gca, 'FontName', 'Arial', 'FontSize', 12);

        
figure(12)

    categories = legend_names;
    segmentLabels = {'E', 'MuscleActivity cost', 'ArmExciation cost', 'LowerJointAcc cost', 'PassiveTor cost'};
    
    % Define five clear colors for each segment
    colors = [0.1, 0.6, 0.8;  % Blue
              0.9, 0.6, 0.1;  % Orange
              0.3, 0.7, 0.3;  % Green
              0.8, 0.3, 0.3;  % Red
              0.5, 0.4, 0.8]; % Purple
    
    % Create the stacked bar plot
    b = bar(dataStack, 'stacked');

    % Add title and axis labels
    title('Stacked Bar Plot with 5 terms in objective function')
    xlabel('cases')
    ylabel('Value')
    
    % Set the x-axis tick labels
    set(gca, 'XTickLabel', categories)
    
    % Add labels on top of each segment
    for i = 1:size(dataStack, 1)   % Loop through each bar group
        for j = 1:size(dataStack, 2) % Loop through each segment in the group
            % Calculate the cumulative height of the previous segments
            if j == 1
                cumulativeData = 0;
            else
                cumulativeData = sum(dataStack(i, 1:j-1));
            end
            
            % Calculate the center of the current segment
            segmentCenter = cumulativeData + dataStack(i, j) / 2;
            
            % Add the label to the segment
            text(i, segmentCenter+10, num2str(dataStack(i, j)), 'HorizontalAlignment', 'center');
        end
    end
    
    % Add a legend
    legend(segmentLabels, 'Location', 'northeastoutside');

    % Set colors for each segment
    for j = 1:size(dataStack, 2)
        b(j).FaceColor = 'flat';      % Enable flat coloring for each segment
        b(j).CData = repmat(colors(j, :), size(dataStack, 1), 1); % Apply color to each segment
    end

% change of objective value based on normal case
% figure()
% 
% subplot(231)
% index = 1;                      % metabolic terms
%     metabolic = dataStack(:,index);
% 
%     normal_case = metabolic(1);
%     after_weak = metabolic(2:end);
% 
%     change = (after_weak-normal_case) ./ normal_case;
%     
%     bar(change)
% 
%     % Add title and axis labels
%     title('metabolic cost change')
%     xlabel('cases')
%     ylabel('percentage')
% 
%     categories = legend_names(2:end);
%     % Set the x-axis tick labels
%     set(gca, 'XTickLabel', categories)
% 
% subplot(232)
% index = 2;                      % MuscleActivity terms
%     MuscleActivity = dataStack(:,index);
% 
%     normal_case = MuscleActivity(1);
%     after_weak = MuscleActivity(2:end);
% 
%     change = (after_weak-normal_case) ./ normal_case;
%     
%     bar(change)
% 
%     % Add title and axis labels
%     title([segmentLabels{index} ' change'])
%     xlabel('cases')
%     ylabel('percentage')
% 
%     categories = legend_names(2:end);
%     % Set the x-axis tick labels
%     set(gca, 'XTickLabel', categories)
% 
% 
% subplot(233)
% index = 3;                      % ArmExciation cost terms
%     MuscleActivity = dataStack(:,index);
% 
%     normal_case = MuscleActivity(1);
%     after_weak = MuscleActivity(2:end);
% 
%     change = (after_weak-normal_case) ./ normal_case;
%     
%     bar(change)
% 
%     % Add title and axis labels
%     title([segmentLabels{index} ' change'])
%     xlabel('cases')
%     ylabel('percentage')
% 
%     categories = legend_names(2:end);
%     % Set the x-axis tick labels
%     set(gca, 'XTickLabel', categories)
% 
% 
% subplot(234)
% index = 4;                      % LowerJointAcc cost terms
%     MuscleActivity = dataStack(:,index);
% 
%     normal_case = MuscleActivity(1);
%     after_weak = MuscleActivity(2:end);
% 
%     change = (after_weak-normal_case) ./ normal_case;
%     
%     bar(change)
% 
%     % Add title and axis labels
%     title([segmentLabels{index} ' change'])
%     xlabel('cases')
%     ylabel('percentage')
% 
%     categories = legend_names(2:end);
%     % Set the x-axis tick labels
%     set(gca, 'XTickLabel', categories)
% 
% 
% subplot(235)
% index = 5;                      % PassiveTor cost terms
%     MuscleActivity = dataStack(:,index);
% 
%     normal_case = MuscleActivity(1);
%     after_weak = MuscleActivity(2:end);
% 
%     change = (after_weak-normal_case) ./ normal_case;
%     
%     bar(change)
% 
%     % Add title and axis labels
%     title([segmentLabels{index} ' change'])
%     xlabel('cases')
%     ylabel('percentage')
% 
%     categories = legend_names(2:end);
%     % Set the x-axis tick labels
%     set(gca, 'XTickLabel', categories)
% 
% 
% %  objective term percentage
% figure()
% 
% subplot(231)
% index = 1;                      % metabolic terms
%     metabolic = dataStack_relative(:,index);
% 
%     normal_case = metabolic(1);
%     after_weak = metabolic(2:end);
% 
%     change = (after_weak-normal_case);
%     
%     bar(change)
% 
%     % Add title and axis labels
%     title('metabolic cost percentage')
%     xlabel('cases')
%     ylabel('percentage')
% 
%     categories = legend_names(2:end);
%     % Set the x-axis tick labels
%     set(gca, 'XTickLabel', categories)
% 
% subplot(232)
% index = 2;                      % MuscleActivity terms
%     MuscleActivity = dataStack_relative(:,index);
% 
%     normal_case = MuscleActivity(1);
%     after_weak = MuscleActivity(2:end);
% 
%     change = (after_weak-normal_case);
%     
%     bar(change)
% 
%     % Add title and axis labels
%     title([segmentLabels{index} ' percentage'])
%     xlabel('cases')
%     ylabel('percentage')
% 
%     categories = legend_names(2:end);
%     % Set the x-axis tick labels
%     set(gca, 'XTickLabel', categories)
% 
% 
% subplot(233)
% index = 3;                      % ArmExciation cost terms
%     MuscleActivity = dataStack_relative(:,index);
% 
%     normal_case = MuscleActivity(1);
%     after_weak = MuscleActivity(2:end);
% 
%     change = (after_weak-normal_case);
%     
%     bar(change)
% 
%     % Add title and axis labels
%     title([segmentLabels{index} ' percentage'])
%     xlabel('cases')
%     ylabel('percentage')
% 
%     categories = legend_names(2:end);
%     % Set the x-axis tick labels
%     set(gca, 'XTickLabel', categories)
% 
% 
% subplot(234)
% index = 4;                      % LowerJointAcc cost terms
%     MuscleActivity = dataStack_relative(:,index);
% 
%     normal_case = MuscleActivity(1);
%     after_weak = MuscleActivity(2:end);
% 
%     change = (after_weak-normal_case) ;
%     
%     bar(change)
% 
%     % Add title and axis labels
%     title([segmentLabels{index} ' percentage'])
%     xlabel('cases')
%     ylabel('percentage')
% 
%     categories = legend_names(2:end);
%     % Set the x-axis tick labels
%     set(gca, 'XTickLabel', categories)
% 
% 
% subplot(235)
% index = 5;                      % PassiveTor cost terms
%     MuscleActivity = dataStack_relative(:,index);
% 
%     normal_case = MuscleActivity(1);
%     after_weak = MuscleActivity(2:end);
% 
%     change = (after_weak-normal_case) ;
%     
%     bar(change)
% 
%     % Add title and axis labels
%     title([segmentLabels{index} ' percentage'])
%     xlabel('cases')
%     ylabel('percentage')
% 
%     categories = legend_names(2:end);
%     % Set the x-axis tick labels
%     set(gca, 'XTickLabel', categories)