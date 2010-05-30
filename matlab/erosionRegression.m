function [reg_data, reg_stats] = erosionRegression(sname, snum, fsd, varargin)
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
%   Plotting options:
%       After all of the required inputs have been enter, the user may
%       specify 'plot' for the function to create at plot of the data and
%       the best-fit curve.  Additionally specifying an file name will use
%       Laprint.m to export the figure for inclusion in a LaTeX document.
%
% Outputs
%   reg_data - regression data generated.  Output as a cell with the form:
%       {[lin_data1] [exp_data1] [pwl_data1];
%       [lin_data2] [exp_data2] [pwl_data2];
%           ...          ...         ...
%       [lin_dataN] [exp_dataN] [pwl_dataN]};
%           where each element is a 100x2 matrix of x and y estimates from
%           the regressions and N is the number of erosion datasets 
%           associated with the sample.  Only sample 2A is fit to a 
%           piece-wise linear curve.  All other sample get only linear and
%           exponential fits.
%   reg_stats - statistics describing the fits.  Output as a cell with the
%   form:
%       {[lin_stat1] [exp_stat1] [pwl_stat1];
%       [lin_stat2] [exp_stat2] [pwl_stat2];
%           ...          ...         ...
%       [lin_statN] [exp_statN] [pwl_statN]};
%           where each element is a 2x22 matric with the form:
%               [erosion rate const         std. error of ERC;
%                critical shear stress      std. error of tau_c
%                R^2 of fit                 R^2 of fit         ];
%
%
% Examples
%   >> [reg_data, reg_stats] = erosionRegression('2B', '2', FSD)
%   >> [reg_data, reg_stats] = erosionRegression('1C', '1', FSD 'plot')
%   >> [reg_data, reg_stats] = erosionRegression('2A', '1', FSD, 'plot', 'fig_2A_erosion')
%
%   See also queryStruct, lsq_linFit, lsq_pwlFit, lsq_expFit, exFig.


% legend placement
if strcmp(sname, '2A') || strcmp(sname,'4B')
    loc = 'NorthEast';
else
    loc = 'NorthWest';
end



N = queryStruct(fsd, 'name',sname, 'num',snum); % query out sample data
tau = fsd(N).tau;                               % shear stress (Pa)
LER = fsd(N).LER;                        % linear erosion rate (mm/s to m/s)
type = fsd(N).type;

x = linspace(0,22);                           % x-vector for esimation
x = x';

for n = 1:length(tau)
    ER = [LER{n}] * fsd(N).rhod / 1000;         % mass erosion rate (kg/m^2/s)
    
        % Linear Fit
    [x_hat seL] = lsq_linFit(tau{n}, ER, 1);    % execute the fit
    m = x_hat(2);                               % slope of line
    b = x_hat(1);                               % y-intercept of line
    y = m*x + b;                                % least-squares estimation
    tcL = -b/m;                                 % critical shear stres (Pa)
    M = m * tcL;                                % erosion rate constant
    se_tc = sqrt(seL(1)^2 + seL(2)^2);          % standard error

    
    Y = m*tau{n} + b;                           % estimation of ER at tau
    SSR = sum( (Y - mean(ER)).^2 );
    SST = sum( (ER - mean(ER)).^2 );
    CoD = SSR/SST;                              % coefficient of determination (R-squared)
    
    reg_data{n,1} = [x,y];                      % output estimatations
    reg_stats{n,1} = [M, seL(1);                % output regression parameters and stats
                    tcL, se_tc;
                    CoD, CoD];           
    
        % Exponential Fit
    [A b seX1] = lsq_expFit(tau{n}, ER);        % execute the first fit
    y = A * exp(x.*b);                          % least-square estimation
    y1 = A * exp(tau{n}.*b);                    % least-square estimation
    E_c = 0.0019;                               % Ricardo's critical erosion rate
    tcX = log(E_c/A)/b;                         % critical shear stress (Pa);
    se_tc = sqrt(seX1(1)^2 + seX1(2))^2;        % propagation of error to tau_c
    X = (tau{n} - tcX)/tcX;                     % excess shear stress
    [c a seX2] = lsq_expFit(X,ER);              % refit the curve based on excess tau
    
    Y = A*exp(tau{n} * b);                      % estimation of ER at tau
    SSR = sum( (Y - mean(ER)).^2 );
    SST = sum( (ER - mean(ER)).^2 );
    CoD = SSR/SST;                              % coefficient of determination (R-squared)

    
    reg_data{n,2} = [x,y];                      % output estimations
    reg_stats{n,2} = [a, seX2(2);               % output regression parameters and stats
                      tcX, se_tc;
                      CoD, CoD];


    % Piece-wise Linear (for Sample 2A only, break point at n = 2)
    if strcmp(sname, '2A');
        bp = 2;                                     % define break point                                
        [x_hat, int, seP] = lsq_pwlFit(tau{n}, ER, bp);
        m = [x_hat{1}(2); x_hat{2}(2)];             % slopes of both fits
        b = [x_hat{1}(1); x_hat{2}(1)];             % intercepts of both fits
        x1 = linspace(1,int, 50);                   % x-vector, first fit
        y1 = m(1)*x1 + b(1);                        % estimation, first fit
        x2 = linspace(int,22,20);                   % x-vector, second fit
        y2 = m(2)*x2 + b(2);                        % estimation, second fit
        x = [x1'; x2'];                             % combine estimations, x
        y = [y1'; y2'];                             % combine estimations, y
        tcP = -b(1)/m(1);                           % critical shear stres (Pa)
        M = m * tcP;                                % erosion rate constant

        
        Y1 = b(1) + tau{n}(1) * m(1);
        Y2 = b(2) + tau{n}(2:end) * m(2);
        Y = [Y1; Y2];
        SSR = sum( (Y - mean(ER)).^2 );
        SST = sum( (ER - mean(ER)).^2 );
        CoD = SSR/SST;                              % coefficient of determination (R-squared)
        
        reg_data{n,3} = [x,y];                      % output estimations
        reg_stats{n,3} = [M(1), seP(1);
                           tcP, seP(2);
                           CoD, CoD];                % output regression parameters and stats
    end

end