%% MTI Radar using Delay Line Canceller
% Aim: To simulate an MTI radar and remove stationary clutter
clc; clear; close all;

%% 1. Parameters
range = 0:0.1:100;                 % distance / range axis (km)

clutter1_pos = 20;  clutter1_amp = 9;    clutter1_width = 2;    % clutter at 20 km
clutter2_pos = 75;  clutter2_amp = 9.5;  clutter2_width = 3;    % clutter at 75 km
stat_pos     = 50;  stat_amp     = 9;    stat_width     = 1;    % stationary target at 50 km
move_amp     = 7.5; move_width   = 1;                           % moving target
move_pos1    = 35;                                              % moving target position, sweep 1 (km)
move_pos2    = 40;                                              % moving target position, sweep 2 (km)

%% 2. Echo shape: each echo is a Gaussian pulse
echo = @(pos, amp, width) amp * exp(-(range - pos).^2 / (2*width^2));

%% 3. Generate the signals
clutter    = echo(clutter1_pos, clutter1_amp, clutter1_width) + ...
             echo(clutter2_pos, clutter2_amp, clutter2_width);   % stationary clutter
stationary = echo(stat_pos, stat_amp, stat_width);               % stationary target

x_prev = clutter + stationary + echo(move_pos1, move_amp, move_width);   % Sweep 1: x[n-1]
x_curr = clutter + stationary + echo(move_pos2, move_amp, move_width);   % Sweep 2: x[n]

%% 4. Apply Single Delay Line Canceller: y[n] = x[n] - x[n-1]
mti_output = abs(x_curr - x_prev);

%% 5. Plots
figure('Name','MTI Radar - Delay Line Canceller');

% Plot 1: Sweep 1 (previous pulse)
subplot(3, 1, 1);
plot(range, x_prev, 'k', 'LineWidth', 1.8);
title({'1. Sweep 1: Clutter (20, 75 km), Stationary Target (50 km),', ...
       'Moving Target (35 km)'});
xlabel('Distance / Range (km)');
ylabel('Amplitude (V)');
ylim([0, 10]);
grid on;

% Plot 2: Sweep 2 (current pulse, delayed)
subplot(3, 1, 2);
plot(range, x_curr, 'k', 'LineWidth', 1.8);
title({'2. Sweep 2 (Delayed): Clutter & Stationary Target Unchanged,', ...
       'Moving Target Shifted to 40 km'});
xlabel('Distance / Range (km)');
ylabel('Amplitude (V)');
ylim([0, 10]);
grid on;

% Plot 3: Delay Line Canceller Output y[n]
subplot(3, 1, 3);
plot(range, mti_output, 'k', 'LineWidth', 1.8);
title({'3. MTI Output: Clutter & Stationary Targets Cancelled (0 V),', ...
       'Only Moving Target Detected'});
xlabel('Distance / Range (km)');
ylabel('Amplitude (V)');
ylim([0, 10]);
grid on;