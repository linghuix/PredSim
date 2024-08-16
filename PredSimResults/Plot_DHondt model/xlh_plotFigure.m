clc
clear
close all



%%

% subject = 'Falisse_et_al_2022';
subject = 'DHondt_2023_3seg';
% plot_results(subject, 'PF')
plot_results(subject, 'MF')
% plot_results(subject, 'MS')
% plot_results(subject, 'PS')

function [] = plot_results(model_subject, assistance_pattern_str)
% Construct a cell array with full paths to files with saved results for
% which you want to appear on the plotted figures.
% Define the folder where result files are stored
pathRepo = 'C:\Users\lingh\OneDrive - KTH\ExMaterials\7-Doctor\Research\2-simulation';
results_folder = fullfile(pathRepo, 'PredSimResults');


% model_subject = 'Falisse_et_al_2022';
folder = [model_subject '_0.1strength' assistance_pattern_str];
scenario_names = {[model_subject '_1strength'],...
                  [model_subject '_0.1strength/_0hipAssistance']};
% model_subject = 'DHondt_2023_3seg';
% Define file paths for different result scenarios
scenario_names = {scenario_names{1}, scenario_names{2} ...
                  [folder '/_10hipAssistance'], ...
                  [folder '/_20hipAssistance'], ...
                  [folder '/_30hipAssistance'], ...
                  [folder '/_40hipAssistance'], ...
                  [folder '/_50hipAssistance'], ...
                  [folder '/_60hipAssistance'], ...
                  [folder '/_70hipAssistance'], ...
                  [folder '/_80hipAssistance']};

% Construct full file paths for each scenario
result_paths = cell(1, numel(scenario_names));
for i = 1:numel(scenario_names)
    result_paths{i} = fullfile(results_folder, scenario_names{i}, [model_subject '_v1.mat']);
    BodyKinematics_paths{i} = fullfile(results_folder, scenario_names{i}, ['3-segment_foot_model_fixed_knee_axis_BodyKinematics_pos_global.sto']);
end


% Cell array with legend name for each result
legend_names = {'Normal', ...
                '10% strength',...
                ['10 assisted' assistance_pattern_str],...
                ['20 assisted' assistance_pattern_str],...
                ['30 assisted' assistance_pattern_str],...
                ['40 assisted' assistance_pattern_str],...
                ['50 assisted' assistance_pattern_str],...
                ['60 assisted' assistance_pattern_str],...
                ['70 assisted' assistance_pattern_str],...
                ['80 assisted' assistance_pattern_str]};

% Path to the folder where figures are saved
figure_folder = results_folder;

% Common part of the filename for all saved figures
figure_savename = 'MyFirstPredictiveSimulationFigure';


% loop over results
trunk_angle = [];
colors = hsv(length(result_paths));
colorIndex = 1;

dataStack = [];
dataStack_relative = [];
for i=1:length(result_paths)

    fprintf('reading from %s \r\n', result_paths{i})

    % load selected result

    load(result_paths{i},'R','model_info');


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


    legendName = replace(legend_names{i},'_',' ');
    
    % loop over figures
    figure(1)
        trunk_angle_i = R.kinematics.Qs(:,model_info.ExtFunIO.coordi.lumbar_bending)+R.kinematics.Qs(:,model_info.ExtFunIO.coordi.pelvis_list);
        
        % 200 length -> 100 length
        if length(trunk_angle_i) > 100
            trunk_angle_i = trunk_angle_i(1:2:end);
        end

        % store
        trunk_angle(i,:) = trunk_angle_i;
        
        % plot
        hold on
        if isequal('Normal', legendName)
            plot(trunk_angle(i,:),'color',[0 0 0], 'DisplayName',legendName,'LineWidth',2)
        elseif isequal('10% strength', legendName)
            plot(trunk_angle(i,:),'--','color',[0 0 0], 'DisplayName',legendName,'LineWidth',2)
        else
            plot(trunk_angle(i,:),'color',colors(colorIndex,:), 'DisplayName',legendName,'LineWidth',2)
        end
        hold off
        legend()

        title('trunk kinematics')
        xlabel('gait cycle (%)');
        ylabel('angle (degree)');
        
