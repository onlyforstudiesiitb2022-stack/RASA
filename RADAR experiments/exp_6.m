%% Radar Display Simulation: PPI, A-Scope, V-Scope and RHI
clc; clear; close all; rng(1);

%% Targets
R   = [800 200 190 700];            % horizontal range (m)
az  = [95 60 244 320];              % azimuth (deg from North)
h   = [100 60 50 200];              % height (m)
amp = [0.7 0.6 1 0.8];              % echo strength
mk  = {'o', '^', 'd', 's'};         % marker for each target
x = R.*sind(az);  y = R.*cosd(az);  % polar -> Cartesian

fprintf('Target Results\n');
for k = 1:4
    fprintf('T%d: Range = %d m, Azimuth = %d deg, Height = %d m\n', k, R(k), az(k), h(k));
end

figure('Color', 'w');

%% 1. PPI - Plan Position Indicator
subplot(2,2,1); hold on; axis([-1000 1000 -1000 1000]); axis square;
title('PPI - PLAN POSITION INDICATOR'); xlabel('X (m)'); ylabel('Y (m)');
th = 0:360;
for rr = 200:200:1000                                   % range rings
    plot(rr*cosd(th), rr*sind(th), '--', 'Color', [0.7 0.7 0.7]);
end
for k = 1:4
    plot(x(k), y(k), mk{k}, 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
end
sweep = plot([0 0], [0 0], 'k', 'LineWidth', 2);        % rotating beam
label = text(0, 0, '', 'FontSize', 8, 'FontWeight', 'bold');

%% 2. A-Scope - Range vs Echo Amplitude
r = 0:900;
subplot(2,2,2);
ascope = plot(r, zeros(size(r)), 'k', 'LineWidth', 1.5); grid on;
axis([0 900 0 1.2]);
title('A-SCOPE - RANGE VS ECHO'); xlabel('Range (m)'); ylabel('Echo Amplitude');

%% 3. V-Scope - Range vs Azimuth
subplot(2,2,3); hold on; grid on; axis([0 360 0 1000]);
title('V-SCOPE - RANGE VS AZIMUTH'); xlabel('Azimuth (degrees)'); ylabel('Range (m)');
for k = 1:4
    plot(az(k), R(k), mk{k}, 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
end

%% 4. RHI - Range Height Indicator
subplot(2,2,4); hold on; grid on; axis([0 900 0 1000]);
title('RHI - RANGE HEIGHT INDICATOR'); xlabel('Horizontal Range (m)'); ylabel('Height (m)');
for k = 1:4
    plot(R(k), h(k), mk{k}, 'MarkerSize', 8, 'MarkerFaceColor', 'k', 'MarkerEdgeColor', 'k');
end

%% Rotate the antenna (0 to 244 deg) and update PPI + A-Scope
for beam = 0:4:244
    set(sweep, 'XData', [0 1000*sind(beam)], 'YData', [0 1000*cosd(beam)]);

    dAz  = abs(mod(az - beam + 180, 360) - 180);        % angle between beam and target
    gain = max(exp(-(dAz/20).^2), 0.08);                % main beam + small sidelobe
    echo = 0.01*rand(size(r));
    for k = 1:4
        echo = echo + amp(k)*gain(k)*exp(-(r-R(k)).^2/(2*8^2));
    end
    set(ascope, 'YData', echo);

    hit = find(dAz < 2, 1);                             % beam is on a target
    if isempty(hit)
        set(label, 'String', '');
    else
        set(label, 'Position', [x(hit)+40 y(hit)], ...
            'String', sprintf('R = %dm  Az = %d%c', R(hit), az(hit), char(176)));
    end
    drawnow; pause(0.05);
end