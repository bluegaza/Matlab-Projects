% Create a grid for the 2D plane
[x, y] = meshgrid(0:50:4000, 0:50:4000);

% Define the three source points
sources = [1000, 1000;   % Source 1 (x,y)
           3000, 1800;   % Source 2 (x,y)
           2000, 3000];  % Source 3 (x,y)

% Initialize signal strength matrix
signal_strength = zeros(size(x));

% Calculate signal strength at each grid point (sum of contributions from all sources)
for i = 1:size(sources, 1)
    % Calculate distance from current source to each grid point
    distance = sqrt((x - sources(i,1)).^2 + (y - sources(i,2)).^2);
    
    % Add signal contribution (free space path loss model)
    % Avoiding log of zero at source points by adding small value
    signal_strength = signal_strength - 20*log10(distance + 1) - 40;
end

% Create the figure
figure('Position', [100, 100, 600, 500]);

% Create the contour plot with filled contours
contourf(x, y, signal_strength, 20, 'LineWidth', 1);

% Add the lines only contour on top for the black lines
hold on;
contour(x, y, signal_strength, 20, 'LineColor', 'black', 'LineWidth', 0.75);

% Mark source points with black circles
for i = 1:size(sources, 1)
    plot(sources(i,1), sources(i,2), 'o', 'MarkerSize', 10, 'MarkerFaceColor', 'black', 'MarkerEdgeColor', 'black');
end

% Add colorbar and customize it
cb = colorbar;
ylabel(cb, 'dBm');
caxis([-110, -40]);  % Set color scale limits to match the original

% Set colormap to match the original (blue to cyan to yellow)
colormap(flipud(jet));

% Set axis limits
xlim([0 4000]);
ylim([0 4000]);
xlabel('distance/m');
ylabel('distance/m');

% Fix aspect ratio
axis square;

% Remove grid
grid off;

% Remove box
box off;

hold off;