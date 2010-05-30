function [Dsve, sPF, Dhyd, hPF] = grainSize(gsd_struct, wc_struct, sname, snum, hCF)
% GRAINSIZE DISTRIBUTION OF SOILS
%   This function calculates the grainsize distribution of a soil whose
%   data is stored in a structure array with the following fields:
%       .name =     Shelby tube name
%       .num  =     GSD test # for this tube,
%       .time =     time of hydrometer readings (min)
%       .hydr =     hydrometer readings (Hydr. type = 152H)
%       .temp =     hydrometer temperatures (deg. C)
%       .Msw  =     Wet mass of soil in hydrometer
%       .SpGr =     specific gravity of soil grains
%       .Msve =     vector of sieve masses (g)
%       .Mtot =     vector of sieve + soil retained masses (g)
%       .Dsve =     vector of sieve opening diameters (mm)
%       .CWCS =     Corresponding WC sample (hyroscopic for hydrometer)
%
%   There must also be a water content sample data structure with the
%    following fields:
%       .name =     Shelby tube name
%       .num  =     WC sample number, will be found with gsd_struct.CWCS
%       .Mp   =     mass of pan (g)
%       .Mpsw =     mass of pan + soil + water (g)
%       .Mps  =     mass of pan + soil (g)
%
%   Inputs:
%       gsd_struct  - this is the data structure with all of the grainsize
%           distribution data
%       wc_struct   - this is the data structure with all of water content
%           sample data
%       sname       - this is the name of the Shelby tube
%       snum        - this is the number of the soil sample from the tube
%       hCF         - this is the quadratic hydrometer calibration curve
%           coeffecients (loaded upon startup and called hCF)
%
%   Outputs:
%       Dsve - diameter of sieve openings (mm)
%       sPF  - percent finer from sieve analysis
%       Dhyd - diameters from hydrometer analysis (mm)
%       hPF  - percent finer from hydrometer analysis
%
%   Example:
%       >> [Dsve, sPF, Dhyd, hPF] = grainSize(GSD, WCS, '1A', '1', hCF)
%
%   See also queryStruct, waterContent, linInterp, planeInterp, gsdFigs.



% index of sample to be analyized
inGS = queryStruct(gsd_struct, 'name',sname, 'num',snum);


% Table 1 from ASTM D 422
Tab1.SpGr = (2.45:0.05:2.95)';      % SG column of ASTM D 422, Table 1
Tab1.alfa  = (1.04:-0.01:0.94)';    % alfa correction of ASTM D 422, Table 1
Tab1.alfa(1) = 1.05;                % correcting last value

% Table 2 from ASTM D 422
Tab2.AHyR = (0:1:60)';              % Actual Hydrometer Reading Column of ASTM D 422, Table 2
Tab2.EffD = ...                     % Effective Depth (cm) from ASTM D 422, Table 2
    [16.3 16.1 16.0 15.8 15.6 15.5 15.3 15.2 ...    
    15.0 14.8 14.7 14.5 14.3 14.2 14.0 13.8 ...
    13.7 13.5 13.3 13.2 13.0 12.9 12.7 12.5 ...
    13.5 13.3 13.2 13.0 12.9 12.7 12.5 12.4 ...
    12.2 12.0 11.9 11.7 11.5 11.4 11.2 11.1 ...
    10.9 10.7 10.6 10.4 10.2 10.1 9.9 9.7 9.6 ...
    9.4 9.2 9.1 8.9 8.6 8.4 8.3 8.1 7.9 7.8 ...
    7.6 7.4 7.3 7.1 7.0 6.8 6.6 6.5]';

