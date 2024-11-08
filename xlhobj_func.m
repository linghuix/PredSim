

%%

% matfile - mat file location
function [metric] = xlhobj_func(matfile, string)

    if nargin < 2
        string = "weighted_rmse"; % Default value
    end
    
    result = load(matfile);

    lumbar_bending = result.R.kinematics.Qs(:, result.model_info.ExtFunIO.coordi.lumbar_bending);
    pelvis_list = result.R.kinematics.Qs(:, result.model_info.ExtFunIO.coordi.pelvis_list);    % based on global coordinate
    trunk_angle = lumbar_bending + pelvis_list;                               % based on global coordinate
    

    if strcmp(string, "weighted_rmse")
        metric = metric_rmse(result);

    elseif strcmp(string, "rmse")
        metric_rmse_even(result);

    elseif strcmp(string, "pelvis_trunk_rom")
        metric = metric_ROM(pelvis_list, trunk_angle);
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
    weight(results.model_info.ExtFunIO.coordi.pelvis_list) = 1;
    weight(results.model_info.ExtFunIO.coordi.lumbar_bending) = 1;

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