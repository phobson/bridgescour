function SG = specGrav(sname, snum, SGD, pCF)
% SPECIFIC GRAVITY OF SOILS
%   This function calculates the specific gravity of a sample that whos 
%   data is in a structure with the following fields and units:
%       .name       % Sample name
%       .Mp         % Mass of evaporating pan, g
%       .Mps        % Mass of evaporating pan + soil, g
%       .Mpyn       % Mass of dry pyncometer, g
%       .Mtot       % Mass of soil + water + pyncometer, g
%       .temp       % Temperature of water in pyncometer, deg. C
%
%   Inputs:
%       sname - name of sample, case-sensitive string
%       snum  - number of sample, case-sensitive string
%       SGD   - data structure of specific gravity data
%       pCF   - pyncometer calibration factors (quadratic fit)
%
%   Output:
%       SG - specific gravity of soil grains
%
%   Other functions called:
%       queryStruct.m - gets index of a sample in a data structure
%
%   Example:
%       >> SG_1A = specGrav('1A', '1', SGD, pCF);
%
%   See also queryStruct.


ii = queryStruct(SGD, 'name',sname, 'num',snum);      % index of SG data

T = [SGD(ii).temp]';            % Temperature of water in pyncometer, deg. C
Mp = [SGD(ii).Mp]';             % Mass of evaporating pan, g
Mps = [SGD(ii).Mps]';           % Mass of evaporating pan + soil, g



% Mpyn = [SGD(ii).Mpyn]';         % Mass of dry pyncometer, g
M1 = [SGD(ii).Mtot]';           % Mass of soil + water + pyncometer, g

Ms = Mps - Mp;                  % Mass of soil, g

% Mass of pyncometer + water from calibration curve, g
M2 = pCF(1) * T.^0 + pCF(2) * T.^1 + pCF(3) * T.^2;

% Determine the specific gravity of a soil
SG = Ms / (Ms - M1 + M2);
