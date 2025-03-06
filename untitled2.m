% Define grid size
x = linspace(0, 4000, 100);  % X-axis (0 to 4000 meters)
y = linspace(0, 4000, 100);  % Y-axis (0 to 4000 meters)
[X, Y] = meshgrid(x, y);

% Simulated Data: Example with three signal sources
signal_strength = -110 + 60 * (exp(-((X-1000).^2 + (Y-3000).^2)/5e5) + ...
                               exp(-((X-3000).^2 + (Y-1000).^2)/5e5) + ...
                               exp(-((X-1000).^2 + (Y-1000).^2)/5e5));

% Create heatmap
figure;
contourf(X, Y, signal_strength, 30, 'LineColor', 'k'); % Filled contour plot
colormap(parula); % Set colormap
colorbar; % Add colorbar
caxis([-110 -50]); % Color range matching dBm scale

% Add labels
xlabel('Distance (m)');
ylabel('Distance (m)');
title('Heatmap with Contours');

% Improve visualization
set(gca, 'FontSize', 12);
axis equal; % Ensure aspect ratio
