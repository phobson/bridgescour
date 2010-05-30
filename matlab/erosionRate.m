function tau_crit = erosionRate(base_filename, index, tau, rho_d, V2mm)
% CALCULATE THE EROSION RATE AS A FUNCTION OF BED SHEER STRESS OF A SOIL
% SAMPLE
% This function performs an analysis of flume erosion data acquired by the
% erosion_daq.vi LabVIEW file.
%
% The following steps are carried out:
%   1) the data (voltage, time, displacement) from all files are read and
%       stored in a cell array (nested matrix).
%   2) the displacement of the piston is plotted for each test.
%   3) a least-squares regression is performed to fit a line to describe
%       the piston's displacement with time.  The slope of this line is the
%       erosion rate.
%   4) The erosion rates are plotted as a function of the shear stress at
%       the bed (tau) and another line is fit to that curve.  The
%       X-intercept of this line is the critical shear stress (tau_c) of
%       the sediment and the primary quantity saught by this analysis
%
% Inputs:
%   base_filename - input string to give the basic filenames to be read.
%       example: MeriCo_sampleB_1.txt, MeriCo_sampleB_2.txt, etc would have
%       the following:  base_filename  = 'MeriCo_sampleB_'.
%   index - since data acquisition begins slightly before the test and ends
%       shortly afterwards, this is an Nx2 matrix where N is the number of
%       files to be read.  The first column is the index at which the test
%       actually began and the second column where it ended, as determined
%       and noted by the investigator in the lab notebook.  Since the
%       output data files have the sampling frequency as the first record,
%       these values should be the actual index of the data points as found
%       in the raw data output file.  Example: If the test actually started
%       on the 7th acquired reading fo the following data:
%           Index       Value
%           1           10.0
%           2           2.5
%           3           2.4
%           4           2.6
%           5           2.5
%           6           2.4
%           7           2.6
%           8           2.8
%           9           2.3
%           10          2.2
%
%           The index and value would be 8 and 2.8 since at the index of 1,
%           the value of 10.0 is the sampling frequency, not a data point.
%   tau - this is the bed shear stress used during all of the test.  An Nx1
%       column vector input in kilopascals (kPa).
%   rho_b - this is the dry density of the soil as determined by the
%       geotechnical analysis of the soil that follows the erosion test.
%   V2mm - the cable-pull potentiometer linear calibration curve coefficients
%
% Outputs:
%   tau_crit - this is the critical sheer stress (Pa) at which a soil will
%       begin to erode as determined by in the tilting flume of Hydraulics
%       Lab at the Georgia Tech Sschool of Civil and Environmental
%       Engineering
%
%
% Example:
%   >> [L, Vol] = extrustionSize(1, d, [300, 500], Ax);
%   >> [rho_b, rho_d] = soilDensities(404.15, 102.25, 0.41, Vol);
%   >> tau = [3.59; 5.61; 10.29];
%   >> index = [5 500; 6 450; 20 1200];
%   >> t_c = erosionRate('2A_', index, rho_d, V2mm);
%
%   See also extrusionSize, soilDensities, readVoltage, lsq_linFit.



% Constants
dia = 76.2/1000;            % m - diameter of Shelby tube
Ax = pi/4 * dia^2;          % m^2 - x-sectional area of Shelby tube
N = length(tau);            % number of files to read, shear stresses, etc

% Initialize matrices and cell arrays
d_dot = zeros(N,1);         % initialize mass-erosion rate storage matrix


% Loop to go through all output data files, trim excess data
[t, d] = readVoltage(N, base_filename, V2mm);

for n = 1:N
    % indices of actually test data
    in1 = index(n,1);           % start of test
    in2 = index(n,2);           % end of test

    t{n} = t{n}(in1:in2);       % trimmed time vector
    t{n} = t{n} - min(t{n});    % time vector rezeroed
    d{n} = d{n}(in1:in2);       % trimmed displacement vector

    x_hat = lsq_linFit(t{n}, d{n}, 1);  % linear fit of piston displacement
    d_dot(n) = x_hat(2);        % linear erosion rate


end

m_dot = d_dot * Ax * rho_d;


% Critical shear stress (CSS) calculations
x_hatCSS = lsq_linFit(tau, m_dot, 1);   % linear regression on tau/erosion rate data
y_hat = x_hatCSS * tau;                 % estimated erosions rates from best-fit
tau_crit = x_hatCSS(1);                 % critical shear stress


% plotting
figure
plot(tau, m_dot,'k.', tau, y_hat,'b-')
xlabel('Erosion Rate (kg/s)')
ylabel('Bed Shear Stress (Pa)')
legend('data', 'best-fit line')
text(50, 0.05, ['\tau_c = ', num2str(x_hatCSS(1)), ' Pa'], 'FontSize', 10)
