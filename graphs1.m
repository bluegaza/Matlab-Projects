clc; clear; close all;

%% Step 1: Generate a Sample Signal
fs = 1000;  % Sampling frequency (Hz)
T = 10;     % Duration (s)
t = linspace(0, T, fs*T);  % Time vector

% Create a synthetic signal (Combination of sine waves + noise)
signal = sin(2 * pi * 2 * t) + 0.5 * sin(2 * pi * 10 * t) + ...
         0.3 * sin(2 * pi * 50 * t) + 0.2 * randn(size(t));

%% Step 2: Perform CEEMDAN Decomposition (or EMD as fallback)
num_imfs = 12;  % Number of IMFs to extract

if exist('ceemdan', 'file') == 2
    imfs = ceemdan(signal, 0.1, num_imfs);  % CEEMDAN decomposition
else
    imfs = emd(signal, 'MaxNumIMF', num_imfs);  % EMD decomposition
end

% Check IMF Dimensions
[num_rows, num_cols] = size(imfs);
if num_rows < num_imfs
    warning('Fewer IMFs than expected. Adjusting to available IMFs.');
    num_imfs = num_rows;  % Use available IMFs
end

%% Step 3: Plot All 14 Graphs in a Single Figure
figure;
tiledlayout(num_imfs + 2, 1, 'TileSpacing', 'compact');  % Compact layout

% Plot Original Signal
nexttile;
plot(t, signal, 'k', 'LineWidth', 1.2);
ylabel('Original');
title('EMD Scenario of Q_s');
grid on;

% Plot IMFs
for i = 1:num_imfs
    nexttile;
    if size(imfs, 1) >= i
        plot(t, imfs(i, :), 'b', 'LineWidth', 1);
        ylabel(['IMF ' num2str(i)]);
        set(gca, 'XTick', []);
        grid on;
    else
        warning(['IMF ' num2str(i) ' not available. Skipping.']);
    end
end

% Plot Residual
residual = signal - sum(imfs(1:num_imfs, :), 1);
nexttile;
plot(t, residual, 'r', 'LineWidth', 1);
ylabel('Residual');
xlabel('Samples');
grid on;

%% Step 4: Compute Correlation Coefficients
correlation_values = zeros(1, num_imfs);
for i = 1:num_imfs
    if size(imfs, 1) >= i
        correlation_values(i) = corr(signal', imfs(i, :)');
    else
        correlation_values(i) = NaN;  % Handle missing IMFs
    end
end

%% Step 5: Display Correlation Table in IEEE Style
figure;
uitable('Data', reshape(correlation_values, [6, 2])', ...
    'ColumnName', arrayfun(@(x) sprintf('IMF %d', x), 1:num_imfs, 'UniformOutput', false), ...
    'RowName', {'Ri'}, ...
    'Position', [50 50 700 80]);

title('Correlation Coefficient of Each IMF Component to Original Data');

disp('IMF Correlation Coefficients:');
disp(correlation_values);
