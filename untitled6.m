clc 
clear
Results_folder = 'C:\Users\lingh\OneDrive - KTH\ExMaterials\7-Doctor\Research\2-simulation\PredSimResults\DHondt_2023_3seg_0.1strengthMF\_30hipAssistance';
Model_folder = 'C:\Users\lingh\OneDrive - KTH\ExMaterials\7-Doctor\Research\2-simulation\Subjects';
osim_path = [Model_folder '\DHondt_2023_3seg\DHondt_2023_3seg.osim'];
mot = [Results_folder '\DHondt_2023_3seg_v1.mot'];


import org.opensim.modeling.*;

% model file and trc file
model = Model(osim_path);
state = model.initSystem();
motion = Storage(mot);


% analyze set
a_tool = AnalyzeTool();
a_tool.setModel(model);
a_tool.setCoordinatesFileName(mot)
% a_tool.setLowpassCutoffFrequency(6)
a_tool.setStatesFromMotion(state,motion,true);
a_tool.setFinalTime(inf);                        % inf means simulate to the end

% body kinematics
bk_tool = BodyKinematics();
bk_tool.setModel(model);
bk_tool.setName('test');

% analyze
analysis_set = a_tool.getAnalysisSet();
analysis_set.cloneAndAppend(bk_tool);

a_tool.addAnalysisSetToModel();
a_tool.setResultsDir(Results_folder);
% a_tool.setCoordinatesFileName('pos.sto')
% a_tool.setStatesFileName('states.sto')
% a_tool.setSpeedsFileName('ves.sto')
a_tool.run()


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
