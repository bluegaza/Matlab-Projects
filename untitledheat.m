clc; clear; close all;

%% Generate Grid for Heatmap
x = linspace(0, 4000, 100);  % X-axis (0 to 4000 meters)
y = linspace(0, 4000, 100);  % Y-axis (0 to 4000 meters)
[X, Y] = meshgrid(x, y);

% Simulated Data: Example with three signal sources
signal_strength = -110 + 60 * (exp(-((X-1000).^2 + (Y-3000).^2)/5e5) + ...
                               exp(-((X-3000).^2 + (Y-1000).^2)/5e5) + ...
                               exp(-((X-1000).^2 + (Y-1000).^2)/5e5));

%% Plot Heatmap with Contours
figure;
contourf(X, Y, signal_strength, 30, 'LineColor', 'k'); % Filled contour plot
colormap(parula); % Set colormap
colorbar; % Add colorbar
caxis([-110 -50]); % Color range matching dBm scale

% Labels
xlabel('Distance (m)');
ylabel('Distance (m)');
title('Heatmap with Contours');
set(gca, 'FontSize', 12);
axis equal; % Ensure proper aspect ratio

%% Generate Frequency vs Power Data for Peak Detection
frequencies = [100 200 300 400 500 600 700 800 900 1000]; % Example strictly increasing values
power_levels = [-90 -85 -78 -88 -70 -60 -55 -80 -82 -75]; % Example power levels

% Ensure frequencies are strictly increasing
[frequencies, sortIdx] = sort(frequencies); % Sort frequencies in ascending order
power_levels = power_levels(sortIdx); % Apply same order to power levels

%% Find Peaks in Power Spectrum
[peak_powers, peak_indices] = findpeaks(power_levels, 'MinPeakHeight', -80);

% Convert peak indices to actual frequency values
peak_frequencies = frequencies(peak_indices);

% Display peak results
disp('Peak Power Levels:'), disp(peak_powers);
disp('Peak Frequencies:'), disp(peak_frequencies);

%% Plot Power Spectrum with Peaks
figure;
plot(frequencies, power_levels, '-o', 'LineWidth', 1.5);
hold on;
plot(peak_frequencies, peak_powers, 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r'); % Mark peaks
hold off;
xlabel('Frequency (Hz)');
ylabel('Power Level (dBm)');
title('Peak Detection in Power Spectrum');
grid on;
