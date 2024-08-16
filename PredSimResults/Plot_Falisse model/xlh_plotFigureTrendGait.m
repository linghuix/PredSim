clc
clear
close all

% Construct a cell array with full paths to files with saved results for
% which you want to appear on the plotted figures.
% Define the folder where result files are stored
pathRepo = 'C:\Users\lingh\OneDrive - KTH\ExMaterials\7-Doctor\Research\2-simulation';
results_folder = fullfile(pathRepo, 'PredSimResults');


model_subject = 'Falisse_et_al_2022';
folder = [model_subject];
weakness = [0.05 0.1 0.2 0.3 0.4 0.5 0.6 0.8 1];

% Construct full file paths for each scenario
result_paths = cell(1, numel(weakness));
for i = 1:numel(weakness)
    result_paths{i} = fullfile(results_folder, [folder '_' num2str(weakness(i)) 'strength'], '_0hipAssistance', [model_subject '_v1.mat']);
end


% Cell array with legend name for each result
legend_names = {'5% strength', ...
                '10% strength',...
                '20% strength',...
                '30% strength',...
                '40% strength',...
                '50% strength',...
                '60% strength',...
                '80% strength',...
                '100% strength'};

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
    
% trunk angle
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
        plot(trunk_angle(i,:),'color',colors(colorIndex,:), 'DisplayName',legendName,'LineWidth',2)
        
        hold off
        legend()

        title('trunk kinematics')
        xlabel('gait cycle (%)');
        ylabel('angle (degree)');
     
% step width
    figure(2)
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
   figure(3)
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
