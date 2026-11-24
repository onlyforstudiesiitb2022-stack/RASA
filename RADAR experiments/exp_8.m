clc; clear; close all;

% Constants
earth_radius = 6371;              % km
grav_param   = 398600.4418;       % km^3/s^2
earth_spin   = 7.2921159e-5;      % rad/s

% Choose orbit
altitudes   = [1000 20200 35786];  % LEO, MEO, GEO (km)
orbit_names = {'LEO','MEO','GEO'};
choice = input('Enter 1-LEO, 2-MEO, 3-GEO: ');

altitude     = altitudes(choice);
orbit_name   = orbit_names{choice};
orbit_radius = earth_radius + altitude;
period       = 2*pi*sqrt(orbit_radius^3 / grav_param);   % seconds
inclination  = deg2rad(53) * (choice ~= 3);              % GEO is equatorial

fprintf('%s | Altitude = %d km | Period = %.2f hours\n', orbit_name, altitude, period/3600);

% Satellite coordinates
time  = linspace(0, period, 300);
angle = 2*pi*time/period;
sat_x = orbit_radius * cos(angle);
sat_y = orbit_radius * sin(angle) * cos(inclination);
sat_z = orbit_radius * sin(angle) * sin(inclination);

% 3D Earth and orbit
figure;
[ex, ey, ez] = sphere(40);
surf(earth_radius*ex, earth_radius*ey, earth_radius*ez, ...
     'FaceColor','b', 'EdgeColor','none', 'FaceAlpha',0.6);
hold on; axis equal; grid on;
plot3(sat_x, sat_y, sat_z, 'r--');
satellite = plot3(sat_x(1), sat_y(1), sat_z(1), 'yo', 'MarkerFaceColor','y');
title([orbit_name ' Orbit']);

% Animate satellite
for k = 1:5:300
    set(satellite, 'XData',sat_x(k), 'YData',sat_y(k), 'ZData',sat_z(k));
    drawnow;
end

% Ground track
latitude  = rad2deg(asin(sat_z / orbit_radius));
longitude = mod(rad2deg(atan2(sat_y, sat_x) - earth_spin*time) + 180, 360) - 180;

% Coverage circle
coverage_angle = rad2deg(acos(earth_radius / orbit_radius));   % deg
circle_angle   = linspace(0, 2*pi, 100);
circle_lon = longitude(1) + coverage_angle*cos(circle_angle);
circle_lat = latitude(1)  + coverage_angle*sin(circle_angle);

figure;
plot(longitude, latitude, 'b.', 'LineWidth',1.5); hold on; grid on;
plot(circle_lon, circle_lat, 'r', 'LineWidth',1.8);
xlim([-180 180]); ylim([-90 90]);
xlabel('Longitude (deg)'); ylabel('Latitude (deg)');
title([orbit_name ' Ground Track and Coverage']);