%     figure(2)
%         hip_abdtorque_i = R.kinematics.Qs(:,model_info.ExtFunIO.coordi.pelvis_list) + R.kinematics.Qs(:,model_info.ExtFunIO.coordi.lumbar_bending);

    figure(2)
        if (i>2)
            hold on
            hip_abdtorque_assistance_i = R.exo.Texo(:,2);
            % hip_abdtorque_assistance(i,:) =  hip_abdtorque_assistance_i;
            plot(hip_abdtorque_assistance_i, 'DisplayName',legendName,'LineWidth',2)
%             plot(R.S.Exo.Hip.TorRight, 'k*', 'DisplayName','reference')
            legend()

            title('right side assistance')
            xlabel('gait cycle (%)');
            ylabel('assistive torque (Nm)');
        end

% step width
    figure(3)
        stepwidth_i = R.spatiotemp.step_width_COP;

        % store
        stepwidth(i) = stepwidth_i;
        
        % plot
        hold on
        plot(i, stepwidth(i),'*', 'MarkerSize', 10, 'LineWidth',3, 'color',colors(colorIndex,:), 'DisplayName',legendName)
        
        hold off
        legend()

        title('step width')
        xlabel('gait cycle (%)');
        ylabel('distance (meter)');

% metabolic cost
   figure(4)
        COT_i = R.metabolics.Bhargava2004.COT;

        % store
        COT(i) = COT_i;
        
        % plot
        hold on
        plot(i, COT(i),'*', 'MarkerSize', 10, 'LineWidth',3, 'color',colors(colorIndex,:), 'DisplayName',legendName)

        hold off
        legend()

        title('cost of transport')
        xlabel('gait cycle (%)');
        ylabel('(J)');

% pelvis obliquity
   figure(5)
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
   figure(6)

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
%         legend()

        title('X CoM displacement')

        subplot(313)
        hold on
        plot(Data_bodyKinematics.time, Data_bodyKinematics.center_of_mass_Y,'color',colors(colorIndex,:), 'DisplayName',legendName,'LineWidth',2) 
        hold off
        xlabel('time (second)');
        ylabel('displacement (meter)');
%         legend()
        
        title('Y CoM displacement')

    colorIndex = colorIndex+1;
end


%% out of loop

% figure for ROM of trunck swing during walking
figure()

	data = trunk_angle';

	% Create a box plot with customized appearance
	boxplot(data, 'Labels', legend_names, 'BoxStyle', 'outline', 'Colors', 'k', 'Symbol', 'k+', 'Widths', 0.5);

	% Add title and labels
	title('trunk kinematics ROM');
	xlabel('cases');
	ylabel('angle (degree)');

	% Set grid and adjust axes properties
	grid on;
	set(gca, 'FontName', 'Arial', 'FontSize', 12);


% figure for ROM of trunck swing during walking
figure()

	data = pelvis';

	% Create a box plot with customized appearance
	boxplot(data, 'Labels', legend_names, 'BoxStyle', 'outline', 'Colors', 'k', 'Symbol', 'k+', 'Widths', 0.5);

	% Add title and labels
	title('pelvis obliquity ROM');
	xlabel('cases');
	ylabel('angle (degree)');

	% Set grid and adjust axes properties
	grid on;
	set(gca, 'FontName', 'Arial', 'FontSize', 12);




figure()

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



%% change of objective value based on normal case
figure()

subplot(231)
index = 1;                      % metabolic terms
    metabolic = dataStack(:,index);

    weak_case = metabolic(2);
    after_assist = metabolic(3:end);

    change = (after_assist-weak_case) ./ weak_case;
    
    bar(change)

    % Add title and axis labels
    title('metabolic cost change')
    xlabel('cases')
    ylabel('percentage')

    categories = legend_names(3:end);
    % Set the x-axis tick labels
    set(gca, 'XTickLabel', categories)

subplot(232)
index = 2;                      % MuscleActivity terms
    MuscleActivity = dataStack(:,index);

    weak_case = MuscleActivity(2);
    after_assist = MuscleActivity(3:end);

    change = (after_assist-weak_case) ./ weak_case;
    
    bar(change)

    % Add title and axis labels
    title([segmentLabels{index} ' change'])
    xlabel('cases')
    ylabel('percentage')

    categories = legend_names(3:end);
    % Set the x-axis tick labels
    set(gca, 'XTickLabel', categories)


