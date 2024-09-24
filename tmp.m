%% 100% strength 
load('C:\Users\lingh\OneDrive - KTH\ExMaterials\7-Doctor\Research\2-simulation\PredSimResults\DHondt_2023_3seg_1strength\DHondt_2023_3seg_v1.mat')

hip_adduction_l_index = find(strcmp(R.colheaders.coordinates, 'hip_adduction_l'));
hip_abd_l_T = R.kinetics.T_ID(:,hip_adduction_l_index);
hip_abd_l_T = hip_abd_l_T(1:2:end);

plot(hip_abd_l_T);
hold on


hip_adduction_r_index = find(strcmp(R.colheaders.coordinates, 'hip_adduction_r'));
hip_abd_r_T = R.kinetics.T_ID(:,hip_adduction_r_index);
hip_abd_r_T = hip_abd_r_T(1:2:end);

plot(hip_abd_r_T)

%% 10% strength 
load('C:\Users\lingh\OneDrive - KTH\ExMaterials\7-Doctor\Research\2-simulation\PredSimResults\DHondt_2023_3seg_0.1strengthMF_back\_0hipAssistance\DHondt_2023_3seg_v1.mat')
% load('C:\Users\lingh\OneDrive - KTH\ExMaterials\7-Doctor\Research\2-simulation\PredSimResults\DHondt_2023_3seg_0.1strength\DHondt_2023_3seg_v1.mat')
hip_adduction_l_index = find(strcmp(R.colheaders.coordinates, 'hip_adduction_l'));
hip_abd_l_T_0_1 = R.kinetics.T_ID(:,hip_adduction_l_index);

plot(hip_abd_l_T_0_1);hold on

hip_adduction_r_index = find(strcmp(R.colheaders.coordinates, 'hip_adduction_r'));
hip_abd_r_T_0_1 = R.kinetics.T_ID(:,hip_adduction_r_index);

plot(hip_abd_r_T_0_1)



netT_HipAbd_L = hip_abd_l_T - hip_abd_l_T_0_1;

netT_HipAbd_R = hip_abd_r_T - hip_abd_r_T_0_1;



hold off
plot(hip_abd_r_T, '--', 'DisplayName', 'hip abd r T'); hold on
plot(hip_abd_r_T_0_1, '-*', 'DisplayName', 'hip abd r T 10% strength');
plot(netT_HipAbd_R, 'DisplayName', 'right Assistance');
plot(netT_HipAbd_L, 'DisplayName', 'left Assistance');


netDiff_nor_10percent_R = netT_HipAbd_R(1:50);
netDiff_nor_10percent_L = netT_HipAbd_L(1:50);
