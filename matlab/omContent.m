function om = omContent(index, data_struct)
% ORGANIC MATTER CONTENT OF A SOIL
% This function determines the water contect of a record in a data
% structure with the following fields:
%   .Mp    - the mass of the pan (g)
%   .Mps   - mass of the pan + soil (g)
%   .Mpsa  - mass of the pan + soil + ash (g)
%   .name  - name of the sample (e.g., '1A' or '3B')
%
% Inputs:
%   index - vector of indices of sample as gathered from queryStruct.m
%   data_struct - data structure containing pertainent data
%
% Outputs:
%   om = water content of the sample.  Will be an N-by-1 matrix where N is
%       the number of samples located by index 
%
% Other functions called:
%   NONE
%
% Example:
%   >> % index of OM sample for 1A from data structure: OMD
%   >> inOM_1A = queryStruct(OMD, 'name','1A'); 
%   >>
%   >> OM_1A = omContent(inOM_1A, OMD); 
%
%   See also queryStruct, waterContent.

Mp = [data_struct(index).Mp]';      % mass of pan (g)
Mps = [data_struct(index).Mps]';    % mass of pan + soil (g)
Mpsa = [data_struct(index).Mpsa]';  % mass of pan + soil + water (g)   
    
Ma = Mpsa - Mps;                    % mass of ash (g)
Ms = Mps - Mp;                      % mass of soil (g)

om = Ma./Ms;                        % water content (dimensionless, Lambe page 8)