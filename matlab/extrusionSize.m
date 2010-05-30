function [L, vol, num] = extrusionSize(sname, xtype, Ax, pdr)
% LENGTH AND VOLUME OF SOIL EXTRUSIONS FROM A STANDARD SHELBY TUBE
%   This function determines the length and volume of a sample of soil
%   extruded from the flume.
%
%   Inputs:
%       sname - sample name (Shelby tube number
%       xtype - extrusion type (geotech, erosion extrusion)
%       Ax    - cross-sectional area of the extrusion.  This is loaded with
%           startup.m; should be in mm^2
%       pdr   - potentiometer data structure
%
%   Outputs:
%       vol - vector of volumes of extrusion (mm^3)
%       num - cell arrary of extrusion numbers (i.e., x1, x2,...,xN)
%
%   Other functions called:
%       queryStruct.m
%
%   Examples:
%       [vol, num] = extusionSize('3B', 'erosion extrusion', Ax, PDR)
%
%   See also readVoltage, soilDensities, querySstruct.



% get index of sample 
ii = queryStruct(pdr, 'name',sname, 'type',xtype);

disp = {pdr(ii).disp};      % displacement data of sample
index = {pdr(ii).ExIn};     % index of data before/after extrusion
num = {pdr(ii).num};        % extrusion number

N = length(index);          % number of data sets

L = zeros(N,1);             % initialize length vector
vol = zeros(N,1);           % initialize volume vector


% loop through all the queried data
for n = 1:N
    d = disp{n};                % read this displacement
    in = index{n};              % this index 
    d_i = mean(d(1:in(1)));     % avg. dist. reading from t=0 to just before extrusion starts
    d_f = mean(d(in(2):end));   % avg. dist. from end of extrusion to end of data record

    L(n) = d_f - d_i;           % mm - length of extruded sample
    vol(n) = Ax * L(n);         % mm^3 - volume of extruded samples
end