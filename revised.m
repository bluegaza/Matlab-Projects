clc; clear; close all;

%% ========== 1. Generate Power Time-Series Data for Node 7 ==========
num_samples = 120000; % More than 100,000 samples
t = linspace(0, 365, num_samples); % Time vector for 12 months
power_signal = sin(2 * pi * t / 365) + 0.5 * sin(4 * pi * t / 365) + 0.2 * randn(size(t));

% Figure 1: Original Power Signal
figure;
plot(t, power_signal, 'b');
xlabel('Time (Days)');
ylabel('Power Signal (p.u.)');
title('Generated Power Signal for Node 7');
grid on;
pause(0.1);

%% ========== 2. Perform Empirical Mode Decomposition (EMD) ==========
num_imfs = 10;
[imf_matrix, residual] = emd(power_signal, 'MaxNumIMF', num_imfs);

% Figure 2: IMF Decomposition (IMF 1-10 + Residual)
figure;
for j = 1:num_imfs
    subplot(11, 1, j);
    plot(t, imf_matrix(:, j), 'k');
    title(['IMF ' num2str(j)]);
    grid on;
end
sgtitle('IMF Decomposition (IMF 1-10) for Node 7');

subplot(11, 1, 11);
plot(t, residual, 'r');
xlabel('Time (Days)');
ylabel('Residual');
title('Residual Component');
grid on;
pause(0.1);

%% ========== 3. Compute Correlation Coefficients ==========
correlation_matrix = corrcoef(imf_matrix);

% Figure 3: Heatmap of IMF Correlation Coefficients
figure;
imagesc(correlation_matrix);
colorbar;
title('Correlation Coefficients of EMD Components');
xlabel('IMF Component');
ylabel('IMF Component');
axis square;
pause(0.1);

% Extract the first four components with the highest correlation coefficients
[~, sorted_indices] = sort(diag(correlation_matrix), 'descend');
selected_imfs = sorted_indices(1:4);

%% ========== 4. Reconstruct Signal Using Top 4 IMFs ==========
reconstructed_signal = sum(imf_matrix(:, selected_imfs), 2);

% Figure 4: Original vs Reconstructed Signal (Top 4 IMFs)
figure;
plot(t, power_signal, 'b', 'DisplayName', 'Original Signal');
hold on;
plot(t, reconstructed_signal, 'r--', 'DisplayName', 'Reconstructed Signal');
xlabel('Time (Days)');
ylabel('Signal Amplitude');
title('Original vs Reconstructed Signal for Node 7');
legend;
grid on;
pause(0.1);

%% ========== 5. Display All Required Outputs Before Saving ==========
disp('Displaying IMF Decomposition (IMF 1-10 + Residual)...');
figure(2);

disp('Displaying Heatmap of Correlation Coefficients...');
figure(3);

%% ========== 6. Save Outputs ==========
save('simulation_results_node7.mat', 'imf_matrix', 'correlation_matrix', 'reconstructed_signal', 't', 'power_signal');

disp('Simulation completed successfully. Results saved in "simulation_results_node7.mat".');
