
clc
clear
close all


% Construct a cell array with full paths to files with saved results for
% which you want to appear on the plotted figures.
% Define the folder where result files are stored
pathRepo = 'C:\Users\lingh\OneDrive - KTH\ExMaterials\7-Doctor\Research\2-simulation';

%% 0.1
results_folder = fullfile(pathRepo, 'PredSimResults');
model_subject = 'Falisse_et_al_2022';
normal_case = fullfile(results_folder, [model_subject '_1strength'], [model_subject '_v1.mat']);
weak_case = fullfile(results_folder, [model_subject '_0.1strength/_0hipAssistance'], [model_subject '_v2.mat']);
info_weakness(results_folder, normal_case, weak_case, '0.1');

%% 0.5
% results_folder = fullfile(pathRepo, 'PredSimResults');
% model_subject = 'Falisse_et_al_2022';
% normal_case = fullfile(results_folder, [model_subject '_1strength'], [model_subject '_v1.mat']);
% weak_case = fullfile(results_folder, [model_subject '_0.5strength/_0hipAssistance'], [model_subject '_v1.mat']);
% info_weakness(results_folder, normal_case, weak_case, '0.5');

%%
function [data] = info_weakness(results_folder, normal_case, weak_case, weakness)

    model_subject = 'Falisse_et_al_2022';
    scenario_names = {[model_subject '_' weakness 'strength/_10hipAssistance'], ...
                      [model_subject '_' weakness 'strength/_20hipAssistance'], ...
                      [model_subject '_' weakness 'strength/_30hipAssistance'], ...
                      [model_subject '_' weakness 'strength/_40hipAssistance'], ...
                      [model_subject '_' weakness 'strength/_50hipAssistance'], ...
                      [model_subject '_' weakness 'strength/_60hipAssistance'], ...
                      [model_subject '_' weakness 'strength/_70hipAssistance']
                      };
    
    % Construct full file paths for each scenario
    result_paths = cell(1, numel(scenario_names)+2);
    result_paths{1} = normal_case;
    result_paths{2} = weak_case;
    for i = 1:numel(scenario_names)
        result_paths{i+2} = fullfile(results_folder, scenario_names{i}, [model_subject '_v3.mat']);
    end
    
    
    % Cell array with legend name for each result
    legend_names = {'Normal', ...
                    [weakness ' strength'],...
                    '10 assisted',...
                    '20 assisted',...
                    '30 assisted',...
                    '40 assisted',...
                    '50 assisted',...
                    '60 assisted',...
                    '70 assisted'
                    };
    
    % Path to the folder where figures are saved
    figure_folder = results_folder;
    
    % Common part of the filename for all saved figures
    figure_savename = 'MyFirstPredictiveSimulationFigure';
    
    
    % loop over results
    trunk_angle = [];
    colors = hsv(length(result_paths)-2);
    colorIndex = 1;
    for i=1:length(result_paths)
        % load selected result
        load(result_paths{i},'R','model_info');
    
        legendName = replace(legend_names{i},'_',' ');
        
        % loop over figures
        figure(1)
            trunk_angle_i = R.kinematics.Qs(:,model_info.ExtFunIO.coordi.pelvis_list) ...
                + R.kinematics.Qs(:,model_info.ExtFunIO.coordi.lumbar_bending);
            
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
            elseif isequal([weakness ' strength'], legendName)
                plot(trunk_angle(i,:),'--','color',[0 0 0], 'DisplayName',legendName,'LineWidth',2)
            else
                plot(trunk_angle(i,:),'color',colors(colorIndex,:), 'DisplayName',legendName,'LineWidth',2)
                colorIndex = colorIndex+1;
            end
            hold off
            legend()
    
            title('trunk kinematics')
            xlabel('gait cycle (%)');
            ylabel('angle (degree)');
            
    %     figure(2)
    %         hip_abdtorque_i = R.kinematics.Qs(:,model_info.ExtFunIO.coordi.pelvis_list) + R.kinematics.Qs(:,model_info.ExtFunIO.coordi.lumbar_bending);
    
        figure(3)
            if (i>2)
                hold on
                hip_abdtorque_assistance_i = R.exo.Texo(:,1);
                % hip_abdtorque_assistance(i,:) =  hip_abdtorque_assistance_i;
                plot(hip_abdtorque_assistance_i, 'DisplayName',legendName,'LineWidth',2)
    %             plot(R.S.Exo.Hip.TorLeft, 'k*', 'DisplayName','reference')
                legend()
    
                title('left side assistance')
                xlabel('gait cycle (%)');
                ylabel('assistive torque (Nm)');
            end
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
% 	    grid on;
	    set(gca, 'FontName', 'Arial', 'FontSize', 12);
end

