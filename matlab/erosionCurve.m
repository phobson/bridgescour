function [tau_c, const, x, y] = erosionCurve(sname, snum, fsd, varargin)
% FIT A REGRESSION TO EROSION RATE/SHEAR STRESS DATA
%   This function takes a sample name and sample number and plots the
%   erosion rate versus the shear stress.  A user-specified curve is fit to
%   the data and the critical shear stress, erosion rate constant, and
%   least-squares estimation of the data are output.
% Inputs
%   sname - this is the name of the sample, string
%   snum  - this is the number of the sample, string
%   fsd   - this is the final sample data structure that contains the
%       following fields:
%           fsd.tau  - bed shear stress (Pa)
%           fsd.LER  - linear erosion rate (mm/s)
%           fsd.rhod - dry density of the soil (km/m^3)
%           fsd.type - type of erosion curve ('Linear' or 'Exponential')
%   Plotting options:
%       After all of the required inputs have been entered, the user may
%       specify 'plot' for the function to create at plot of the data and
%       the best-fit curve.  Additionally specifying an file name will use
%       Laprint.m to export the figure for inclusion in a LaTeX document.
%
% Outputs
%   tau_c  - the critical shear stress (Pa).  For linear and piece-wise
%       linear fits, this is where the best-fit curve intersects the
%       x-axis (ER = 0).  For exponential fits, this is where the estimated
%       erosion rate is E_c = 0.00190 km/m^2/s per Ricardo Navarro's
%       master's thesis under Dr. Terry Sturm.
%
% Examples
%   >> [tau_c, const, x, y] = erosionCurve('2B', '2', FSD, 'exp')
%   >> [tau_c, const, x, y] = erosionCurve('1C', '1', FSD, 'lin', 'plot')
%   >> [tau_c, const, x, y] = erosionCurve('2A', '1', fsd, 'pwl', 2, 'plot', 'fig_2A_erosion')
%
%   See also queryStruct, lsq_linFit, lsq_pwlFit, lsq_expFit, exFig.


% legend placement, few examples specific to my data
if strcmp(sname, '2A') || strcmp(sname,'4B')
    loc = 'NorthEast';
else
    loc = 'NorthWest';
end



N = queryStruct(fsd, 'name',sname, 'num',snum); % query out sample data
tau = fsd(N).tau;                               % shear stress (Pa)
LER = fsd(N).LER;                               % linear erosion rate (mm/s)
type = fsd(N).type;

x = linspace(0,21.5);                           % x-vector for esimation

for n = 1:length(tau)
ER{n} = [LER{n}] * fsd(N).rhod / 1000;          % mass erosion rate (kg/m^2/s)
    
        % Linear Fits
    if strcmp(type, 'Linear');
        x_hat = lsq_linFit(tau{n}, ER{n}, 1);   % execute the fit
        m{n} = x_hat(2);                        % slope of line
        b{n} = x_hat(1);                        % y-intercept of line
        y{n} = m{n}*x + b{n};                   % least-squares estimation
        tau_c{n} = -b{n}/m{n};                  % critical shear stres (Pa)
        const{n} = m{n} * tau_c{n};             % erosion rate constant


        % Exponential Fit
    elseif strcmp(type, 'Exponential');
        [A{n} b{n}] = lsq_expFit(tau{n}, ER{n});    % execute the fit
        y{n} = A{n} * exp(x.*b{n});                 % least-square estimation
        E_c = 0.0019;                               % Ricardo's critical erosion rate
        tau_c{n} = log(E_c/A{n})/b{n};              % critical shear stress (Pa);
        a{n} = b{n} * (x - tau_c{n})/((x/tau_c{n}) - 1);
        const{n} = a{n};                            % erosion-rate constant


        % Piece-wise Linear
    elseif strcmp(type, 'Piece-wise linear');
        bp = varargin{1};
        [x_hat, int] = lsq_pwlFit(tau{n}, ER{n}, bp);
        m = [x_hat{1}(2); x_hat{2}(2)];             % slopes of both fits
        b = [x_hat{1}(1); x_hat{2}(1)];             % intercepts of both fits

        x1 = linspace(1,int, 20);                   % x-vector, first fit
        y1 = m(1)*x1 + b(1);                        % estimation, first fit

        x2 = linspace(int,21,20);                   % x-vector, second fit
        y2 = m(2)*x2 + b(2);                        % estimation, second fit

        % combine estimations
        x = [x1'; x2'];
        y = [y1'; y2'];
        tau_c = -b(1)/m(1);                         % critical shear stres (Pa)
        const = m * tau_c;

    end

dots = {'o' 's'};
lines = {'-', '--'};
colors = {'k', 'b'};

    % plotting
    if length(varargin) >= 1 && (strcmp(type, 'Linear') || strcmp(type, 'Exponential'))
        figure
        hold on
        h1{n} = plot(tau{n}, ER{n}, [colors{n} dots{n}]);              % plot data
        h2{n} = plot(x, y{n}, [colors{n} lines{n}]);                  % plot estimation
        set(h1{n}, 'MarkerSize', 7);               % edit data marker
        set(h2{n}, 'LineWidth', 2);                % edit est. line
        axis([0 22 0 10])
        xlabel('Bed Shear Stress, $\tau$ (Pa)')
        ylabel('Erosion Rate, E (kg/m\ssu{2}/s')
        legend('Erosion data', [type ' best-fit'], 'Location', loc)
        box on
        grid on
        hold off

        % export plot
        if length(varargin) == 2
            fname = varargin{2};
%             exFig(gcf, fname, 6, 4);
        exFig(gcf, fname, 5, 3);
        end

    elseif length(varargin) >= 2 && (strcmp(type, 'Piece-wise linear'))
        figure
        hold on
        h1 = plot(tau{n}, ER{n}, 'ko');              % plot data
        h2 = plot(x, y, 'b-');                  % plot estimation
        set(h1, 'MarkerSize', 7);               % edit data marker
        set(h2, 'LineWidth', 2);                % edit est. line
        axis([0 22 0 10])
        xlabel('Bed Shear Stress, $\tau$ (Pa)')
        ylabel('Erosion Rate, E (kg/m\ssu{2}/s')
        legend('Erosion data', [type ' best-fit'], 'Location', loc)
        box on
        grid on
        hold off

        % export plot
        if length(varargin) == 3
            fname = varargin{3};
%             exFig(gcf, fname, 6, 4);
        exFig(gcf, fname, 5, 3);
        end
    end

end