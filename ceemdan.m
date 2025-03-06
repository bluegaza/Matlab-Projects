clc; clear; close all;

%% ========== 1. Define IEEE-14 Synthetic Load Data ==========
% Mapping NYISO regions to IEEE-14 nodes
nyiso_nodes = [2, 3, 4, 5, 6, 9, 10, 11, 12, 13, 14];
nyiso_regions = {'CAPITL', 'CENTREL', 'DUNWOD', 'GENESE', 'HUD VL', ...
                 'LONGIL', 'MHK VL', 'MILLWD', 'N.Y.C.', 'NORTH', 'WEST'};
nyiso_loads = [100, 120, 80, 90, 110, 70, 130, 95, 105, 115, 85];

% Initialize power flow data for IEEE-14 system
num_nodes = 14;
bus_data = zeros(num_nodes, 3); % Columns: [Active Power, Reactive Power, Phase Angle]

% Assign synthetic active/reactive power loads
for i = 1:length(nyiso_nodes)
    node = nyiso_nodes(i);
    bus_data(node, 1) = nyiso_loads(i);        % Active power (MW)
    bus_data(node, 2) = nyiso_loads(i) * 0.3;  % Reactive power (MVAR)
end

disp('Synthetic IEEE-14 Load Data Mapped to NYISO Regions.');

%% ========== 2. Generate Power Time-Series Data ==========
sampling_interval = 5 / (60 * 24); % Convert minutes to fraction of a day
t = 0:sampling_interval:365; % Time vector for 12 months
power_signals = zeros(num_nodes, length(t));

for i = 1:num_nodes
    power_signals(i, :) = sin(2 * pi * t / 365) + 0.5 * sin(4 * pi * t / 365) + 0.2 * randn(size(t));
end

% Plot Power Signals for All Nodes
figure;
for i = 1:num_nodes
    subplot(4, 4, i);
    plot(t, power_signals(i, :));
    xlabel('Time (Days)');
    ylabel('Power Signal (p.u.)');
    title(['Node ' num2str(i)]);
    grid on;
end
sgtitle('Generated Power Signals for All Nodes');

%% ========== 3. CEEMDAN Decomposition for Each Node ==========
if exist('ceemdan', 'file') ~= 2
    error('CEEMDAN function not found. Please install or define it.');
end

num_imfs = 6; % Number of IMFs to extract
imf_matrix = cell(num_nodes, 1);

for i = 1:num_nodes
    imf_matrix{i} = ceemdan(power_signals(i, :), 0.1, num_imfs);
end

% Plot IMFs for All Nodes
for i = 1:num_nodes
    figure;
    for j = 1:num_imfs
        subplot(num_imfs, 1, j);
        plot(t, imf_matrix{i}(j, :));
        title(['IMF ' num2str(j) ' for Node ' num2str(i)]);
        grid on;
    end
    sgtitle(['CEEMDAN Decomposition Components for Node ' num2str(i)]);
end

%% ========== 4. Correlation Coefficients of Decomposed Components ==========
correlation_matrix = zeros(num_nodes, num_imfs, num_imfs);

for i = 1:num_nodes
    correlation_matrix(i, :, :) = corrcoef(imf_matrix{i}');
end

% Display Correlation Matrix for All Nodes
for i = 1:num_nodes
    figure;
    imagesc(squeeze(correlation_matrix(i, :, :)));
    colorbar;
    title(['Correlation Coefficients of CEEMDAN Components (Node ' num2str(i) ')']);
    xlabel('IMF Component');
    ylabel('IMF Component');
    axis square;
end

%% ========== 5. Reconstruct Signal for Each Node ==========
reconstructed_signals = zeros(num_nodes, length(t));

for i = 1:num_nodes
    reconstructed_signals(i, :) = sum(imf_matrix{i}, 1);
end

% Plot Original vs Reconstructed for All Nodes
for i = 1:num_nodes
    figure;
    plot(t, power_signals(i, :), 'b', 'DisplayName', 'Original Signal');
    hold on;
    plot(t, reconstructed_signals(i, :), 'r--', 'DisplayName', 'Reconstructed Signal');
    xlabel('Time (Days)');
    ylabel('Signal Amplitude');
    title(['Original vs Reconstructed Signal for Node ' num2str(i)]);
    legend;
    grid on;
end

%% ========== 6. Compute System Voltage and Phase Angles ==========
% Assuming a constant voltage magnitude of 1.0 p.u.
voltage_magnitude = ones(num_nodes, 1);
phase_angle = linspace(-pi/6, pi/6, num_nodes); % Simulated phase angles

bus_data(:, 3) = phase_angle; % Store in data structure

% Plot Voltage Magnitudes
figure;
bar(voltage_magnitude);
title('Voltage Magnitude at IEEE-14 Nodes');
xlabel('Node Index');
ylabel('Voltage (p.u.)');

% Plot Phase Angles
figure;
bar(phase_angle);
title('Phase Angles at IEEE-14 Nodes');
xlabel('Node Index');
ylabel('Phase Angle (radians)');

%% ========== 7. Save Outputs ==========
save('simulation_results.mat', 'bus_data', 'imf_matrix', 'correlation_matrix', 'reconstructed_signals', 't', 'power_signals');

disp('Simulation completed successfully. Results saved in "simulation_results.mat".');