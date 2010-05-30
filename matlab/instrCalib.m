function iCF = instrCalib(instrument)
% CALIBRATE LABORATORY INSTRUMENTS
%   This function calibrations an instrument whose reading are affected by
%   changes in temperature such as a soil pyncometer or hydrometer.  This
%   function reads data from text (*.txt) files with the following format:
%       Temp  Values
%       (C)   (units)  
%       T1    V1
%       T2    V2
%       T3    V3
%       T4    V4
%       ...   ...
%
%   Linear and quadratic regression are performed on the data and the best
%   value is selected based on correllation coeffecients.
%
%   Calibration curves for the flume's large pump and slope counter are
%   generated.
%
%   Inputs:
%       instrument - this is the name of the file (a string) in which the calibration data
%       is stored.  For example, the hydrometer calibration data is in
%       work/Calibrations/hydrometer.txt.  Available calibrations:
%           'hydrometer'
%           'pyncometer'
%           'slope_counter'
%           'pump'
%
%   Outputs:
%       iCF        - this is a vector of the coefficients of the calibration
%       curve (i.e., iCF(1) = constant term, iCF(2) = linear term, iCF(3) =
%       second order term...
%
%   Other functions called:
%       NONE
%
%   Example:
%       >> hCF = instrCalib('hydrometer');
%
%   See also lvdtCalib.

blu = [0 0 0.62];

if strcmp(instrument, 'hydrometer') || strcmp(instrument, 'pyncometer');

    data = dlmread([instrument, '.txt'], '\t', 1,0);    % import instrument calibration data
    T = data(2:end,1);                                  % temp is the first column (deg. C)
    y = data(2:end,2);                                  % pyncometer + H2O mass is the second column (g)

    x_hat1 = lsq_linFit(T,y,1);                         % linear fit
    x_hat2 = lsq_linFit(T,y,2);                         % quadratic fit

    T_ = (5:1:40)';                                         % temp. vector
    y1 = x_hat1(1)*T_.^0 + x_hat1(2) * T_;                  % linear estimation
    y2 = x_hat2(1)*T_.^0 + x_hat2(2)*T_ + x_hat2(3)*T_.^2;  % quad. estimation

    y_hat1 = x_hat1(1)*T.^0 + x_hat1(2) * T;                % linear estimation at measured temperatures
    y_hat2 = x_hat2(1)*T.^0 + x_hat2(2)*T + x_hat2(3)*T.^2; % quad. estimation at measured temperatures

    R1 = corr(y,y_hat1)^2;
    R2 = corr(y,y_hat2)^2;

    if R1 > R2
        R = R1;
        xhat = x_hat1;
    else
        R = R2;
        xhat = x_hat2;
    end


    figure
    hold on
    h1 = plot(T,y,'ko');
    h2 = plot(T_,y1,'b--');
    h3 = plot(T_,y2,'g-');
    legend('Data', 'Linear Best-Fit', 'Quadratic Best-fit')
    xlabel('Temperature (^{o}C)')

    if strcmp(instrument, 'hydrometer')
        ylabel('Hydrometer Reading')
        text(11, -1.5, ['$R^2$ = ', num2str(R, '%0.5f')], 'FontSize',10)
        axis([5 30 -4 4])

    elseif strcmp(instrument, 'pyncometer')
        ylabel('Pyncometer + H_20 Mass (g)')
        text(22.5, 156.45, ['$R^2$ = ', num2str(R, '%0.5f')], 'FontSize',10)
        axis([20 40 156 157])

    end

    grid on
    hold off

    iCF = xhat;

elseif strcmp(instrument, 'slope_counter')
    data = dlmread([instrument, '.txt'], '\t', 1,0);    % import slope counter calibration data
    S = data(:,1);                                      % slope values
    C = data(:,2);                                      % counter values
    [x_hat St]  = lsq_linFit(S,C,1);                         % linear fit

    S_ = (0:0.001:0.02)';                                   % slope vector
    C1 = x_hat(1)*S_.^0 + x_hat(2) * S_;                  % linear estimation
    C_hat = x_hat(1)*S.^0 + x_hat(2) * S;                % linear estimation at measured slopes
%     R = corr(C,C_hat)^2;

    figure
    hold on
    h1 = plot(S,C,'ko');
    h2 = plot(S_,C1,'b-');
    set(h1, 'MarkerSize', 7)
    set(h2, 'LineWidth', 2, 'Color',blu)
    text(0.0025, 9.9475*10^4, ['$R^2$ = ', num2str(St(4), '%0.4f')], 'FontSize',11)
    text(0.0025, 9.955*10^4, ['$y = ', num2str(x_hat(2), '%0.0f'), 'x + ', num2str(x_hat(1), '%0.0f') ,'$'], 'FontSize', 11)
    text(0.0025, 9.940*10^4, ['$SE = ', num2str(St(3), '%0.3f') ,'$'], 'FontSize', 11)
    legend('Data', 'Best-fit   line', 'Location','NorthEast', 'FontSize', 11)
    set(gca, 'XMinorTick','on', 'YMinorTick','on', 'TickDir','out', 'FontSize', 11)
%     set(gca, 'YTickLabel', [99200 99300 99400 99500 99600 99700 99800 99000 10000])
    xlabel('Slope', 'FontSize', 11)
    ylabel('Slope Counter', 'FontSize', 11)
    grid on
    box on
    hold off

    %     exFig(gcf, 'fig_calib_slope', 4, 4)
    exFig(gcf, 'fig_calib_slope', 5, 3)


elseif strcmp(instrument, 'pump')
    data1 = dlmread('pump_weighed.txt', '\t', 1,0);     % import weigh tank flow data
    data2 = dlmread('pump_mag.txt', '\t', 1,0);         % import magnetometer flow data

    % manometer deflections (inches)
    dh1 = data1(:,1);   % weigh tank
    dh2 = data2(:,1);   % magnetometer
    dh  = [dh1; dh2];   % both for best-fit curve

    % flow rates (cfs)
    Q1 = data1(:,2);    % weigh tank
    Q2 = data2(:,2);    % magnetometer
    Q = [Q1; Q2];       % both for best-fit curve

    % fit a power-curve to the composite data sets
    [a b] = lsq_powerFit(dh, Q);

    % estimatae flow rate from beste-fit
    Q_hat = a * dh.^b;
    R = corr(Q,Q_hat)^2;


    % plotting
    figure
    hold on
    h1 = plot(dh1,Q1,'ko');
    h2 = plot(dh2,Q2,'ks');
    h3 = plot(dh,Q_hat,'b-');
    set(h1, 'MarkerSize', 7)
    set(h2, 'MarkerSize', 7)
    set(h3, 'LineWidth', 2, 'Color',blu)
    axis([0.1 100 0.1 10])
    set(gca, 'Xscale','log', 'YScale','log', 'FontSize', 11, ...
        'XminorTick','on', 'YMinorTick','on', 'TickDir','out',...
        'XTickLabel', [0.1 1.0 10 100], 'YTickLabel', [0.1 1.0 10])
    legend('Q, weighed', 'Q,   magmeter', 'Best-Fit', 'location','SouthEast', 'FontSize', 11)
    text(0.15, 2.05, ['$Q = (', num2str(a,'%0.4f'), '\pm 0.0003)\,  \Delta h^{1/2}$'], 'FontSize', 11)
    text(0.15, 1.5, ['$R^2 = ', num2str(R,'%0.5f'), '$'], 'FontSize', 11)
    text(0.15, 1.12, '$SE$ = 0.0057 cfs', 'FontSize', 11)
    box on
    grid on
    xlabel('Manometer Deflection, $\Delta h$ (in)', 'FontSize', 11)
    ylabel('Flow Rate, $Q$ (cfs)', 'FontSize', 11)
    hold off
    exFig(gcf, 'fig_calib_pump', 5, 3)


end

