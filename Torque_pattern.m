
%% biological moment inspired moment
gait_cycle = 0:0.01:1;

y_right = -1*sin(2*pi/1.2*gait_cycle).*(gait_cycle<0.6);
y_left = -1*sin(2*pi/1.2*(gait_cycle-0.5)).*(gait_cycle>=0.5 & gait_cycle<=1) - 35*sin(2*pi/1.2*(gait_cycle+0.5)).*(gait_cycle>=0 & gait_cycle<=0.1);
plot(gait_cycle,y_left)

%% biological power inspired moment



%% muscle moment inspired moment



%% muscle power inspired moment



%% grid search
gaitPhase_1 = 0.1;
gaitPhase_2 = 0.2;
peakTor = 1;
y_right_general = 

