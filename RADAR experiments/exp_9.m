%% Experiment 9: Noise, C/N, and G/T
clc; 
clear;
close all
dB = @(x) 10*log10(x);          % converts a linear value to dB

%% Given values
k  = 1.38e-23;                  % Boltzmann constant (J/K)
B  = 1e6;                       % bandwidth (Hz)
Ts = 150;                       % system noise temperature (K)
C  = -100;                      % received carrier power (dBW)
G  = 35;                        % antenna gain (dBi)

%% Calculations
N  = dB(k*Ts*B);                % noise power, N = kTB (dBW)
CN = C - N;                     % carrier-to-noise ratio (dB)
GT = G - dB(Ts);                % figure of merit G/T (dB/K)
CN_check = C - G + GT - dB(k) - dB(B);   % same C/N, found using G/T

fprintf('Noise power N = %.4e W (%.2f dBW)\n', k*Ts*B, N);
fprintf('C/N = %.2f dB (%.2f linear)\n', CN, 10^(CN/10));
fprintf('G/T = %.2f dB/K\n', GT);
fprintf('C/N check = %.2f dB\n', CN_check);

%% Sweep values for the plots
T  = 50:10:1000;                % noise temperature range (K)
Gr = 10:60;                     % antenna gain range (dBi)

N_T  = dB(k*T*B);               % noise power vs T
CN_T = C - N_T;                 % C/N vs T
GT_G = Gr - dB(Ts);             % G/T vs gain (Ts fixed)
GT_T = G - dB(T);               % G/T vs T (G fixed)

%% Plots (one figure, four panels)
x      = {T, T, Gr, T};
y      = {N_T, CN_T, GT_G, GT_T};
pt     = {[Ts N], [Ts CN], [G GT], [Ts GT]};     % the given point on each plot
xl     = {'Noise Temperature (K)', 'Noise Temperature (K)', 'Antenna Gain (dBi)', 'Noise Temperature (K)'};
yl     = {'Noise Power (dBW)', 'C/N (dB)', 'G/T (dB/K)', 'G/T (dB/K)'};
ttl    = {'Noise Temperature vs Noise Power', 'Noise Temperature vs C/N', ...
          'Antenna Gain vs G/T', 'Noise Temperature vs G/T'};

figure
for i = 1:4
    subplot(2, 2, i)
    plot(x{i}, y{i}, 'LineWidth', 2); hold on
    plot(pt{i}(1), pt{i}(2), 'ro', 'MarkerFaceColor', 'r')   % given point
    grid on
    xlabel(xl{i});
    ylabel(yl{i});
    title(ttl{i})
    legend('Curve', 'Given point', 'Location', 'best')
end