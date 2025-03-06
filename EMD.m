clc; clear; close all;

%% ========== Define Nodes and Parameters ==========
nodes = [7, 8];
data_interval = 5 / (24 * 60); % 5-minute interval in days
num_samples = floor(365 / data_interval); % More than 105,000 samples
sample_index = 1:num_samples; % Number of samples
num_imfs = 10; % Number of Intrinsic Mode Functions (IMFs)

for node = nodes
    % ========== 1. Generate Power Time-Series Data ==========
    t = linspace(0, 365, num_samples); % Time vector for 12 months
    if node == 7
        power_signal = sin(2 * pi * t / 365) + 0.5 * sin(4 * pi * t / 365) + 0.2 * randn(size(t));
    else
        power_signal = sin(2 * pi * t / 365) + 0.3 * sin(6 * pi * t / 365) + 0.25 * randn(size(t));
    end
    
    % Figure 1: Original Power Signal
    figure;
    plot(sample_index, power_signal, 'b');
    xlabel('Number of Samples');
    ylabel('Power Signal (p.u.)');
    title(['Generated Power Signal for Node ' num2str(node)]);
    grid on;
    pause(0.1);
    
    % ========== 2. Perform Empirical Mode Decomposition (EMD) ==========
    [imf_matrix, residual] = emd(power_signal, 'MaxNumIMF', num_imfs);
    
    % Figure 2: IMF Decomposition (IMF 1-10 + Residual)
    figure;
    for j = 1:num_imfs
        subplot(11, 1, j);
        plot(sample_index, imf_matrix(:, j), 'k');
        title(['IMF ' num2str(j)]);
        grid on;
    end
    sgtitle(['IMF Decomposition (IMF 1-10) for Node ' num2str(node)]);
    
    subplot(11, 1, 11);
    plot(sample_index, residual, 'r');
    xlabel('Number of Samples');
    ylabel('Residual');
    title('Residual Component');
    grid on;
    pause(0.1);
    
    % ========== 3. Compute Correlation Coefficients ==========
    correlation_matrix = corrcoef(imf_matrix);
    
    % Figure 3: Heatmap of IMF Correlation Coefficients
    figure;
    imagesc(correlation_matrix);
    colorbar;
    title(['Correlation Coefficients of EMD Components for Node ' num2str(node)]);
    xlabel('IMF Component');
    ylabel('IMF Component');
    axis square;
    pause(0.1);
    
    % Extract the first four components with the highest correlation coefficients
    [~, sorted_indices] = sort(diag(correlation_matrix), 'descend');
    selected_imfs = sorted_indices(1:4);
    
    % ========== 4. Reconstruct Signal Using Top 4 IMFs ==========
    reconstructed_signal = sum(imf_matrix(:, selected_imfs), 2);
    
    % Figure 4: Original vs Reconstructed Signal (Top 4 IMFs)
    figure;
    plot(sample_index, power_signal, 'b', 'DisplayName', 'Original Signal');
    hold on;
    plot(sample_index, reconstructed_signal, 'r--', 'DisplayName', 'Reconstructed Signal');
    xlabel('Number of Samples');
    ylabel('Signal Amplitude');
    title(['Original vs Reconstructed Signal for Node ' num2str(node)]);
    legend;
    grid on;
    pause(0.1);
    
    % ========== 5. Sequence Decomposition of Active (p) and Reactive (q) Power ==========
    p_signal = power_signal; % Assume active power sequence
    q_signal = 0.7 * power_signal + 0.1 * randn(size(t)); % Simulated reactive power sequence
    
    [p_imfs, p_residual] = emd(p_signal, 'MaxNumIMF', num_imfs);
    [q_imfs, q_residual] = emd(q_signal, 'MaxNumIMF', num_imfs);
    
    % Figure 5: IMF Decomposition for Active Power (p)
    figure;
    for j = 1:num_imfs
        subplot(11, 1, j);
        plot(sample_index, p_imfs(:, j), 'k');
        title(['IMF ' num2str(j) ' (Active Power p)']);
        grid on;
    end
    sgtitle(['IMF Decomposition for Active Power (p) - Node ' num2str(node)]);
    
    subplot(11, 1, 11);
    plot(sample_index, p_residual, 'r');
    xlabel('Number of Samples');
    ylabel('Residual');
    title('Residual Component (Active Power p)');
    grid on;
    pause(0.1);
    
    % Figure 6: IMF Decomposition for Reactive Power (q)
    figure;
    for j = 1:num_imfs
        subplot(11, 1, j);
        plot(sample_index, q_imfs(:, j), 'k');
        title(['IMF ' num2str(j) ' (Reactive Power q)']);
        grid on;
    end
    sgtitle(['IMF Decomposition for Reactive Power (q) - Node ' num2str(node)]);
    
    subplot(11, 1, 11);
    plot(sample_index, q_residual, 'r');
    xlabel('Number of Samples');
    ylabel('Residual');
    title('Residual Component (Reactive Power q)');
    grid on;
    pause(0.1);
    
    % ========== 6. Save Outputs ==========
    save(['simulation_results_node' num2str(node) '.mat'], 'imf_matrix', 'correlation_matrix', 'reconstructed_signal', 'sample_index', 'power_signal', 'p_imfs', 'q_imfs');
    
    disp(['Simulation for Node ' num2str(node) ' completed successfully. Results saved.']);
end
