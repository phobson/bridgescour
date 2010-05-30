function wc = waterContent(index, data_struct)
% WATER CONTENT OF A SOIL
% This function determines the water contect of a record in a data
% structure with the following fields:
%   .Mp   - the mass of the pan (g)
%   .Mps  - mass of the pan + soil (g)
%   .Mpsw - mass of the pan + soil + water (g)
%   .name - name of the sample (e.g., '1A' or '3B')
%
% Inputs:
%   index - vector of indices of sample as gathered from queryStruct.m
%   data_struct - data structure containing pertainent data
%
% Outputs:
%   wc = water content of the sample.  Will be an N-by-1 matrix where N is
%       the number of samples located by index 
%
% Other functions called:
%   NONE
%
% Example:
%   >> % index of WC samples for 1A from data structure: OMD
%   >> inWC_1A = queryStruct(WCS, 'name','1A', 'type','LL'); 
%   >>
%   >> wcLL_1A = waterContent(inLL_1A, WCS); 
%
%   See also queryStruct, omContent.

Mp = [data_struct(index).Mp]';      % mass of pan (g)
Mps = [data_struct(index).Mps]';    % mass of pan + soil (g)
Mpsw = [data_struct(index).Mpsw]';  % mass of pan + soil + water (g)   
    
Mw = Mpsw - Mps;                    % mass of water (g)
Ms = Mps - Mp;                      % mass of soil (g)

wc = Mw./Ms;                        % water content (dimensionless, Lambe page 8)