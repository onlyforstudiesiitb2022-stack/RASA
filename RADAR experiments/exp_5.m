%% Pulse Doppler Radar - Range and Velocity Estimation
clc; clear; close all; rng(1);

%% Parameters
c = 3e8;  fc = 3e9;  lambda = c/fc;       % wavelength = 0.1 m
PRF = 15e3;  fs = 3e6;  Np = 150;         % pulse rate, sampling rate, no. of pulses
Ns = fs/PRF;  L = 3;                      % range bins per pulse (200), pulse width (1 us)

%% Targets
R = [3000 5000 7000];  v = [50 -30 80];  amp = [1 0.8 0.6];
fd = 2*v/lambda;                          % Doppler shift (Hz)
d  = round(2*R/c*fs);                     % echo delay (samples)

%% Received signal = noise + echoes (phase rotates from pulse to pulse)
rx = 0.1*(randn(Ns,Np) + 1j*randn(Ns,Np))/sqrt(2);
for k = 1:3
    rx(d(k)+1:d(k)+L,:) = rx(d(k)+1:d(k)+L,:) + amp(k)*exp(1j*2*pi*fd(k)*(0:Np-1)/PRF);
end

%% Range processing (matched filter) and Doppler processing (FFT)
mf = conv2(rx, ones(L,1)/L);  mf = mf(L:L+Ns-1,:);
RD = fftshift(fft(mf,[],2),2);
RDdB = 20*log10(abs(RD)/Np + 1e-6);
r    = (0:Ns-1)*c/(2*fs)/1e3;                    % range axis (km)
v_ax = (-Np/2:Np/2-1)*PRF/Np*lambda/2;           % velocity axis (m/s)

%% Find the 3 strongest peaks
tmp = abs(RD);
for k = 1:3
    [~,idx] = max(tmp(:));  [ri,di] = ind2sub(size(tmp),idx);
    Rk(k) = r(ri);  vk(k) = v_ax(di);
    tmp(max(ri-L,1):min(ri+L,Ns), max(di-3,1):min(di+3,Np)) = 0;   % erase this peak
end
fprintf('\nTarget Results\n');
fprintf('T%d: Range = %.2f km, Velocity = %.0f m/s\n', [1:3; Rk; vk]);

%% Plots
rp = mean(abs(mf),2);
subplot(3,2,1); 
plot((0:899)/fs*1e6, [ones(1,L) zeros(1,900-L)],'k','LineWidth',1.5);
title('Transmitted Pulse');
xlabel('Time (\mus)'); 
ylabel('Amplitude');
ylim([0 1.2]);
grid on;
subplot(3,2,2); plot(r, abs(mf(:,1)),'k');
title('Received Echo'); xlabel('Range (km)'); ylabel('Echo Amplitude'); xlim([0 10]); grid on;
subplot(3,2,3); plot(r, rp/max(rp),'k');
title('Range Profile'); xlabel('Range (km)'); ylabel('Amplitude'); xlim([0 10]); grid on;
subplot(3,2,4); plot(v_ax, max(RDdB,[],1),'k');
title('Velocity Spectrum'); xlabel('Velocity (m/s)'); ylabel('Magnitude (dB)'); xlim([-100 100]); ylim([-40 5]); grid on;
subplot(3,2,[5 6]); imagesc(r, v_ax, RDdB.'); axis xy; colormap(gray); colorbar; clim([-40 0]); hold on;
title('2-D Range-Velocity Map'); xlabel('Range (km)'); ylabel('Velocity (m/s)'); xlim([0 10]); ylim([-120 120]);
plot(Rk, vk, 'ko', 'MarkerSize',12, 'LineWidth',2, 'MarkerFaceColor','w');
text(Rk+0.15, vk, {'T1','T2','T3'}, 'FontWeight','bold', 'BackgroundColor','w');