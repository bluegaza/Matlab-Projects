clc; clear; close all;

% Define grid
x = linspace(0, 4000, 100);
y = linspace(0, 4000, 100);
[X, Y] = meshgrid(x, y);

% Define signal sources and power distribution
sources = [1000, 1000; 3000, 3000; 1000, 3000]; % Source positions
sigma = 500; % Spread of signal
P_max = -30; % Maximum power level in dBm
P_min = -110; % Minimum power level in dBm

% Compute power at each point
Z = zeros(size(X));
for i = 1:size(sources, 1)
    Z = Z + P_max * exp(-((X - sources(i,1)).^2 + (Y - sources(i,2)).^2) / (2*sigma^2));
end
Z = max(Z, P_min); % Enforce minimum power level

% Plot contour
figure;
contourf(X, Y, Z, 20, 'LineColor', 'k'); % Filled contour plot
colormap(jet); % Apply color map
colorbar;
clim([P_min P_max]); % Set color limits
xlabel('distance/m');
ylabel('distance/m');
title('Signal Strength Contour Plot (dBm)');
