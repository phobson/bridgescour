
function slope = lvdtCalib(calib_number, plot_tog)
% This function uses LDVT readings in conjunction with digital
% high-precision caliper readings to calibrate the LDVT set-up.
%
% Inputs:
%   calib_number - which time the pot. is being calibrated
%       calib_number = 5 => 5th calibration
%       voltage files are calib5_*.txt
%       displacement file is displacement5.txt
%   plot_tog - toggles plotting functionality of this function.
%
% Output:
%   slope = the slope of the best-fit calibration line
%
% Other functions called:
%   readVoltage
%
% Example:
%   >> slope6 = lvdtCalibration(6);
%
%   See also readVoltage, instrCalib.
blu = [0 0 0.62];

x = dlmread(['displacement', num2str(calib_number) '.txt']);  % Displacements read off digital caliper
N = length(x);                      % number of files to read
vFileName = ['calib', num2str(calib_number), '_'];
[f, t, V] = readVoltage(N, vFileName, 1);    % read, voltage for each displacment
clear f t

% ExportFileName = ['fig_pot_calib', num2str(calib_number), '.eps'];

% find average voltage for each reading
V_avg = zeros(N,1);
for n = 1:N
    V_avg(n) = mean(V{n});
end

% do linear regression based on x and V_avg
[x_hat S] = lsq_linFit(x, V_avg, 1);

x_ = (0:1:600)';
V_hat = x_hat(1) + x_hat(2)*x_';
R2 = S(4);
SE = S(3);


% plot calibration data
if strcmp(plot_tog, 'plot')
    figure
    hold on
    h1 = plot(x,V_avg, 'ko', 'MarkerSize', 7);
    h2 = plot(x_,V_hat,'-', 'LineWidth', 2, 'Color',blu);
    xlabel('Displacement (mm)', 'FontSize',11)%, 'Interpreter','latex')
    ylabel('Voltage (V)', 'FontSize',11)%, 'Interpreter','latex')
    
    hL = legend([h1, h2], {'Data', 'Best-fit   line'});%
    set(hL, 'Location', 'NorthWest', 'FontSize',11);
%     set(hL, 'box','off');

    axis([0 650 0 10])
    text(350, 4.25, ['y-int = ', num2str(x_hat(1)), ' V'],'FontSize', 11)%,'Interpreter','latex')
    text(350, 3.50, ['slope = ', num2str(x_hat(2)), ' V/mm'], 'FontSize',11)%, 'Interpreter','latex')
    text(350, 2.75, ['$R^2$ = ', num2str(R2, '%0.3f')], 'FontSize',11)%, 'Interpreter','latex')
    text(350, 2.00, ['$SE$ = ', '0.0313 mm'], 'FontSize',11)%, 'Interpreter','latex')
    set(gca, 'TickDir', 'out', 'FontSize',11)
    grid on
    box on
    hold off
%     exFig(gcf, 'fig_calib_pot', 6, 4)
    exFig(gcf, 'fig_calib_pot', 5, 3.5)

end

slope = x_hat(2);