% Table 3 from ASTM D 422
Tab3.SpGr = (2.45:0.05:2.85)';      % SG values covered in Table 3, cols/x_data
Tab3.Temp = (16:1:30)';             % Temperature values (deg. C) covered in Table 3, rows/y_data
Tab3.K = ...                        % K values from Table 3, z_data
    [0.01530 0.01505 0.01481 0.01457 0.01435 0.01414 0.01394 0.01374 0.01356;
    0.01511 0.01486 0.01462 0.01439 0.01417 0.01396 0.01376 0.01356 0.01338;
    0.01492 0.01467 0.01443 0.01421 0.01399 0.01378 0.01359 0.01339 0.01321;
    0.01474 0.01449 0.01425 0.01403 0.01382 0.01361 0.01342 0.01323 0.01305;
    0.01456 0.01431 0.01408 0.01386 0.01365 0.01344 0.01325 0.01307 0.01289;
    0.01438 0.01414 0.01391 0.01374 0.01369 0.01348 0.01328 0.01291 0.01273;
    0.01421 0.01397 0.01374 0.01353 0.01332 0.01312 0.01294 0.01276 0.01258;
    0.01404 0.01381 0.01358 0.01337 0.01317 0.01297 0.01279 0.01261 0.01243;
    0.01388 0.01365 0.01342 0.01321 0.01301 0.01282 0.01264 0.01246 0.01229;
    0.01372 0.01349 0.01327 0.01306 0.01286 0.01267 0.01249 0.01232 0.01215;
    0.01357 0.01334 0.01312 0.01291 0.01272 0.01253 0.01235 0.01218 0.01201;
    0.01342 0.01319 0.01297 0.01277 0.01258 0.01329 0.01221 0.01204 0.01188;
    0.01327 0.01304 0.01283 0.01264 0.01255 0.01244 0.01208 0.01191 0.01175;
    0.01312 0.01290 0.01269 0.01249 0.01230 0.01212 0.01195 0.01178 0.01162;
    0.01298 0.01276 0.01256 0.01236 0.01217 0.01199 0.01182 0.01165 0.01149];



% Hydrometer Data
t = [gsd_struct(inGS).time];	% time of hydrometer readings (minutes)
R = [gsd_struct(inGS).hydr];    % hydrometer readings (152H)
T = [gsd_struct(inGS).temp];    % temperature of suspension (deg. C)
SG = [gsd_struct(inGS).SG];     % specific gravity of soil grains

% Sieve Data
Dsve = [gsd_struct(inGS).Dsve]; % sieve openings (mm)
Msve = [gsd_struct(inGS).Msve]; % masses of the sieves (g)
Mtot = [gsd_struct(inGS).Mtot]; % masses of the sieves + soil (g)
Mret = Mtot - Msve;             % mass of soil retained in sieve (g)


if isempty(R)	% if only sieve data exists
    cumFR_ret = cumsum(Mret)./sum(Mret);    % calculate cumulative fraction retained
    sPF = (1 - cumFR_ret(1:end-1)) * 100;   % calculate percent finer (sieve)
    Dhyd = [];
    hPF = [];

else            % if sieve and hydrometer data exist

    % WCS.num of the hygroscopic moisture content sample
    hygro = [gsd_struct(inGS).CWCS];

    % find index of hygro WCS with hygro cells
    inWC = queryStruct(wc_struct, 'name',sname, 'num',hygro);

    % Soil sample data
    Msw = [gsd_struct(inGS).Msw];               % wet mass of soil in suspension (g)
    hygrWC = waterContent(inWC, wc_struct);     % determine water content using inWC
    Ms = Msw ./ (1 + hygrWC);                   % dry mass of soil in the suspension (g)


    % More soil sample data
    Mcoarse = sum(Mret);                        % mass of soil retained on wet #200 sieve (g)
    Mfine = Ms - Mcoarse;                       % mass of soil passing wet #200 sieve (g)
    n = length(Mret);

    Mret(n) = Mret(n) + Mfine;                  % add Mfine to the -pan- of the the sieve analysis g)

    % sieve analysis
    cumFR_ret = cumsum(Mret)./Ms;               % calculate cumulative fraction retained
    sPF = (1 - cumFR_ret(1:end-1)) * 100;       % calculate percent finer (sieve)



    % hydrometet analysis
    Rcorr = hCF(1) + hCF(2).*T + hCF(3).*(T.^2);    % correction for temperature variations
    R_ = R - Rcorr;                                 % applying the correction to the raw hydrometer readings
    alpha = linInterp(SG, Tab1.SpGr, Tab1.alfa);    % linearly interpolate a value of alpha from ASTM D 422, Table 1
    hPF = R_ * alpha / Ms * 100;                    % calculating the percent finer (hydrometer)

    L = zeros(length(R),1);                         % initialize L values
    K = zeros(length(R),1);                         % initialize K values
    for m = 1:length(R)
        L(m) = linInterp(R(m), Tab2.AHyR, Tab2.EffD);               % linearly interpolate L values from ASTM D 422, Table 2
        K(m) = planeInterp(SG, T(m), Tab3.SpGr, Tab3.Temp, Tab3.K); % interpolate K values from ASTM D 422, Table 3
    end

    Dhyd = K .* sqrt(L./t);                           % particle diameters from hydrometer, mm
end
