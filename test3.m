
clc
clear
%% case 1

 [l, r, g] = T_bio([10 20 30 40 50 40 20 30], 0)   %{'T1', 'Fmax', 'T2', 'T3', 'T4'};
 plot(g(1:50), r); hold on; plot(g(51:end), l)

function [TorLeft, TorRight, phase] = T_bio(assistance_input, fullgait)
% Example usage:
%  [l, r, g] = T_trapezoid([  15 20 80 90 10])   %{'T1', 'Fmax', 'T2', 'T3', 'T4'};
%  plot(g, r)

%  [l, r, g] = T_trapezoid([  15 20 80 90 10], 0)   %{'T1', 'Fmax', 'T2', 'T3', 'T4'};
%  plot(g(1:50), r); hold on; plot(g(51:end), l)

    phase = 0:99;

    Ph_1 = assistance_input(1);
    Ph_2 = assistance_input(2);
    Ph_3 = assistance_input(3);
    Ph_4 = assistance_input(4);
    Ph_5 = assistance_input(5);
    peakTor1 = assistance_input(6);
    peakTor2 = assistance_input(7);
    peakTor3 = assistance_input(8);

    x = [0, Ph_1,    Ph_2, Ph_3, Ph_4, Ph_5, 99];
    y = [0, 0, peakTor1, peakTor2, peakTor3, 0, 0];

    Tor = generateCurve(x, y, 'pchip');
    if fullgait == 1
        TorLeft = [Tor.y(51:end) Tor.y(1:50)];      % right leg is first in exp
        TorRight = Tor.y;
    else
        TorLeft = Tor.y(51:end);      % right leg is first in exp
        TorRight = Tor.y(1:50);
    end

end

function curve = generateCurve(x, y, method)
% GENERATECURVE Generate a curve through given points using specified interpolation.
%
% Inputs:
%   x      - A vector of x-coordinates of the points.
%   y      - A vector of y-coordinates of the points (same length as x).
%   method - A string specifying the interpolation method ('spline', 'linear',
%           'nearest', 'pchip', 'cubic', 'v5cubic', 'makima', 'quadratic' etc.).
%
% Output:
%   curve - A structure containing the interpolated curve data:
%           curve.x - Interpolated x-coordinates.
%           curve.y - Interpolated y-coordinates.
%
% Example usage:
%   x = [1, 2, 3, 4];
%   y = [1, 4, 9, 16];
%   curve = generateCurve(x, y, 'spline');
%   plot(curve.x, curve.y, '-r', x, y, 'o');
%
% %% case 1
% x_phase  = [0, 10, 30, 50, 70, 99];
% y_torque = [0, 40, 20, 50, 0,  0];
% curve = generateCurve(x_phase, y_torque, 'pchip');
% plot(curve.x, curve.y, '-r', x_phase, y_torque, 'o'); % Plot interpolated curve and original points
% 
%
% %% case 2
% x_phase = [0, 5, 10, 30, 40, 50, 70, 100];
% y_torque = [0, 0, 40, 0, 0, 50, 0, 0];
% curve = generateCurve(x_phase, y_torque, 'pchip');
% plot(curve.x, curve.y, '-r', x_phase, y_torque, 'o'); % Plot interpolated curve and original points

    % Validate inputs
    if length(x) ~= length(y)
        error('Vectors x and y must have the same length.');
    end
    if length(x) < 2
        error('At least two points are required to generate a curve.');
    end
    if ~ischar(method) && ~isstring(method)
        error('Method must be a string specifying the interpolation method.');
    end

    % Generate a dense set of x-coordinates for interpolation
    x_dense = linspace(min(x), max(x), 100); % Adjust density as needed

    % Perform interpolation based on the selected method
    try
        y_dense = interp1(x, y, x_dense, method);
    catch ME
        error('Interpolation failed: %s', ME.message);
    end

    % Store the interpolated curve data in the output structure
    curve.x = x_dense;
    curve.y = y_dense;
end
