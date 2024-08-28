
%% biological moment inspired moment
% gait_cycle = 0:0.01:1;
% 
% y_right = -1*sin(2*pi/1.2*gait_cycle).*(gait_cycle<0.6);
% y_left = -1*sin(2*pi/1.2*(gait_cycle-0.5)).*(gait_cycle>=0.5 & gait_cycle<=1) - 35*sin(2*pi/1.2*(gait_cycle+0.5)).*(gait_cycle>=0 & gait_cycle<=0.1);
% plot(gait_cycle,y_left)

%% biological power inspired moment



%% muscle moment inspired moment



%% muscle power inspired moment


function [TorLeft, TorRight] = Torque_pattern(gaitPhase_1, gaitPhase_peak, gaitPhase_2, peakTor, fullgaitcycle)
%% grid search
% gaitPhase_1 = 2;
% gaitPhase_2 = 32;
% gaitPhase_peak = 17;
% peakTor = 10;
% peakTor -  addcution is positive, back bend to right is positive


% 输入数据点
gaitPhase = [gaitPhase_1, gaitPhase_peak, gaitPhase_2];
tor = [0, peakTor, 0];

% 生成更密集的 gaitPhase 值
GaitPhase = linspace(min(gaitPhase), max(gaitPhase), gaitPhase_2-gaitPhase_1+1);

% 使用三次样条插值
Tor = interp1(gaitPhase, tor, GaitPhase, 'spline');

GaitPhase = 1:100;
Tor = [zeros(1,(gaitPhase_1-1)) Tor zeros(1, 100-(gaitPhase_2))];


% 绘制插值曲线
% plot(GaitPhase, Tor, '-r', gaitPhase, tor, 'o');
% xlabel('GaitPhase');
% ylabel('Tor');
% legend('三次样条插值', '数据点');

TorLeft = [Tor(51:end) Tor(1:50)];      % right leg is first in exp
TorRight = Tor;


if fullgaitcycle

else
    TorLeft = TorLeft(1:50);
    TorRight = TorRight(1:50);
end