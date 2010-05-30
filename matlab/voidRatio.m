function [e, n] = voidRatio(sname, snum, Ax, wcs, pdr, sgd, pCF)
% sname = '1A';
% snum = '1';
% pdr = PDR;
% wcs =WCS;
% sgd = SGD
% VOID RATIO OF A SOIL SAMPLE
%
%   Inputs:
%       sname - sample name (string)
%       snum  - specific gravity sample number (string)
%       Ax    - Shelby tube cross sectional area (mm^2)
%       wcs   - water content data structure
%       pdr   - potentiometer data structure
%       pCF   - pyncometer calibration curve coefficients (quadratic)
%
%
%   Outputs:
%       e - void ratio
%       n - porosity
%
%   Other functions called
%       queryStruct.m
%       soilDensities.m
%       waterConent.m
%       extrusionSize.m
%
% Example:
% [e, n] = voidRatio('4B', '1', Ax, WCS, PDR, SGD, pCF)
%
%   See also queryStruct, soilDensities, waterConent, extrusionSize.

% index of water content samples
inWC = queryStruct(wcs, 'name',sname, 'type','WC');      

% index of extrusion
inX = queryStruct(wcs, 'name',sname, 'type','extrusion');
% Mexw = wcs(inX).


% WC = waterConent(inWC, wcs);            % water content
Mpsw = [wcs(inX).Mpsw];                  % mass of pan + soil (g)
Mp = [wcs(inWC).Mp];                      % mass of pan (g)

w = waterContent(inWC(1), wcs);
Msw = (Mpsw(1) - Mp(1));

Ms = Msw./(1+w);

[L, Vt, num] = extrusionSize(sname, 'extrusion', Ax, pdr); 
SG = specGrav(sname, snum, sgd, pCF);
rho_w = 10^-3;          % density of water (g/mm^3)
rho_s  = SG * rho_w;    % density of soil grains (g/mm^3);

Vs = Ms/rho_s;
Vv = Vt(1) - Vs;


e = Vv/Vs;
n = e./(1 + e);