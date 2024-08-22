
%%

function analyze_RoM()
    % Clear command window and workspace
    clc;
    clear;

    % Define the folders corresponding to different levels of hip assistance
    folders = {'_10hipAssistance', '_20hipAssistance', '_30hipAssistance', '_40hipAssistance', ...
               '_50hipAssistance', '_60hipAssistance', '_70hipAssistance', ...
               '_80hipAssistance', '_90hipAssistance'};

    % Define the root directory containing the results
    root_folder = 'C:\Users\lingh\OneDrive - KTH\ExMaterials\7-Doctor\Research\2-simulation\PredSimResults\DHondt_2023_3seg_0.1strengthMF_MS';
    
    % Define the model folder path
    Model_folder = 'C:\Users\lingh\OneDrive - KTH\ExMaterials\7-Doctor\Research\2-simulation\Subjects';
    
    % Define the path to the OpenSim model file
    osim_path = [Model_folder '\DHondt_2023_3seg\DHondt_2023_3seg.osim'];
    
    % Analyze motion data for each folder
    for index = 1:length(folders)
        % Construct the full path to the results folder
        Results_folder = fullfile(root_folder, folders{index});
        
        % Construct the full path to the motion file (.mot)
        mot = fullfile(Results_folder, 'DHondt_2023_3seg_v1.mot');

        % Display a prompt indicating the current analysis folder
        disp(['Running analysis for: ', folders{index}]);
        disp(['motion file: ', mot]);

        % Run the analysis for the current folder
        run_BodyKinematics_analysis(osim_path, mot, Results_folder);

        % Display a prompt indicating completion of the current folder's analysis
        disp(['Completed analysis for: ', folders{index}]);
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