subplot(233)
index = 3;                      % ArmExciation cost terms
    MuscleActivity = dataStack(:,index);

    weak_case = MuscleActivity(2);
    after_assist = MuscleActivity(3:end);

    change = (after_assist-weak_case) ./ weak_case;
    
    bar(change)

    % Add title and axis labels
    title([segmentLabels{index} ' change'])
    xlabel('cases')
    ylabel('percentage')

    categories = legend_names(3:end);
    % Set the x-axis tick labels
    set(gca, 'XTickLabel', categories)


subplot(234)
index = 4;                      % LowerJointAcc cost terms
    MuscleActivity = dataStack(:,index);

    weak_case = MuscleActivity(2);
    after_assist = MuscleActivity(3:end);

    change = (after_assist-weak_case) ./ weak_case;
    
    bar(change)

    % Add title and axis labels
    title([segmentLabels{index} ' change'])
    xlabel('cases')
    ylabel('percentage')

    categories = legend_names(3:end);
    % Set the x-axis tick labels
    set(gca, 'XTickLabel', categories)


subplot(235)
index = 5;                      % PassiveTor cost terms
    MuscleActivity = dataStack(:,index);

    weak_case = MuscleActivity(2);
    after_assist = MuscleActivity(3:end);

    change = (after_assist-weak_case) ./ weak_case;
    
    bar(change)

    % Add title and axis labels
    title([segmentLabels{index} ' change'])
    xlabel('cases')
    ylabel('percentage')

    categories = legend_names(3:end);
    % Set the x-axis tick labels
    set(gca, 'XTickLabel', categories)


%  objective term percentage
figure()

subplot(231)
index = 1;                      % metabolic terms
    metabolic = dataStack_relative(:,index);

    weak_case = metabolic(2);
    after_assist = metabolic(3:end);

    change = (after_assist-weak_case);
    
    bar(change)

    % Add title and axis labels
    title('metabolic cost percentage')
    xlabel('cases')
    ylabel('percentage')

    categories = legend_names(3:end);
    % Set the x-axis tick labels
    set(gca, 'XTickLabel', categories)

subplot(232)
index = 2;                      % MuscleActivity terms
    MuscleActivity = dataStack_relative(:,index);

    weak_case = MuscleActivity(2);
    after_assist = MuscleActivity(3:end);

    change = (after_assist-weak_case);
    
    bar(change)

    % Add title and axis labels
    title([segmentLabels{index} ' percentage'])
    xlabel('cases')
    ylabel('percentage')

    categories = legend_names(3:end);
    % Set the x-axis tick labels
    set(gca, 'XTickLabel', categories)


subplot(233)
index = 3;                      % ArmExciation cost terms
    MuscleActivity = dataStack_relative(:,index);

    weak_case = MuscleActivity(2);
    after_assist = MuscleActivity(3:end);

    change = (after_assist-weak_case);
    
    bar(change)

    % Add title and axis labels
    title([segmentLabels{index} ' percentage'])
    xlabel('cases')
    ylabel('percentage')

    categories = legend_names(3:end);
    % Set the x-axis tick labels
    set(gca, 'XTickLabel', categories)


subplot(234)
index = 4;                      % LowerJointAcc cost terms
    MuscleActivity = dataStack_relative(:,index);

    weak_case = MuscleActivity(2);
    after_assist = MuscleActivity(3:end);

    change = (after_assist-weak_case) ;
    
    bar(change)

    % Add title and axis labels
    title([segmentLabels{index} ' percentage'])
    xlabel('cases')
    ylabel('percentage')

    categories = legend_names(3:end);
    % Set the x-axis tick labels
    set(gca, 'XTickLabel', categories)


subplot(235)
index = 5;                      % PassiveTor cost terms
    MuscleActivity = dataStack_relative(:,index);

    weak_case = MuscleActivity(2);
    after_assist = MuscleActivity(3:end);

    change = (after_assist-weak_case) ;
    
    bar(change)

    % Add title and axis labels
    title([segmentLabels{index} ' percentage'])
    xlabel('cases')
    ylabel('percentage')

    categories = legend_names(3:end);
    % Set the x-axis tick labels
    set(gca, 'XTickLabel', categories)




end

