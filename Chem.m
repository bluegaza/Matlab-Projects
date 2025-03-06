clc; clear; close all;

%% ========== 1. Define IEEE-14 Synthetic Load Data ==========
nyiso_nodes = [2, 3, 4, 5, 6, 9, 10, 11, 12, 13, 14];
nyiso_loads = [100, 120, 80, 90, 110, 70, 130, 95, 105, 115, 85];

num_nodes = 14;
bus_data = zeros(num_nodes, 3); % [Active Power, Reactive Power, Phase Angle]

for i = 1:length(nyiso_nodes)
    node = nyiso_nodes(i);
    if node <= num_nodes
        bus_data(node, 1) = nyiso_loads(i);       
        bus_data(node, 2) = nyiso_loads(i) * 0.3; 
    end
end

disp('Synthetic IEEE-14 Load Data Mapped to NYISO Regions.');

%% ========== 2. Generate Power Time-Series Data for Node 7 ==========
num_samples = 120000; 
t = linspace(0, 365, num_samples); 
power_signal = sin(2 * pi * t / 365) + 0.5 * sin(4 * pi * t / 365) + 0.2 * randn(size(t));

figure;
plot(t, power_signal, 'b');
xlabel('Time (Days)');
ylabel('Power Signal (p.u.)');
title('Generated Power Signal for Node 7');
grid on;

%% ========== 3. CEEMDAN Decomposition for Node 7 ==========
num_imfs = 10;

% Fix: Ensure CEEMDAN function is correctly defined
if exist('ceemdan', 'file') ~= 2
    error('CEEMDAN function not found or is not a function. Check ceemdan.m file.');
end

imf_matrix = ceemdan(power_signal, 0.1, num_imfs);

% Plot IMF components (1-10) and Residual
figure;
for j = 1:num_imfs
    subplot(11, 1, j);
    plot(t, imf_matrix(j, :), 'k');
    title(['IMF ' num2str(j)]);
    grid on;
end
sgtitle('CEEMDAN Decomposition (IMF 1-10) for Node 7');

subplot(11, 1, 11);
plot(t, imf_matrix(end, :), 'r');
xlabel('Time (Days)');
ylabel('Residual');
title('Residual Component');
grid on;

%% ========== 4. Correlation Coefficients ==========
correlation_matrix = corrcoef(imf_matrix');

figure;
imagesc(correlation_matrix);
colorbar;
title('Correlation Coefficients of CEEMDAN Components');
xlabel('IMF Component');
ylabel('IMF Component');
axis square;

[~, sorted_indices] = sort(diag(correlation_matrix), 'descend');
selected_imfs = sorted_indices(1:4);

%% ========== 5. Reconstruct Signal Using Top 4 IMFs ==========
reconstructed_signal = sum(imf_matrix(selected_imfs, :), 1);

figure;
plot(t, power_signal, 'b', 'DisplayName', 'Original Signal');
hold on;
plot(t, reconstructed_signal, 'r--', 'DisplayName', 'Reconstructed Signal');
xlabel('Time (Days)');
ylabel('Signal Amplitude');
title('Original vs Reconstructed Signal for Node 7');
legend;
grid on;

%% ========== 6. Save Outputs ==========
save('simulation_results_node7.mat', 'imf_matrix', 'correlation_matrix', 'reconstructed_signal', 't', 'power_signal');

disp('Simulation completed successfully. Results saved in "simulation_results_node7.mat".');
