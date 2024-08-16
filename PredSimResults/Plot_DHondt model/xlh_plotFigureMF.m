clc
clear
close all

% Construct a cell array with full paths to files with saved results for
% which you want to appear on the plotted figures.
% Define the folder where result files are stored
pathRepo = 'C:\Users\lingh\OneDrive - KTH\ExMaterials\7-Doctor\Research\2-simulation';
results_folder = fullfile(pathRepo, 'PredSimResults');


model_subject = 'Falisse_et_al_2022';
folder = [model_subject '_0.1strengthMF'];
scenario_names = {[model_subject '_1strength/_0hipAssistance'],...
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
end


% Cell array with legend name for each result
legend_names = {'Normal', ...
                '10% strength',...
                '10 assisted',...
                '20 assisted',...
                '30 assisted',...
                '40 assisted',...
                '50 assisted',...
                '60 assisted',...
                '70 assisted',...
                '80 assisted'};

% Path to the folder where figures are saved
figure_folder = results_folder;

% Common part of the filename for all saved figures
figure_savename = 'MyFirstPredictiveSimulationFigure';


% loop over results
trunk_angle = [];
colors = hsv(length(result_paths));
colorIndex = 1;
for i=1:length(result_paths)
    % load selected result
    load(result_paths{i},'R','model_info');

    legendName = replace(legend_names{i},'_',' ');
    
    % loop over figures
    figure(1)
        trunk_angle_i = R.kinematics.Qs(:,model_info.ExtFunIO.coordi.pelvis_list) + R.kinematics.Qs(:,model_info.ExtFunIO.coordi.lumbar_bending);
        
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


colorIndex = colorIndex+1;
end

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
