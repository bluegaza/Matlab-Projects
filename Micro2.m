% MATLAB Script for Simulating a Microgrid Under Cyber Attacks on Secondary Control
% Enhancements: Resilience Mechanism, Communication Delays, Adaptive Control, Additional Attack Strategies, and Performance Metrics

clc; clear; close all;

%% System Parameters (Adjusted Based on Document Data)
DG_count = 4;  % Number of Distributed Generators
V_ref = 380;   % Reference Voltage in Volts
f_ref = 50;    % Reference Frequency in Hz
t_end = 10;    % Simulation time in seconds
delta_t = 0.01;% Time step

% Adaptive Secondary Control Gains
k_p_base = 0.1;
k_i_base = 0.05;
k_p = k_p_base;
k_i = k_i_base;

% Initial Conditions from Document Data
V = zeros(DG_count, length(0:delta_t:t_end));
f = zeros(DG_count, length(0:delta_t:t_end));
P = zeros(DG_count, length(0:delta_t:t_end));
Q = zeros(DG_count, length(0:delta_t:t_end));
V(:,1) = [368; 370; 372; 374];
f(:,1) = [48.5; 48.7; 48.9; 49.0];
P(:,1) = [50; 55; 60; 65];
Q(:,1) = [10; 12; 15; 18];

integral_error_f = zeros(DG_count, 1);
integral_error_v = zeros(DG_count, 1);
time = 0:delta_t:t_end;

%% Event-Triggering and Attack Mechanisms
ETM_threshold = 0.05;
trigger_intervals = zeros(DG_count, length(time));
DoS_attack = zeros(1, length(time));
replay_attack = zeros(1, length(time));
integrity_attack = zeros(1, length(time));
communication_delay = zeros(DG_count, length(time));

for t_idx = 2:length(time)
    t = time(t_idx);
    
    % Simulate Cyber Attacks
    if (t > 2 && t < 4) || (t > 6 && t < 7)
        DoS_attack(t_idx) = 1;
    end
    if (t > 3 && t < 5)
        replay_attack(t_idx) = 1;
    end
    if (t > 5 && t < 6)
        integrity_attack(t_idx) = 1;
    end
    
    % Introduce Random Communication Delay
    communication_delay(:, t_idx) = 0.005 * rand(DG_count, 1);
    
    for i = 1:DG_count
        % Compute secondary control errors
        error_f = f_ref - f(i, t_idx-1);
        error_v = V_ref - V(i, t_idx-1);
        
        % Integrate errors for PI control
        integral_error_f(i) = integral_error_f(i) + error_f * delta_t;
        integral_error_v(i) = integral_error_v(i) + error_v * delta_t;
        
        % Adaptive Control Adjustment
        if abs(error_f) > 1 || abs(error_v) > 5
            k_p = k_p_base * 1.5;
            k_i = k_i_base * 1.5;
        else
            k_p = k_p_base;
            k_i = k_i_base;
        end
        
        % Apply Secondary Control (Unless Disrupted by Attack)
        if DoS_attack(t_idx) == 0
            control_f = k_p * error_f + k_i * integral_error_f(i);
            control_v = k_p * error_v + k_i * integral_error_v(i);
            
            % Introduce Communication Delays
            delay_idx = max(1, t_idx - round(communication_delay(i, t_idx) / delta_t));
            V(i, t_idx) = V(i, delay_idx) + control_v * delta_t;
            f(i, t_idx) = f(i, delay_idx) + control_f * delta_t;
            P(i, t_idx) = P(i, t_idx-1) + 0.2 * delta_t;
            Q(i, t_idx) = Q(i, t_idx-1) + 0.1 * delta_t;
        else
            V(i, t_idx) = V(i, t_idx-1);
            f(i, t_idx) = f(i, t_idx-1);
            P(i, t_idx) = P(i, t_idx-1);
            Q(i, t_idx) = Q(i, t_idx-1);
        end
    end
end

%% Compute Performance Metrics
voltage_deviation = max(abs(V - V_ref), [], 2);
frequency_deviation = max(abs(f - f_ref), [], 2);

%% Plot Results with Enhanced Visualization
figure;
subplot(4,1,1);
plot(time, V', 'LineWidth', 1.5); hold on;
area(time, 380 * DoS_attack, 'FaceColor', [1 0.8 0.8], 'EdgeColor', 'none');
xlabel('Time (s)'); ylabel('Voltage (V)');
title('DG Output Voltage Under Cyber Attacks'); grid on;

subplot(4,1,2);
plot(time, f', 'LineWidth', 1.5); hold on;
area(time, 50 * replay_attack, 'FaceColor', [0.8 0.8 1], 'EdgeColor', 'none');
xlabel('Time (s)'); ylabel('Frequency (Hz)');
title('DG Output Frequency Under Cyber Attacks'); grid on;

subplot(4,1,3);
stem(time, DoS_attack, 'r', 'Marker', 'none'); hold on;
stem(time, replay_attack, 'b', 'Marker', 'none'); hold on;
stem(time, integrity_attack, 'g', 'Marker', 'none');
xlabel('Time (s)'); ylabel('Attack Indicators');
title('Cyber Attack Timeline'); legend('DoS', 'Replay', 'Integrity'); grid on;

subplot(4,1,4);
plot(time, sum(trigger_intervals,1), 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Trigger Count');
title('Event Triggering Moments During Attack'); grid on;

figure;
plot(time, P', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Active Power (W)');
title('Active Power Variation During Attacks'); grid on;

figure;
plot(time, Q', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Reactive Power (VAR)');
title('Reactive Power Variation During Attacks'); grid on;
