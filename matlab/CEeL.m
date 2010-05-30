% FIX THIS! :(

in = queryStruct(PDR, 'type','erosion extrusion');
% Exin = {PDR(in).ExIn}';
% d{in} = {PDR(in).disp}';

in0 = min(in);      % index of test extrusion (TE) in PDR)
inWC = queryStruct(WCS, 'name','3B', 'num','Ex0');  % index of TE in WCS
wc = waterContent(inWC, WCS);   % water content of TE
Mpsw = [WCS(inWC).Mpsw];          % mass of pan, soil, water of TE
Mp = [WCS(inWC).Mp];              % mas of pan of TE

pdr_ex = PDR(in);
[vol, num] = extrusionSize('3B', 'erosion extrusion', Ax, PDR);


for i = min(in):1:max(in)
    i
%     Exin{i} = [PDR(i).ExIn]';
%     d{i} = [PDR(i).disp]; 

    if i == in0
        [rho_b, rho_d] = soilDensities(Mpsw, Mp, wc, vol(i-in0 + 1));    % bulk/dry density, g/mm^3
    
    elseif i >= in0
        PDR(i).ExMcs = vol(i-in0 + 1) * rho_d;
        
    end
       
        
end


%     d1 = mean( PDR(i).disp(1:Exin{i}(1)) );        % initial pot. disp., mm
%     d2 = mean( PDR(i).disp(Exin{i}(2):end) );      % final pot. disp.,mm
%     L = d2 - d1;                            % length of extrusion, mm
%     Vol{i} = L * Ax;                           % vol. of extrs., mm^3
     