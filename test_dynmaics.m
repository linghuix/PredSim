
%     % Create zero (sparse) input vector for external function
%     F_ext_input = MX(model_info.ExtFunIO.input.nInputs,1);
%     % Assign Qs
%     F_ext_input(model_info.ExtFunIO.input.Qs.all,1) = Qskj_nsc(:,j+1);
%     % Assign Qdots
%     F_ext_input(model_info.ExtFunIO.input.Qdots.all,1) = Qdotskj_nsc(:,j+1);
%     % Assign Qdotdots (A)
%     F_ext_input(model_info.ExtFunIO.input.Qdotdots.all,1) = Aj_nsc(:,j);
%     % Assign forces and moments 
%     % (not used yet)
% 
%     % Evaluate external function
%     [Tj] = F(F_ext_input);



%% Muscle information
% Muscles from one leg and from the back
muscleNames = model_info.muscle_info.muscle_names;

% Total number of muscles
NMuscle = model_info.muscle_info.NMuscle;
[~,mai] = MomentArmIndices_asym(muscleNames, model_info.muscle_info.muscle_spanning_joint_info);

eq_constr = {};
M_lig_j = R.ligaments.moment;

nq = model_info.ExtFunIO.jointi.nq; % lengths of coordinate subsetsn 

%% Creating casadi functions
% Add CasADi to the path
if ~isempty(R.S.solver.CasADi_path)
    addpath(genpath(R.S.solver.CasADi_path));
end

if exist('f_casadi', 'var') == 0
    addpath([R.S.misc.main_path '\CasadiFunctions'])
    addpath([R.S.misc.main_path '\ModelComponents'])
    disp('Start creating CasADi functions...')
    disp(' ')
    t0 = tic;
    [f_casadi] = createCasadiFunctions(R.S,model_info);
    disp(' ')
    disp(['...CasADi functions created. Time elapsed ' num2str(toc(t0),'%.2f') ' s'])
    disp(' ')
    disp(' ')
end


for time = 1:200
% % We extract the specific tensions and slow twitch rations.
% tensions = struct_array_to_double_array(model_info.muscle_info.parameters,'specific_tension');
% [Hilldiffj,FTj,Fcej,Fpassj,Fisoj] = ...
%         f_casadi.forceEquilibrium_FtildeState_all_tendon(R.muscles.a(:,j),...
%         R.muscles.FTtilde(:,j),R.muscles.dFTtilde(:,j),...
%         R.muscles.lMT(:,j),R.muscles.vMT(:,j),tensions);
% FTj
% end

% calculate total number of joints that each muscle crosses (used later)
sumCross = sum(model_info.muscle_info.muscle_spanning_joint_info);


    [lMTj,vMTj,MAj] =  f_casadi.lMT_vMT_dM(R.kinematics.Qs_rad(time,:)',R.kinematics.Qdots_rad(time,:)');
    % Derive the moment arms of all the muscles crossing each joint
    for i=1:nq.musAct
        MA_j.(model_info.ExtFunIO.coord_names.muscleActuated{i}) = ...
            MAj(mai(model_info.ExtFunIO.jointi.muscleActuated(i)).mus',...
            model_info.ExtFunIO.jointi.muscleActuated(i));
    end

    % Add path constraints
    for i=1:nq.all
        % total coordinate torque
        Ti = 0;
    
        % muscle moment
        cond_special_mtp = strcmp(R.S.subject.mtp_type,'2022paper') &&...
            contains(model_info.ExtFunIO.coord_names.all{i},'mtp');
    
        if ismember(i,model_info.ExtFunIO.jointi.muscleActuated) && ~cond_special_mtp
            % muscle forces
            FTj_coord_i = R.muscles.FT(mai(i).mus',1);
            % total muscle moment
            M_mus_i = f_casadi.(['musc_cross_' num2str(sumCross(i))])...
                (MA_j.(model_info.ExtFunIO.coord_names.all{i}),FTj_coord_i);
            % add to total moment
            Ti = Ti + M_mus_i;
        end
        
        % torque actuator
        if nq.torqAct > 0 && ismember(i,model_info.ExtFunIO.jointi.torqueActuated)
            idx_act_i = find(model_info.ExtFunIO.jointi.torqueActuated(:)==i);
            T_act_i = a_akj(idx_act_i,j+1).*scaling.ActuatorTorque(idx_act_i);
            Ti = Ti + T_act_i;
        end
    
        % ligament moment
        Ti = Ti + M_lig_j(:,i);
        
        % passive moment
        if ~ismember(i,model_info.ExtFunIO.jointi.floating_base)
            Ti = Ti + Tau_passj(i);
        end
    
        Ti_exo = 0;
        % exoskeleton moment
        if R.S.Exo.Hip.available
            if strcmp(model_info.ExtFunIO.coord_names.all{i},'hip_adduction_l')
                Ti_exo = TorExo_k(1);
            elseif strcmp(model_info.ExtFunIO.coord_names.all{i},'hip_adduction_r')
                Ti_exo = TorExo_k(2);
            end
        end
        
        % total coordinate torque equals inverse dynamics torque
        eq_constr{end+1} = Ti+Ti_exo;
    
    end

end