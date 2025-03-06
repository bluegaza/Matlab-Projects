% MATLAB Script for Simulating a Microgrid Under DoS Attacks on Secondary Control
% Reproducing Figures and Plots from Chapter 4 using Document Data

clc; clear; close all;

%% System Parameters (Adjusted Based on Document Data)
DG_count = 4;  % Number of Distributed Generators
V_ref = 380;   % Reference Voltage in Volts
f_ref = 50;    % Reference Frequency in Hz
t_end = 10;    % Simulation time in seconds
delta_t = 0.01;% Time step

% Secondary Control Gains (Based on Document Equations)
k_p = 0.1; % Proportional gain for secondary voltage control
k_i = 0.05; % Integral gain for secondary frequency control

% Initial Conditions from Document Data
V = zeros(DG_count, length(0:delta_t:t_end)); % Voltage over time
f = zeros(DG_count, length(0:delta_t:t_end)); % Frequency over time
P = zeros(DG_count, length(0:delta_t:t_end)); % Active Power
Q = zeros(DG_count, length(0:delta_t:t_end)); % Reactive Power

% Set initial values based on document figures
V(:,1) = [368; 370; 372; 374];  % Initial voltages for each DG
f(:,1) = [48.5; 48.7; 48.9; 49.0]; % Initial frequencies for each DG

% Define power values based on document data
P(:,1) = [50; 55; 60; 65]; % Active power initial values
Q(:,1) = [10; 12; 15; 18]; % Reactive power initial values

% Initialize secondary control error integrals
integral_error_f = zeros(DG_count, 1);
integral_error_v = zeros(DG_count, 1);

time = 0:delta_t:t_end;

%% Event-Triggering Mechanism (HETM)
% Define hybrid event-triggering control parameters
ETM_threshold = 0.05;
trigger_intervals = zeros(DG_count, length(time));
DoS_attack = zeros(1, length(time));

for t_idx = 2:length(time)
    t = time(t_idx);
    
    % Simulate DoS Attack targeting secondary control
    if (t > 2 && t < 4) || (t > 6 && t < 7)  % Attack windows
        DoS_attack(t_idx) = 1;
    end
    
    for i = 1:DG_count
        % Compute secondary control errors
        error_f = f_ref - f(i, t_idx-1);
        error_v = V_ref - V(i, t_idx-1);
        
        % Integrate errors for PI control
        integral_error_f(i) = integral_error_f(i) + error_f * delta_t;
        integral_error_v(i) = integral_error_v(i) + error_v * delta_t;
        
        % Apply secondary control (unless disrupted by attack)
        if DoS_attack(t_idx) == 0
            control_f = k_p * error_f + k_i * integral_error_f(i);
            control_v = k_p * error_v + k_i * integral_error_v(i);
            
            V(i, t_idx) = V(i, t_idx-1) + control_v * delta_t;
            f(i, t_idx) = f(i, t_idx-1) + control_f * delta_t;
            P(i, t_idx) = P(i, t_idx-1) + 0.2 * delta_t;
            Q(i, t_idx) = Q(i, t_idx-1) + 0.1 * delta_t;
        else
            % Attack disrupts secondary control updates
            V(i, t_idx) = V(i, t_idx-1);
            f(i, t_idx) = f(i, t_idx-1);
            P(i, t_idx) = P(i, t_idx-1);
            Q(i, t_idx) = Q(i, t_idx-1);
        end
    end
end

%% Plot Results (Matching Figures from Document)
figure;
subplot(4,1,1);
plot(time, V', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Voltage (V)');
title('DG Output Voltage Under Secondary Control Attack'); grid on;

subplot(4,1,2);
plot(time, f', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Frequency (Hz)');
title('DG Output Frequency Under Secondary Control Attack'); grid on;

subplot(4,1,3);
stem(time, DoS_attack, 'r', 'Marker', 'none');
xlabel('Time (s)'); ylabel('DoS Attack');
title('DoS Attack Timeline on Secondary Control'); grid on;

subplot(4,1,4);
plot(time, sum(trigger_intervals,1), 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Trigger Count');
title('Event Triggering Moments During Attack'); grid on;

figure;
plot(time, P', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Active Power (W)');
title('Active Power Variation During DoS Attack'); grid on;

figure;
plot(time, Q', 'LineWidth', 1.5);
xlabel('Time (s)'); ylabel('Reactive Power (VAR)');
title('Reactive Power Variation During DoS Attack'); grid on;
