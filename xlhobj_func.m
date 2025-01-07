

%%

% matfile - mat file location
function [metric] = xlhobj_func(matfile, string)
    
    if nargin < 2
        string = "weighted_rmse"; % Default value
    end
    
%     matfile = "C:\Users\lingh\OneDrive - KTH\MyFile\7-Doctor\Research\2-simulation\PredSimResults\DHondt_2023_3seg_0.1strengthbilevel\1_0__8_2__97_0__98_0hipAssistance\DHondt_2023_3seg_v1.mat"
    result = load(matfile);

    lumbar_bending = result.R.kinematics.Qs(:, result.model_info.ExtFunIO.coordi.lumbar_bending);
    pelvis_list = result.R.kinematics.Qs(:, result.model_info.ExtFunIO.coordi.pelvis_list);    % based on global coordinate
    trunk_angle = lumbar_bending + pelvis_list;                               % based on global coordinate
    

    if strcmp(string, "weighted_rmse")
        metric = metric_rmse(result);

    elseif strcmp(string, "rmse")
        metric = metric_rmse_even(result);

    elseif strcmp(string, "pelvis_trunk_rom")
        metric = metric_ROM(pelvis_list, trunk_angle);

    elseif strcmp(string, "DHondt_4seg_rmse")
        metric = metric_rmse_DHondt_et_al(result);
    end

end


function [ROM] = metric_ROM(pelvis_list, trunk_angle)  

    % figure for ROM of trunck swing during walking

    max_trunk = max(trunk_angle);

    max_pelvis =  max(pelvis_list);

	% Create a box plot with customized appearance
	ROM = ( max_pelvis + max_trunk)/2;
end


function [ROM] = metric_ROM_clip(pelvis_list, trunk_angle)  
    % figure for ROM of trunck swing during walking
    max_trunk = max(trunk_angle);
    max_trunk = max_trunk - max_trunk(1);
    max_trunk(max_trunk <=0) = 0;

    max_pelvis =  max(pelvis_list);
    max_pelvis = max_pelvis - max_pelvis(1);
    max_pelvis(max_pelvis <=0) = 0;

	% Create a box plot with customized appearance
	ROM = ( max_pelvis + max_trunk ) /2 ;
	% Add title and labels
	title('pelvis + trunk metric');
	xlabel('cases');
	ylabel('angle (degree)');
end


function [RMSE] = metric_rmse(results)

    pathRepo = 'C:\Users\lingh\OneDrive - KTH\MyFile\7-Doctor\Research\2-simulation';
    results_folder = fullfile(pathRepo, 'PredSimResults');
    control_paths = fullfile(results_folder, 'DHondt_2023_3seg_1strength', 'DHondt_2023_3seg_v2.mat');
    control = load(control_paths);
    
    weight = ones(1,33); 
    weight(results.model_info.ExtFunIO.coordi.pelvis_list) = 10;
    weight(results.model_info.ExtFunIO.coordi.lumbar_bending) = 10;

    weight = weight./sum(weight);

    r = 100*ones(1,33);
    for j = 1:33
        % 200 length -> 100 length
        RkinematicsQs_i = results.R.kinematics.Qs(:,j);
        if length(results.R.kinematics.Qs(:,j)) > 100
            RkinematicsQs_i = results.R.kinematics.Qs(1:2:end, j);
        end

        rmse_i = rmse(RkinematicsQs_i, control.R.kinematics.Qs(:,j));
        r(j) = rmse_i;
    end
    
    RMSE = sum(r.* weight);
end


function [RMSE] = metric_rmse_even(results)

    pathRepo = 'C:\Users\lingh\OneDrive - KTH\MyFile\7-Doctor\Research\2-simulation';
    results_folder = fullfile(pathRepo, 'PredSimResults');
    control_paths = fullfile(results_folder, 'DHondt_2023_3seg_1strength', 'DHondt_2023_3seg_v2.mat');
    control = load(control_paths);
    
    weight = ones(1,33); 
    weight = weight./sum(weight);

    r = 100*ones(1,33);
    for j = 1:33
        % 200 length -> 100 length
        RkinematicsQs_i = results.R.kinematics.Qs(:,j);
        if length(results.R.kinematics.Qs(:,j)) > 100
            RkinematicsQs_i = results.R.kinematics.Qs(1:2:end, j);
        end

        rmse_i = rmse(RkinematicsQs_i, control.R.kinematics.Qs(:,j));
        r(j) = rmse_i;
    end
    
    RMSE = sum(r.* weight);
end



function [RMSE] = metric_rmse_DHondt_et_al(results)

    joints_ref = {'pelvis_tilt'	'pelvis_list'	'pelvis_rotation'	'pelvis_tx'	'pelvis_ty'	'pelvis_tz'	'hip_flexion'	'hip_adduction'	'hip_rotation'	'knee_angle'	'ankle_angle'	'subtalar_angle'	'mtj_angle'	'mtp_angle'	'lumbar_extension'	'lumbar_bending'	'lumbar_rotation'	'arm_flex'	'arm_add'	'arm_rot'	'elbow_flex'};
    joints_sim = {'pelvis_tilt', 'pelvis_list', 'pelvis_rotation', 'pelvis_tx',	'pelvis_ty',	'pelvis_tz', 	'hip_flexion_r',	'hip_adduction_r',	'hip_rotation_r', 'knee_angle_r','ankle_angle_r','subtalar_angle_r','mtj_angle_r','mtp_angle_r', 'lumbar_extension','lumbar_bending','lumbar_rotation','arm_flex_r','arm_add_r','arm_rot_r','elbow_flex_r'};

    pathRepo = 'C:\Users\lingh\OneDrive - KTH\MyFile\7-Doctor\Research\2-simulation';
    control_paths = fullfile(pathRepo, '\PredSimResults\DHondt_2023_3seg_normalbilevel\', 'Fal_s1.mat');
    control = load(control_paths);

    RefData = 'Fal_s1_mtjcf3_FK_custom_right';
    
    data_field = ['IK_' RefData(8:end)];
    Qref = control.Data.(data_field);
    
    data_field = ['ID_' RefData(8:end)];
    Tref = control.Data.(data_field);
    
    data_field = ['P_' RefData(8:end)];
    Pref = control.Data.(data_field);
    

%     results = load(fullfile(pathRepo, 'PredSimResults\ReferenceResults\DHondt_et_al_2024_4seg', 'DHondt_et_al_2024_4seg_paper.mat'));
    Qsim = results.R.kinematics.Qs;
    colheadersim = results.R.colheaders.coordinates;
%     weight = ones(1,legnth(joints_ref)); 
%     weight = weight./sum(weight);

    r = 100*ones(1,length(joints_ref));

    for j = 1:length(joints_ref)
        
        idx_jref = strcmp(Qref.colheaders,joints_ref{j});
        Qs_mean_ref = Qref.Qall_mean(:,idx_jref);
        Qs_std_ref = Qref.Qall_std(:,idx_jref);

        idx_jsim = strcmp(colheadersim,joints_sim{j});
        Qs_jsim = Qsim(:,idx_jsim);
        if length(Qs_jsim) == 200
            Qs_jsim = Qs_jsim(1:100);
        end
        
        Qs_std_ref(Qs_std_ref == 0) = 100;
        Qs_std_ref(Qs_std_ref == 100) = min(Qs_std_ref);
        rmse_i = sqrt( mean( ((Qs_mean_ref - Qs_jsim)./Qs_std_ref).^2 ) );
        r(j) = rmse_i;
    end
    
    RMSE = mean(r);
end