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
num_samples = 100000; % More than 100,000 samples
t = linspace(0, 365, num_samples); % Time vector for 12 months
power_signals = zeros(num_nodes, num_samples);

for i = 1:num_nodes
    power_signals(i, :) = sin(2 * pi * t / 365) + 0.5 * sin(4 * pi * t / 365) + 0.2 * randn(size(t));
end

% Plot Power Signal for Node 7
figure;
plot(t, power_signals(7, :));
xlabel('Time (Days)');
ylabel('Power Signal (p.u.)');
title('Generated Power Signal for Node 7');
grid on;

%% ========== 3. CEEMDAN Decomposition for Node 7 ==========
if exist('ceemdan', 'file') ~= 2
    error('CEEMDAN function not found. Please install or define it.');
end

num_imfs = 10; % Number of IMFs to extract
imf_matrix = ceemdan(power_signals(7, :), 0.1, num_imfs);

% Plot IMFs for Node 7
figure;
for j = 1:num_imfs
    subplot(num_imfs, 1, j);
    plot(t, imf_matrix(j, :));
    title(['IMF ' num2str(j) ' for Node 7']);
    grid on;
end
sgtitle('CEEMDAN Decomposition Components for Node 7');

% Plot Residual
figure;
plot(t, imf_matrix(end, :));
xlabel('Time (Days)');
ylabel('Residual');
title('Residual Component for Node 7');
grid on;

%% ========== 4. Correlation Coefficients of Decomposed Components ==========
correlation_matrix = corrcoef(imf_matrix');

% Display Correlation Matrix for Node 7
figure;
imagesc(correlation_matrix);
colorbar;
title('Correlation Coefficients of CEEMDAN Components (Node 7)');
xlabel('IMF Component');
ylabel('IMF Component');
axis square;

% Extract the first four components with the highest correlation coefficients
[~, sorted_indices] = sort(diag(correlation_matrix), 'descend');
selected_imfs = sorted_indices(1:4);

%% ========== 5. Reconstruct Signal Using Selected IMFs ==========
reconstructed_signal = sum(imf_matrix(selected_imfs, :), 1);

% Plot Original vs Reconstructed for Node 7
figure;
plot(t, power_signals(7, :), 'b', 'DisplayName', 'Original Signal');
hold on;
plot(t, reconstructed_signal, 'r--', 'DisplayName', 'Reconstructed Signal');
xlabel('Time (Days)');
ylabel('Signal Amplitude');
title('Original vs Reconstructed Signal for Node 7 (Using Top 4 IMFs)');
legend;
grid on;

%% ========== 6. Save Outputs ==========
save('simulation_results_node7.mat', 'imf_matrix', 'correlation_matrix', 'reconstructed_signal', 't', 'power_signals');

disp('Simulation completed successfully. Results saved in "simulation_results_node7.mat".');