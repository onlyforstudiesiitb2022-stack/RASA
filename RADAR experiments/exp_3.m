clc; clear; close all;

c = 3e8;                          % speed of light (m/s)

%% 1. Operating frequency vs Doppler frequency (v = 30 m/s)
v  = 30;
fc = [2 5 10 15 20] * 1e9;        % carrier frequencies (Hz)
lambda = c ./ fc;                 % wavelength
fd = 2 * v ./ lambda;             % Doppler shift = 2v/lambda

figure; plot(fc/1e9, fd, '-o'); grid on;
title('Operating Frequency vs Doppler Frequency');
xlabel('Operating Frequency (GHz)'); ylabel('Doppler Frequency (Hz)');

%% 2. Target distance vs received power (power falls as 1/R^4)
R = [50 100 200 500];             % distances (m)
P = (50 ./ R) .^ 4;               % power, normalized to 1 at 50 m

figure; semilogy(R, P, '-o'); grid on;
title('Effect of Target Distance on Received Power');
xlabel('Target Distance (m)'); ylabel('Normalized Received Power');

%% 3. Target velocity vs Doppler frequency (fc = 10 GHz)
v  = 10:10:50;                    % velocities (m/s)
fc = 10e9;
fd = 2 * v * fc / c;

figure; plot(v, fd, '-o'); grid on;
title('Target Velocity vs Doppler Frequency');
xlabel('Target Velocity (m/s)'); ylabel('Doppler Frequency (Hz)');

%% 4. Received Doppler signal (v = 30 m/s, fc = 10 GHz -> fd = 2000 Hz)
fs = 10000;                       % sampling frequency (Hz)
t  = 0 : 1/fs : 0.1 - 1/fs;       % 0.1 s of time samples
N  = length(t);
fd = 2 * 30 * 10e9 / c;           % = 2000 Hz

signal = exp(1j*2*pi*fd*t);                          % Doppler-shifted signal
noise  = 0.1 * (randn(1,N) + 1j*randn(1,N)) / sqrt(2);
x = signal + noise;                                  % received signal

figure; plot(t, real(x)); grid on;
title('Received Doppler Signal');
xlabel('Time (s)'); ylabel('Amplitude');

%% 5. FFT power spectrum
X = fftshift(fft(x));                                % FFT, zero frequency in the centre
f = -fs/2 : fs/N : fs/2 - fs/N;                      % frequency axis
power_dB = 10 * log10(abs(X).^2 / N);

figure; plot(f, power_dB); hold on;
xline(2000, '--k');                                  % expected Doppler shift
grid on; ylim([-60 40]);
title('Doppler Power Spectrum Using FFT');
xlabel('Frequency (Hz)'); ylabel('Power (dB)');
legend('FFT Power Spectrum', 'Expected f_D = 2000 Hz');