%%
N = 5;
sn = FSD(N).name
inW = queryStruct(WCS, 'name',sn, 'num','2','type','WC');
w = waterContent(inW, WCS);

inX = queryStruct(WCS, 'name',sn, 'type','extrusion')%, 'num', 'x5');
inX = inX;
Ms = (WCS(inX).Mpsw - WCS(inX).Mp)./(1+w)
FSD(N).SG
[L, Vt, num] = extrusionSize(sn, 'extrusion', Ax, PDR);
Vt
