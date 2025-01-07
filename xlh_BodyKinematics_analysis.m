
%%

function analyze_RoM()
    % Clear command window and workspace
    clc;
    clear;

    % Define the folders corresponding to different levels of hip assistance
%     folders = {'_10hipAssistance', '_20hipAssistance', '_30hipAssistance', '_40hipAssistance', ...
%                '_50hipAssistance', '_60hipAssistance', '_70hipAssistance', ...
%                '_80hipAssistance', '_90hipAssistance'};

    % % weak muscle model
%     scenario_List = {['DHondt_2023_3seg' '_1strength'], ['DHondt_2023_3seg' '_v2.mot'], 'Normal';...
%                       'weakness\DHondt_2023_3seg_0.9strength', ['DHondt_2023_3seg' '_v2.mot'], '90% strength';...
%                       'weakness\DHondt_2023_3seg_0.8strength', ['DHondt_2023_3seg' '_v3.mot'], '80% strength';...
%                       'weakness\DHondt_2023_3seg_0.7strength', ['DHondt_2023_3seg' '_v3.mot'], '70% strength';...
%                       'weakness\DHondt_2023_3seg_0.6strength', ['DHondt_2023_3seg' '_job38.mot'], '60% strength'; ...
%                       'weakness\DHondt_2023_3seg_0.5strength', ['DHondt_2023_3seg' '_job44.mot'], '50% strength';...
%                       'weakness\DHondt_2023_3seg_0.4strength', ['DHondt_2023_3seg' '_job46.mot'], '40% strength'; ...
%                       'weakness\DHondt_2023_3seg_0.3strength', ['DHondt_2023_3seg' '_job59.mot'], '30% strength';...
%                       'weakness\DHondt_2023_3seg_0.2strength', ['DHondt_2023_3seg' '_job60.mot'], '20% strength'; ...
%                       'weakness\DHondt_2023_3seg_0.1strength', ['DHondt_2023_3seg' '_job64.mot'], '10% strength';...
%                       'weakness\DHondt_2023_3seg_0.05strength', ['DHondt_2023_3seg' '_job86.mot'], '5% strength'
%                       };

    scenario_List = {['assistance\DHondt_2023_3seg_0.1strengthMF_back\_18.6hipAssistance\'], ['DHondt_2023_3seg' '_job148.mot'], 'MF';...
                  ['assistance\DHondt_2023_3seg_0.1strengthMS_back\_18.6hipAssistance\'], ['DHondt_2023_3seg' '_job151.mot'], 'MS';...
                  ['assistance\DHondt_2023_3seg_0.1strengthPF_back\_18.6hipAssistance\'], ['DHondt_2023_3seg' '_job156.mot'], 'PF'; ...
                  ['assistance\DHondt_2023_3seg_0.1strengthPS_back\_18.6hipAssistance\'], ['DHondt_2023_3seg' '_job159.mot'], 'PS';...
                  ['assistance\DHondt_2023_3seg_0.1strengthMF_MS_back\_18.6hipAssistance\'], ['DHondt_2023_3seg' '_job165.mot'], 'MFMS'; ...
                  ['assistance\DHondt_2023_3seg_0.1strengthPF_PS_back\_18.6hipAssistance\'], ['DHondt_2023_3seg' '_job169.mot'], 'PFPS';...
				  ['assistance\DHondt_2023_3seg_0.1strengthNet_back\_0hipAssistance\'], ['DHondt_2023_3seg' '_job172.mot'], 'Net';...
                  };

    % Define the root directory containing the results
    root_folder = 'C:\Users\lingh\OneDrive - KTH\MyFile\7-Doctor\Research\2-simulation\PredSimResults\';
    
    % Define the model folder path
    Model_folder = 'C:\Users\lingh\OneDrive - KTH\MyFile\7-Doctor\Research\2-simulation\Subjects';
    
    % Define the path to the OpenSim model file
    osim_path = [Model_folder '\DHondt_2023_3seg\DHondt_2023_3seg.osim'];
    
    % Analyze motion data for each folder
    for index = 1:size(scenario_List, 1)
        % Construct the full path to the results folder
        Results_folder = fullfile(root_folder, scenario_List{index,1});
        
        % Construct the full path to the motion file (.mot)
        mot = fullfile(Results_folder, scenario_List{index ,2});

        if exist(mot, 'file') == 2  % Check if the file exists
            
        else
            fprintf('Skip, File does not exist: %s\n', mot);
            continue;  % Skip to the next iteration if the file doesn't exist
        end

        % Display a prompt indicating the current analysis folder
        disp(['Running analysis for: ', scenario_List{index, 1}]);
        disp(['motion file: ', mot]);

        % Run the analysis for the current folder
        run_BodyKinematics_analysis(osim_path, mot, Results_folder);

        % Display a prompt indicating completion of the current folder's analysis
        disp(['Completed analysis for: ', scenario_List{index, 1}]);
    end
end

function run_BodyKinematics_analysis(osim_path, mot, Results_folder)
    % Import OpenSim library
    import org.opensim.modeling.*;
    
    % Load the OpenSim model and initialize the system
    model = Model(osim_path);
    state = model.initSystem();
    
    % Load the motion data
    motion = Storage(mot);
    
    % Initialize the AnalyzeTool
    a_tool = AnalyzeTool();
    a_tool.setModel(model);
    a_tool.setCoordinatesFileName(mot);
    a_tool.setStatesFromMotion(state, motion, true);
    a_tool.setFinalTime(inf);  % Simulate to the end
    
    % Set up the Body Kinematics analysis
    bk_tool = BodyKinematics();
    bk_tool.setModel(model);
    bk_tool.setName('3-segment_foot_model_fixed_knee_axis_BodyKinematics');
    
    % Add the analysis to the AnalyzeTool
    analysis_set = a_tool.getAnalysisSet();
    analysis_set.cloneAndAppend(bk_tool);
    a_tool.addAnalysisSetToModel();
    
    % Specify the directory where results will be saved
    a_tool.setResultsDir(Results_folder);
    
    % Run the analysis
    a_tool.run();
end


%%
function test()
pk_tool = PointKinematics();
pk_tool.setRelativeToBody(updBodySet("ground"))
pk_tool.setBodyPoint()

pk_tool.setBody()
PhysicalFrame.updMobilizedBody("ground")
%%



% Set each coordinate value
n_coord = model_info.ExtFunIO.jointi.nq.all;

%% Initialise model
import org.opensim.modeling.*;
model = Model(osim_path);
state = model.initSystem;

% Get state vector
state_vars = model.getStateVariableValues(state);
state_vars.setToZero();
model.setStateVariableValues(state,state_vars);
model.realizePosition(state);




%%

% Set state vector to 0
state_vars.setToZero();
model.setStateVariableValues(s,state_vars);
model.realizePosition(s);
%%
coordset = model.getCoordinateSet();

for i=1:n_coord
    coordname_i = model_info.ExtFunIO.coord_names.all{i};
    coord_i = coordset.get(coordname_i);
    coord_state_idx = coord_i.getStateVariableValues(state).getAsMat;
    
    coordi_OpenSimAPI.(coordname_i) = coord_state_idx(1);
end

model_info.ExtFunIO.coordi_OpenSimAPIstate = coordi_OpenSimAPI;



end
