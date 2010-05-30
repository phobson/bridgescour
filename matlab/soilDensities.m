function [rho_b, rho_d] = soilDensities(sname, xnum, Ax, pdr, wcs)
% BULK AND DRY DENSITIES OF A SOIL
%   This function determines the bulk and dry densities of a soil
%   specimen.
%
%   Inputs:
%       Mpsw = mass of the Pan, Soil, and pore Water (units: grams)
%       Mp = mass of the Pan (units: grams)
%       wc = the water content of the specimen (units: dimensionless)
%       vol = volume of the speciment as determined with extrusionSize.m
%       in the case of flume extrision or by repeated caliper measurements
%       of a band saw-cut section of tube (units: mm^3)
%
%   Outputs:
%       rho_b = bulk density - water and soil (units: g/mm^3)
%       rho_d = dry density - soil only  (units: g/mm^3)
%
%   Other functions called:
%       NONE
%
%   Example:
%       [rho_b, rho_d] = soilDensities('1A', 'x1', Ax, PDR, WCS)
%
%   See also queryStruct, waterContent, extrusionSize.

if strcmp(sname, '3B');
    L = mean([64.53 64.99 65.77 65.48 64.56]);
    Vol = L * Ax;

    iX = queryStruct(wcs, 'name',sname, 'num','cut_tube');
    Msw = wcs(iX).Mpsw - wcs(iX).Mp;
    
    iWC = queryStruct(wcs, 'name',sname, 'num','1');
    wc = waterContent(iWC, wcs);
    
    rho_b = Msw/Vol;        % bulk density of tube cut
    rho_d = rho_b.*(1-wc);          % dry density of soil, g/mm^3


else

    iP = queryStruct(pdr,'name',sname, 'num',xnum);
    d = pdr(iP).disp;       % piston displacement (mm)
    in = pdr(iP).ExIn;      % indicies for start/stop of extrusion
    Msw = pdr(iP).ExMsw;    % mass of wet soil (g)
    WCnum = pdr(iP).CWCS;   % correspoding water content sample for extrusion

    d1 = mean(d(1:in(1)));  % initial piston displacement (mm)
    d2 = mean(d(in(2):end));% final piston displacement (mm)
    L = d2 - d1;            % length of extrusion (mm)
    Vol = L * Ax;           % volume of extrusion (mm^3)

    rho_b = Msw/Vol;        % bulk density of extrusion

    iWC = queryStruct(wcs, 'name',sname, 'num',WCnum);
    wc = waterContent(iWC, wcs);

    rho_d = rho_b.*(1-wc);          % dry density of soil, g/mm^3
    
end

    % Msw = (Mpsw - Mp);              % Mass of wet soil, g
    % rho_b = Msw./Vol;               % bulk density of soil, g/mm^3
    % rho_d = rho_b.*(1-wc);          % dry density of soil, g/mm^3
