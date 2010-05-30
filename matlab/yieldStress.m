function [ty1 ty2 wc] = yieldStress(sname, snum, ysd, varargin)
% DETERMINE THE YIELD STRESS OF A SOIL SLURRY FROM RHEOMETER DATA
%   This function takes stress/strain data from a rheometer and determines
%   the yield stress (Pa) of the sample.
%
% Inputs:
%   sname - name of the sample, string
%   snum  - number of the test, string
%   ysd   - data structure containing the following fields:
%       ysd.Mc   - mass of the rheometer cup (g)
%       ysd.Mcsw - mass of the cup + soil + water (g)
%       ysd.Mp   - mass of the evaporating pan (g)
%       ysd.Mps  - mass of the pan + dry soil (g)
%       ysd.gam  - strain data of rheometer test
%       ysd.tau  - stress data of rheometer test (Pa)
%       ysd.eta  - vicosity of rheometer test (cP)
%       ysd.inA  - this is 2x1 or 1x2 vector on the indices of the 1st fit
%       ysd.inB  - this is 2x1 or 1x2 vector on the indices of the 2nd fit
%       ysd.ax   - this is 4x1 vector that determine the axis limits of the
%           plot per the built-in MATLAB function axis.m
%   Plotting options:
%       After the required inputs are specified, 'plot' can be specified to
%       have the function create a plot of the data and the best-fit
%       curves.  If a 'export' is specified after 'plot', the figure will
%       be exported using Laprint.m  for inclusion in a LaTeX document.
%
% Outputs:
%   ty1 - yields stress of the sample (Pa)
%   wc    - water content of the sample
%
% Examples:
%   >> [ty1 wc] = yieldStress('3A', '1', YSD, 'plot');
%   >> [ty1 wc] = yieldStress('3A', '2', YSD, 'plot', 'fig_3Ays_2');
%
%   See also lsq_powerFit, queryStruct, exFig, axis.



n = queryStruct(ysd, 'name',sname, 'num',snum);


% calculat water content of soil in rheometer cup
Mc = ysd(n).Mc;         % mass of rheometer cup (g)
Mcsw = ysd(n).Mcsw;     % mass of cup + soil + water (g)
Mp = ysd(n).Mp;         % mass of evaporating pan (g)
Mps = ysd(n).Mps;       % mass of pan + soil (g)

Ms = Mps - Mp;          % mass of soil (g)
Msw = Mcsw - Mc;        % mass of soil + water (g)
Mw = Msw - Ms;          % mass of water (g)
wc = Mw/Ms;             % water content of soil in rheometer cup [OUTPUT]

% define stress/strain
gam = ysd(n).gam;       % strain (dimensionless)
gmd = ysd(n).gmd;       % srain rate (1/s)
tau = ysd(n).tau;       % shear stress (Pa)


% axis stuff
ax1 = ysd(n).ax(1,:);            % read axis limits from ysd
ax2 = ysd(n).ax(2,:);
xN = log10(ax1(2)/ax1(1)) + 1;    % number of x-axis ticks
yN = log10(ax1(4)/ax1(3)) + 1;    % number of y-axis ticks


% % take log of data
% lnTau = log(tau);
% lnGam = log(gam);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YIELS STRESS ONE
% define indicies for curve fitting
if isempty(ysd(n).inA)
    ty1 = 0;
