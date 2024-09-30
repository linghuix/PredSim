
% load('C:\Users\lingh\OneDrive - KTH\ExMaterials\7-Doctor\Research\2-simulation\PredSimResults\DHondt_2023_3seg_0.1strengthfixStepWidth\metric.mat')
% load('C:\Users\lingh\OneDrive - KTH\ExMaterials\7-Doctor\Research\2-simulation\PredSimResults\DHondt_2023_3seg_0.1strength\metric.mat')
% load('C:\Users\lingh\OneDrive - KTH\ExMaterials\7-Doctor\Research\2-simulation\PredSimResults\DHondt_2023_3seg_1strength\metric.mat')
load('C:\Users\lingh\OneDrive - KTH\ExMaterials\7-Doctor\Research\2-simulation\PredSimResults\DHondt_2023_3seg_0.1strengthfixStepWidth\metric.mat')


% vertical
[val,loca] = min(S.Foot_r2.xyz(:,2))

% medial lateral
lateral = S.Foot_r2.xyz(:,3);
R1 = lateral(loca)





% vertical
[val,loca] = min(S.Foot_l2.xyz(:,2))

% medial lateral
lateral = S.Foot_l2.xyz(:,3);
L1 = lateral(loca)


stepWith = R1 - L1


%% keen joint center
load('PredSimResults\DHondt_2023_3seg_0.1strength\DHondt_2023_3seg_v1.mat')
load('PredSimResults\DHondt_2023_3seg_0.1strength\metric.mat')


% load('PredSimResults\DHondt_2023_3seg_1strength\DHondt_2023_3seg_v1.mat')
% load('PredSimResults\DHondt_2023_3seg_1strength\metric.mat')

knee = (S.rknee.xyz + S.rkneemed.xyz)/2;
knee = knee(1:200,:);

% load R
vector_cop_toknee = knee - R.ground_reaction.COP_r;

vector_F = R.ground_reaction.GRF_r;
th = []; moment_arm = [];
for i = R.ground_reaction.idx_stance_r'

    vector_1 = vector_cop_toknee(i,2:3);
    vector_2 = vector_F(i,2:3);

    dot_product = dot(vector_1, vector_2);
    
%     % 计算模
    norm_A = norm(vector_1);
    norm_B = norm(vector_2);

    
    % 计算夹角（以度为单位）
    theta_2 = get_angle([0 1], vector_2);
    theta_1 = get_angle([0 1], vector_1);

    theta = theta_2-theta_1
    moment_arm_i = norm_A * sind(theta);

    th = [th theta];
    moment_arm = [moment_arm moment_arm_i];
end

plot(moment_arm)