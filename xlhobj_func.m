

%%

% matfile - mat file location
function [] = xlhobj_func(matfile)

    fprintf('reading from %s \r\n', matfile)
    
    load(matfile,'R','model_info');

    lumbar_bending = R.kinematics.Qs(:,model_info.ExtFunIO.coordi.lumbar_bending);
    pelvis_list = R.kinematics.Qs(:,model_info.ExtFunIO.coordi.pelvis_list);    % based on global coordinate
    trunk_angle = lumbar_bending + pelvis_list;                               % based on global coordinate
    
    metric2(pelvis_list, trunk_angle)

end


function [ROM] = metric2(pelvis_list, trunk_angle)  

    % figure for ROM of trunck swing during walking

    max_trunk = max(trunk_angle);

    max_pelvis =  max(pelvis_list);

	% Create a box plot with customized appearance
	ROM = ( max_pelvis + max_trunk)/2;
end


function [ROM] = metric1(pelvis_list, trunk_angle)  
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