else
    inA = ysd(n).inA(:,:);       % indices for lower fit



    [a b] = lsq_powerFit(tau(inA(1,1):inA(1,2)), gam(inA(1,1):inA(1,2)));
    [c d] = lsq_powerFit(tau(inA(2,1):inA(2,2)), gam(inA(2,1):inA(2,2)));

    % define x-axis for calculating fits
    x = logspace(-2,2);
    y1 = a * x.^b;
    y2 = c * x.^d;

    % calculate the yield stress and yield strain
    ty1 = exp(log(c/a)/(b-d));               % yield stress (Pa) [OUTPUT]
    gy1 = a * ty1.^b;   % yield strain

    % plotting
    if length(varargin) == 1
        set(0, 'defaulttextinterpreter', 'tex')
        % plotting
        figure
        clf
        hold on

        % plot data
        h1 = loglog(tau,gam,'ko');
        set(h1, 'MarkerFaceColor','k', 'MarkerSize', 2)

        % circle data points selected for lower fit
        h2 = loglog(tau(inA(1,1):inA(1,2)),gam(inA(1,1):inA(1,2)),'bo');
        set(h2, 'MarkerSize', 7)

        % plot lower fit
        h3 = loglog(x,y1,'b-');
        set(h3, 'LineWidth', 1)

        % circle data points selected for upper fit
        h4 = loglog(tau(inA(2,1):inA(2,2)),gam(inA(2,1):inA(2,2)),'go');
        set(h4, 'MarkerSize', 7)

        % plot upper fit
        h5 = loglog(x,y2,'g-');
        set(h5, 'LineWidth', 1)

        % highlight yield stress point
        h6 = loglog(ty1, gy1, 'kp');
        set(h6, 'MarkerFaceColor', 'r', 'MarkerSize',10)

        % tweak the figure
        axis(ax1)
        grid on

        set(gca, 'YScale','log', 'XScale','log', 'TickDir','out')
        set(gca, 'XTick', logspace(log10(ax(1)), log10(ax(2)), xN))
        set(gca, 'YTick', logspace(log10(ax(3)), log10(ax(4)), yN))
        set(gca, 'YMinorGrid', 'off')
        set(gca, 'XMinorGrid', 'off')
        set(gca, 'FontSize', 11)

        xlabel('Shear Stress, \tau (Pa)', 'FontSize',11)
        ylabel('Strain, \gamma', 'FontSize',11)
        text(ty1 + 2, gy1, ['\tau_y = ', num2str(ty1, '%0.2f'), ' Pa'], 'FontSize',11)
        hold off

    elseif length(varargin) == 2
        set(0, 'defaulttextinterpreter', 'none')
        filename = ['fig_' sname 'ys1_' snum];
        % plotting
        figure
        clf
        hold on

        % plot data
        h1 = loglog(tau,gam,'ko');
        set(h1, 'MarkerFaceColor','k', 'MarkerSize', 2)

        % plot lower fit
        h3 = loglog(x,y1,'k-');
        set(h3, 'LineWidth', 1)

        % plot upper fit
        h5 = loglog(x,y2,'k-');
        set(h5, 'LineWidth', 1)

        % highlight yield stress point
        h6 = loglog(ty1, gy1, 'kp');
        set(h6, 'MarkerFaceColor', 'r', 'MarkerSize',10)

        %     legend('Data', 'Lower Power Fit', 'Upper Power Fit',...
        %         ['$\tau_y$ = ', num2str(ty1, '%0.2f'), ' Pa'], ...
        %         'Location', 'NorthWest');

        legend([h1; h3; h6], {'Data', 'Power Fits', ...
            ['ty1 = ', num2str(ty1, '%0.2f'), ' Pa at w = ',...
            num2str(wc*100, '%0.0f'),'\%']}, 'Location','SouthEast',...
            'FontSize',11);





        % tweak the figure
        axis(ax1)
        set(gca, 'YScale','log', 'XScale','log', 'TickDir','out')
        grid on
        set(gca, 'XTick', logspace(log10(ax1(1)), log10(ax1(2)), xN))
        set(gca, 'YTick', logspace(log10(ax1(3)), log10(ax1(4)), yN))
        set(gca, 'YMinorGrid', 'off')
        set(gca, 'XMinorGrid', 'off')
        set(gca, 'FontSize', 11)
        xlabel('Shear Stress, $\tau$ (Pa)' , 'FontSize',11)
        ylabel('Strain, $\gamma$', 'FontSize',11)
        box on
        hold off

        % export the figure
%             exFig(gcf, filename, 6, 4);
        exFig(gcf, filename, 5.5, 2.75);


    elseif length(varargin) > 2
        error('Too many inputs inputs')
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% YIELD STRESS TWO
% define indicies for curve fitting
if isempty(ysd(n).inB)
    ty2 = 0;
