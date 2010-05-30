function [LL, PL, PI] = atterbergLimits(sname, wcs, varargin)
% ATTERBERG LIMITS OF A SOIL SAMPLE
% 	This function determines the Atterberg Limits -- Liquid Limit (LL),
%   Plastic Limit (PL), and Plasticity Index (PI) of a soil sample.
%
%   Inputs:
%       sname - Sample name.  This is the name of the sample whose AL's
%           need to be determined.  It should be a string in the form, '1A',
%           '2C', '3B', etc.
%       wcs - Water content data structure.  This should be a data data
%           structure of the water content data of the samples.  Data structure
%           should have at least the following fields:
%             .name  - name of the sample (1A, 2C, etc)
%             .type  - type of test (LL or PL)
%             .Mp    - mass of the pan (see waterContent.m)
%             .Mps   - mass of the pan and soil (see waterContent.m)
%             .Mpsw  - mass of the pan, soil, and water (see waterContent.m)
%             .blows - values for Casagrande Cup test
%             .pen   - penetration (mm) values for Fall Cone test
%       Other options:
%           Two more inputs can be added after sname and wcs.  A string
%           value of 'plot' can be included to produce a plot of the liquid
%           limit data.  Additionally, a second string can be used as a
%           filename.  Plot will be exported using LaPrint.m for inclusion
%           in a LaTeX document.
%
%   Outputs:
%       LL - Liquid Limit
%       PL - Plastic Limit
%       PI - Plasticity Index
%
%   Other functions called:
%       queryStruct.m - looks for LL and PL data in the input data
%           structure that correspond the the sample name specified.
%       waterContent.m - determines the water content of a sample using
%           data acquired with queryStruct.m.
%       lsq_logFit.m - performs a straight-line fitting proceedure to data
%           where the blows or penetration (mm) are plotted on a log. scale
%           on the x-axis and the water contents are plotted arithmetically
%           on the y-axis
%
%   Example:
%       [LL_1A, PL_1A, PI_1A] = atterbergLimits('1A', WCS, 'plot', 'fig_1ALL');
%
%   See also queryStruct, waterContent, lsq_logFit.


% Liquid Limit Determination
inLL = queryStruct(wcs, 'name',sname, 'type','LL');     % index of LL samples
blows = [wcs(inLL).blows]';                             % blow count
pen = [wcs(inLL).pen]';                                 % penetration (mm)

wcLL = waterContent(inLL, wcs);                         % determine WC of each sample

if ~isempty(blows)                                      % blows is not null => Casagrande test
    x = blows;
    xx = 25;                                            % number of blows at LL per ASTM
    x_hat = lsq_logFit(blows, wcLL, 1);                 % determine best-fit line of data
    LL = (x_hat(1) + log10(25) * x_hat(2)) * 100;       % LL is WC at 25 blows
    P = 10:1:35;                                        % x-variable for best-fit line
    LegLoc = 'SouthWest';                               % legend location for plots
    xlab = 'Number of blows';                           % x-axis label

elseif ~isempty(pen);                                   % pen is not null => Fallcone test
    x = pen;
    xx = 20;                                            % amount of penetration at LL per BS
    x_hat = lsq_logFit(pen, wcLL, 1);                   % determine best-fit line of data
    LL = (x_hat(1) + log10(20) * x_hat(2)) * 100;       % LL is the WC at 20 mm of penetration
    P = 10:1:30;                                        % x-variable for best-fit line
    LegLoc = 'SouthEast';                               % legend location for plots
    xlab = 'Penetration, mm';                           % x-axis label
end
w = (x_hat(1) + log10(P)*x_hat(2))*100;                 % best-fit line


% Plastic Limit Determination
inPL = queryStruct(wcs, 'name',sname, 'type','PL');      % index of PL samples
wcPL = waterContent(inPL, wcs);                          % determine WC of each sample
PL = mean(wcPL) * 100;                                   % PL is average WC

% Plasticity Index
PI = LL - PL;

% plotting
if ~isempty(varargin)
    if strcmp(varargin{1}, 'plot')
        if length(varargin) == 1
            figure
            hold on
            h1 = plot(x,wcLL*100,'ko');
            h2 = plot(P,w,'b-');
            set(h1, 'MarkerSize', 7)
            set(h2, 'LineWidth', 2)
            legend('Data', 'Best-Fit Line', 'location',LegLoc)
            h3 = plot(xx,LL, 'kp');
            set(h3, 'MarkerSize',10, 'MarkerFaceColor','k')
            xlabel(xlab)
            ylabel('Water Content, %')
            text(xx+1,LL, ['Liquid Limit = ', num2str((LL), '%0.1f')])
            set(gca, 'TickDir','out', 'XScale','log', 'Xlim',[10 50])
            set(gca, 'XMinorTick','on', 'YMinorTick','on', 'TickDir','out')
            box on
            grid on
            hold off
        elseif length(varargin) == 2
            figure
            hold on
            filename = varargin{2};
            h1 = plot(x,wcLL*100,'ko');
            h2 = plot(P,w,'b-');
            set(h1, 'MarkerSize', 7)
            set(h2, 'LineWidth', 2)
            legend('Data', 'Best-Fit Line','location',LegLoc)
            h3 = plot(xx,LL, 'kp');
            set(h3, 'MarkerSize',10, 'MarkerFaceColor','k')
            xlabel(xlab)
            ylabel('Water Content, \%')
            text(xx+0.2,LL, ['$\leftarrow$ Liquid Limit = ', num2str((LL), '%0.1f')], 'FontSize', 10)
            set(gca, 'TickDir','out', 'XScale','log', 'Xlim',[10 50])
            set(gca, 'XMinorTick','on', 'YMinorTick','on', 'TickDir','out')
            box on
            grid on
            % export the figure
            exFig(gcf, filename, 3.5, 3.5)
            hold off
        end
    end
end