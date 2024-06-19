
%% Clear workspace
if exist('result_paths','var')
    clearvars -Except result_paths
else
    clear
end
close all
clc

%% Get paths for later use
[pathHere,~,~] = fileparts(mfilename('fullpath'));
[pathRepo,~,~] = fileparts(pathHere);
[pathRepoFolder,~,~] = fileparts(pathRepo);

%% General settings
% These settings will apply to all figures

% Construct a cell array with full paths to files with saved results for
% which you want to appear on the plotted figures.
% Define the folder where result files are stored
results_folder = fullfile(pathRepo, 'PredSimResults');



% Define file paths for different result scenarios
scenario_names = {'DHondt_2023_3seg_1strength',...
                  'DHondt_2023_3seg_0.1strength',...
                  'DHondt_2023_3seg_0.1strength/_10hipAssistance', ...
                  'DHondt_2023_3seg_0.1strength/_20hipAssistance', ...
                  'DHondt_2023_3seg_0.1strength/_30hipAssistance', ...
                  'DHondt_2023_3seg_0.1strength/_40hipAssistance', ...
                  'DHondt_2023_3seg_0.1strength/_50hipAssistance', ...
                  'DHondt_2023_3seg_0.1strength/_60hipAssistance', ...
                  'DHondt_2023_3seg_0.1strength/_70hipAssistance'};

% Construct full file paths for each scenario
result_paths = cell(1, numel(scenario_names));
for i = 1:numel(scenario_names)
    result_paths{i} = fullfile(results_folder, scenario_names{i}, 'DHondt_2023_3seg_v1.mat');
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
            '70 assisted'};

% Path to the folder where figures are saved
figure_folder = results_folder;

% Common part of the filename for all saved figures
figure_savename = 'MyFirstPredictiveSimulationFigure';

%% Settings for each figure to be made
% "figure_settings" is a cell array where each cell contains a struct with
% the settings for a single figure.
% These settings are defined by several fields:
%   - name -
%   * String. Name assigned to the figure, and by default
%   appended to the filename when saving the figure.
%
%   - dofs -
%   * Cell array of strings. Can contain coordinate names OR muscle names.
%   Alternatively, 'all_coords' will use all coordinates from the 1st
%   result. Enter 'custom' to use variables that do not exist for individual
%   coordinates or muscles.
%
%   - variables -
%   * Cell array of strings. Containsone or more variable names. e.g. 'Qs'
%   to plot coordinate positions, 'a' to plot muscle activity. Variables
%   that do not rely on coordinates or muscles (e.g. GRFs)
%
%   - savepath -
%   * String. Full path + filename used to save the figure. Does not
%   include file extension.
%
%   - filetype -
%   * Cell array of strings. File extensions to save the figure as, leave
%   empty to not save the figure. Supported types are: 'png', 'jpg', 'eps'
%
%



% initilise the counter for dynamic indexing
fig_count = 1;

figure_settings(fig_count).name = 'all_angles';
figure_settings(fig_count).dofs = {'all_coords'};
figure_settings(fig_count).variables = {'Qs'};
figure_settings(fig_count).savepath = fullfile(figure_folder,[figure_savename '_' figure_settings(fig_count).name]);
figure_settings(fig_count).filetype = {};
fig_count = fig_count+1;

% figure_settings(fig_count).name = 'all_angles';
% figure_settings(fig_count).dofs = {'all_coords'};
% figure_settings(fig_count).variables = {'Qdots'};
% figure_settings(fig_count).savepath = fullfile(figure_folder,[figure_savename '_' figure_settings(fig_count).name]);
% figure_settings(fig_count).filetype = {};
% fig_count = fig_count+1;

% figure_settings(fig_count).name = 'all_angles';
% figure_settings(fig_count).dofs = {'all_coords'};
% figure_settings(fig_count).variables = {'Qddots'};
% figure_settings(fig_count).savepath = fullfile(figure_folder,[figure_savename '_' figure_settings(fig_count).name]);
% figure_settings(fig_count).filetype = {};
% fig_count = fig_count+1;

figure_settings(fig_count).name = 'all_activations';
figure_settings(fig_count).dofs = {'muscles_r'};
figure_settings(fig_count).variables = {'a'};
figure_settings(fig_count).savepath = fullfile(figure_folder,[figure_savename '_' figure_settings(fig_count).name]);
figure_settings(fig_count).filetype = {};
fig_count = fig_count+1;

% figure_settings(fig_count).name = 'selected_angles';
% figure_settings(fig_count).dofs = {'hip_flexion_r','hip_adduction_r','hip_rotation_r','knee_angle_r',...
%     'ankle_angle_r','subtalar_angle_r','mtp_angle_r'};
% figure_settings(fig_count).variables = {'Qs'};
% figure_settings(fig_count).savepath = fullfile(figure_folder,[figure_savename '_' figure_settings(fig_count).name]);
% figure_settings(fig_count).filetype = {'jpeg'};
% fig_count = fig_count+1;

figure_settings(fig_count).name = 'torques';
figure_settings(fig_count).dofs = {'all_coords'};
figure_settings(fig_count).variables = {'T_ID'};
figure_settings(fig_count).savepath = fullfile(figure_folder,[figure_savename '_' figure_settings(fig_count).name]);
figure_settings(fig_count).filetype = {'png'};
fig_count = fig_count+1;

% figure_settings(fig_count).name = 'ankle_muscles';
% figure_settings(fig_count).dofs = {'soleus_r','med_gas_r','lat_gas_r','tib_ant_r'};
% figure_settings(fig_count).variables = {'a','FT','lMtilde','Wdot','Edot_gait'};
% figure_settings(fig_count).savepath = fullfile(figure_folder,[figure_savename '_' figure_settings(fig_count).name]);
% figure_settings(fig_count).filetype = {};
% fig_count = fig_count+1;

figure_settings(fig_count).name = 'grfs';
figure_settings(fig_count).dofs = {'custom'};
figure_settings(fig_count).variables = {'GRF'};
figure_settings(fig_count).savepath = fullfile(figure_folder,[figure_savename '_' figure_settings(fig_count).name]);
figure_settings(fig_count).filetype = {};
fig_count = fig_count+1;

% figure_settings(fig_count).name = 'template';
% figure_settings(fig_count).dofs = {'custom'};
% figure_settings(fig_count).variables = {' '};
% figure_settings(fig_count).savepath = fullfile(figure_folder,[figure_savename '_' figure_settings(fig_count).name]);
% figure_settings(fig_count).filetype = {};
% fig_count = fig_count+1;

%%

plot_figures(result_paths,legend_names,figure_settings);