else
    inB = ysd(n).inB(:,:);       % indices for lower fit



    X1 = lsq_linFit(gmd(inB(1,1):inB(1,2)), tau(inB(1,1):inB(1,2)),1);
    X2 = lsq_linFit(gmd(inB(2,1):inB(2,2)), tau(inB(2,1):inB(2,2)),1);
    
    a = X1(1); b = X1(2);
    c = X2(1); d = X2(2);

    % define x-axis for calculating fits
    x1 = logspace(-3,3);
    x2 = linspace(0,max(gmd)+100);
    y1 = a + x1 .* b;
    y2 = c + x2 .* d;

    % calculate the yield stress and yield strain
    gy2 = (a - c)/(d - b);          % yield strain
    ty2 = c + gy2 .* d;      % yield stress (Pa) [OUTPUT]


    % plotting
    if length(varargin) == 1
        set(0, 'defaulttextinterpreter', 'tex')
        % plotting
        figure
        clf
        hold on

        % plot data
        h1 = plot(gmd,tau,'ko');
        set(h1, 'MarkerFaceColor','k', 'MarkerSize', 2)

        % circle data points selected for lower fit
        h2 = plot(gmd(inB(1,1):inB(1,2)),tau(inB(1,1):inB(1,2)),'bo');
        set(h2, 'MarkerSize', 7)

        % plot lower fit
        h3 = plot(x1,y1,'b-');
        set(h3, 'LineWidth', 1)

        % circle data points selected for upper fit
        h4 = plot(gmd(inB(2,1):inB(2,2)),tau(inB(2,1):inB(2,2)),'go');
        set(h4, 'MarkerSize', 7)

        % plot upper fit
        h5 = plot(x2,y2,'g-');
        set(h5, 'LineWidth', 1)

        % highlight yield stress point
        h6 = plot(gy2, ty2, 'kp');
        set(h6, 'MarkerFaceColor', 'r', 'MarkerSize',10)

        % tweak the figure
        axis(ax2)
        grid on

        set(gca, 'TickDir','out')
%         set(gca, 'XTick', logspace(log10(ax(1)), log10(ax(2)), xN))
%         set(gca, 'YTick', logspace(log10(ax(3)), log10(ax(4)), yN))
        set(gca, 'YMinorGrid', 'off')
        set(gca, 'XMinorGrid', 'off')

        ylabel('Shear Stress, \tau (Pa)')
        xlabel('Strain Rate, \dot{\gamma}')
        text(gy2 + 2, ty2, ['\tau_y_2 = ', num2str(ty2, '%0.2f'), ' Pa'])
        hold off

    elseif length(varargin) == 2
        set(0, 'defaulttextinterpreter', 'none')
        filename = ['fig_' sname 'ys2_' snum];
        % plotting
        figure
        clf
        hold on

        % plot data
        h1 = plot(gmd, tau,'ko');
        set(h1, 'MarkerFaceColor','k', 'MarkerSize', 2)

        % plot lower fit
        h3 = plot(x1,y1,'k-');
        set(h3, 'LineWidth', 1)

        % plot upper fit
        h5 = plot(x2,y2,'k-');
        set(h5, 'LineWidth', 1)

        % highlight yield stress point
        h6 = plot(gy2, ty2, 'kp');
        set(h6, 'MarkerFaceColor', 'r', 'MarkerSize',10)

        %     legend('Data', 'Lower Power Fit', 'Upper Power Fit',...
        %         ['$\tau_y$ = ', num2str(ty1, '%0.2f'), ' Pa'], ...
        %         'Location', 'NorthWest');

        legend([h1; h3; h6], {'Data', 'Linear Fits', ...
            ['ty2 = ', num2str(ty2, '%0.2f'), ' Pa at w = ',...
            num2str(wc*100, '%0.0f'),'\%']}, 'Location','SouthEast',...
            'FontSize',11)





        % tweak the figure
        axis(ax2)
        set(gca, 'TickDir','out')
        grid on
        set(gca, 'YMinorGrid', 'off')
        set(gca, 'XMinorGrid', 'off')
        set(gca, 'FontSize', 11)
        ylabel('Shear Stress, $\tau$ (Pa)', 'FontSize', 11)
        xlabel('Strain Rate, $\dot{\gamma}$ (s\ssu{-1})', 'FontSize', 11)
        box on
        hold off

        % export the figure
%             exFig(gcf, filename, 6, 4);
        exFig(gcf, filename, 5.5, 2.75);


    elseif length(varargin) > 2
        error('Too many inputs inputs')
    end
end
