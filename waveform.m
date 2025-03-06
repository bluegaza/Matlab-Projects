clc; clear; close all;

% Parameters
Vout_no_filter = 5.7; % Measured DC output without filter capacitor
Vout_with_filter = 6.1; % Measured DC output with filter capacitor
Vr_pp = 0.5; % Peak-to-peak ripple voltage with filter capacitor
ripple_freq = 120; % Ripple frequency in Hz
time = linspace(0, 1/ripple_freq, 1000); % Time vector for one ripple period

% Waveforms
Vout_wave_no_filter = Vout_no_filter + 0 * time; % DC output without filter (constant)
Vout_wave_with_filter = Vout_with_filter + (Vr_pp/2) * sin(2 * pi * ripple_freq * time); % DC output with ripple

% Plot without filter capacitor
figure;
plot(time, Vout_wave_no_filter, 'b', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Output Voltage Without Filter Capacitor');
grid on;

% Plot with filter capacitor
figure;
plot(time, Vout_wave_with_filter, 'r', 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Voltage (V)');
title('Output Voltage With Filter Capacitor');
grid on;
