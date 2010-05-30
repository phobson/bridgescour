% b = [];     % y-int for lower ys, lin fit
% m = [];     % slope for lower ys, lin fit
% c = [];     % y-int for upper ys, exp fit
% d = [];     % exp term for upper ys, exp fit

F = [];     % clay content
d50 = [];   % median particle size
LL = [];    % liquid limit
ds = [];    % d*, dimensionless diameter
rhob = [];
SG = [];     % spec. grav. of soil grains

ty1_L = [];
ty2_L = [];
ty1_E = [];
ty2_E = [];

for n = [1 2 5 6 7 8 10 12 13 15]

%     % get lower ys linear regression parameters
%     b = [b; FSD(n).Xys{1}(1,1)];
%     m = [m; FSD(n).Xys{1}(2,1)];
%     
%     % get upper ys exp. regression parameters
%     c = [c; FSD(n).Xys{2}(1,1)];
%     d = [d; FSD(n).Xys{2}(2,1)];
    
    % parameters for next regression
    F = [F; 1 - FSD(n).sand/100];
    d50 = [d50; FSD(n).d50/1000];
    LL = [LL; FSD(n).LL];
    rhob = [rhob; FSD(n).rhob];
    SG = [SG; FSD(n).SG];
    
    nu = 1.004 *10^-6;  % visc. water @ 20 deg. C

    ds = [ds; ((FSD(n).SG-1)*9.81.*FSD(n).d50/nu).^(1/3)];
    
    ty1_L = [ty1_L; FSD(n).YS{1}(1)];
    ty1_E = [ty1_E; FSD(n).YS{1}(2)];
    ty2_L = [ty2_L; FSD(n).YS{2}(1)];
    ty2_E = [ty2_E; FSD(n).YS{2}(2)];


end

tsy1_L = ty1_L./(9810 .* (SG-1) .* d50);
% tsy1_E = ty1_E./(9810 .* (SG-1) .* d50);
tsy2_L = ty2_L./(9810 .* (SG-1) .* d50);
% tsy2_E = ty2_E./(9810 .* (SG-1) .* d50);

x = [F d50 ds LL log10([F d50 ds LL])];
% x = [F d50 ds LL];


n = 1;
% [X{n} Y{n} S{n} P{n}] = lsq_stepwiseRegression(x, ty1_L); n = n+1;
% [X{n} Y{n} S{n} P{n}] = lsq_stepwiseRegression(x, ty1_E); n = n+1;
% [X{n} Y{n} S{n} P{n}] = lsq_stepwiseRegression(x, ty2_L); n = n+1;
% [X{n} Y{n} S{n} P{n}] = lsq_stepwiseRegression(x, ty2_E); n = n+1;

[X{n} Y{n} S{n} P{n}] = lsq_stepwiseRegression(x, log10(tsy1_L)); n = n+1;
% [X{n} Y{n} S{n} P{n}] = lsq_stepwiseRegression(x, log10(tsy1_E)); n = n+1;
[X{n} Y{n} S{n} P{n}] = lsq_stepwiseRegression(x, log10(tsy2_L)); n = n+1;
% [X{n} Y{n} S{n} P{n}] = lsq_stepwiseRegression(x, log10(tsy2_E)); n = n+1;


% [X{n} Y{n} S{n} P{n}] = lsq_stepwiseRegression(x, tsy1_L); n = n+1;
% [X{n} Y{n} S{n} P{n}] = lsq_stepwiseRegression(x, tsy1_E); n = n+1;
% [X{n} Y{n} S{n} P{n}] = lsq_stepwiseRegression(x, tsy2_L); n = n+1;
% [X{n} Y{n} S{n} P{n}] = lsq_stepwiseRegression(x, tsy2_E); n = n+1;
% [X{n} Y{n} S{n} P{n}] = lsq_stepwiseRegression(x, log10(ty1_L)); n = n+1;
% [X{n} Y{n} S{n} P{n}] = lsq_stepwiseRegression(x, log10(ty1_E)); n = n+1;
% [X{n} Y{n} S{n} P{n}] = lsq_stepwiseRegression(x, log10(ty2_L)); n = n+1;
% [X{n} Y{n} S{n} P{n}] = lsq_stepwiseRegression(x, log10(ty2_E)); n = n+1;







n = 16;     % index of selected fit.

figure(1)
clf
hold on
h1(1) = plot([0.1 10^4], [0.1 10^4], '-');
h1(2) = plot(tsy1_L,10.^Y{1}{n},'ko', 'MarkerSize',7);
h1(3) = plot(tsy2_L,10.^Y{2}{n},'ko', ...
        'MarkerSize',7, ...
        'MarkerFaceColor','k');
set(h1(1), 'LineWidth',2, 'Color', clr.b)
set(gca,'TickDir', 'out', ...
        'XScale', 'log',...
        'YScale','log')
grid on
grid minor
box on
axis([0.1 10^4 0.1 10^4])
xlabel('Measured Yield Stress, $\tau_y$ (Pa)')
ylabel('Predicted Yield Stress, $\hat{\tau}_y$ (Pa)')
legend(h1(2:3), ...
    {'Lower yield stress, $\tau_{y1}$', 'Upper yield stress, $\tau_{y2}$'},...
    'location', 'NorthWest')

a = num2str([10^X{1}{n}(1); 10^X{2}{n}(1)], '%0.0f');
B = num2str([X{1}{n}(2); X{2}{n}(2)], '%0.0f');
C = num2str([X{1}{n}(3); X{2}{n}(3)], '%0.3g');

R2 = num2str([S{1}(n,3); S{2}(n,3)], '%0.3g');
SE = num2str([S{1}(n,2); S{2}(n,2)], '%0.3g');

str1 = {['Lower Yield Stress:\\',...
        '\toprule',...
        '$\hat{\tau}_{y1} =', a(1,:), '\times 10^{' B(1,:), 'd_{50} ', C(1,:), 'd_*}$\\',...
        '$R^2 = ', R2(1,:),'$\\',...
        '$SE = ', SE(1,:), '$']};

str2 = {['Upper Yield Stress:\\',...
        '\toprule',...
        '$\hat{\tau}_{y2} =', a(2,:), '\times 10^{' B(2,:), 'd_{50} ', C(2,:), 'd_*}$\\',...
        '$R^2 = ', R2(2,:),'$\\',...
        '$SE = ', SE(2,:), '$']};
    
text(0.2, 800, str1)
text(20, 0.4, str2)

% text(-9,-8,'Line of Equality', 'Rotation',45)
% text(-9,29.0, ['$\hat{b} = ', Xb(1,:), ' + ', Xb(2,:), ' d_{*} + ', ...
%     Xb(3,:), ' w_{LL} +', Xb(4,:), ' \log\left( d_{50}\right) + ',...
%     Xb(5,:), ' \log\left( d_{*}\right)$'])
% text(-9,27.5, ['$R^2 = ', num2str(Sb(3), '%0.3f'), '$'])
% text(-9,26.0, ['$SE = ', num2str(Sb(2), '%0.3f'), '$'])
exFig(gcf, 'fig_ty_regr', 4.5, 4.5)

% figure(2)
% clf
% hold on
% h1(1) = plot([0.1 10^4], [0.1 10^4], '-');

    
    

    
    
% set(h1(1), 'LineWidth',2, 'Color', clr.b)
% set(gca,'TickDir', 'out', ...
%         'XScale', 'log',...
%         'YScale','log')
% grid on
% grid minor
% box on
% axis([0.1 10^4 0.1 10^4])
% xlabel('Measured $y$-intercept of yield stress curve, $b$ (Pa)')
% ylabel('Predicted $y$-intercept of yield stress curve, $\hat{b}$ (Pa)')
% text(-9,-8,'Line of Equality', 'Rotation',45)
% text(-9,29.0, ['$\hat{b} = ', Xb(1,:), ' + ', Xb(2,:), ' d_{*} + ', ...
%     Xb(3,:), ' w_{LL} +', Xb(4,:), ' \log\left( d_{50}\right) + ',...
%     Xb(5,:), ' \log\left( d_{*}\right)$'])
% text(-9,27.5, ['$R^2 = ', num2str(Sb(3), '%0.3f'), '$'])
% text(-9,26.0, ['$SE = ', num2str(Sb(2), '%0.3f'), '$'])
% exFig(gcf, 'fig_ty1_b', 4.5, 4.5)





clc



% % dlmwrite('ty1_L.txt', S{n}, '\t'); n = n+1;
% % dlmwrite('ty1_E.txt', S{n}, '\t'); n = n+1;
% % dlmwrite('ty2_L.txt', S{n}, '\t'); n = n+1;
% % dlmwrite('ty2_E.txt', S{n}, '\t'); n = n+1;
% % dlmwrite('tsy1_L.txt', S{n}, '\t'); n = n+1;
% % dlmwrite('tsy1_E.txt', S{n}, '\t'); n = n+1;
% % dlmwrite('tsy2_L.txt', S{n}, '\t'); n = n+1;
% % dlmwrite('tsy2_E.txt', S{n}, '\t'); n = n+1;
% 
% n = 1;
% dlmwrite('lin_ty1_L.txt', S{n}, '\t'); n = n+1;
% dlmwrite('lin_ty1_E.txt', S{n}, '\t'); n = n+1;
% dlmwrite('lin_ty2_L.txt', S{n}, '\t'); n = n+1;
% dlmwrite('lin_ty2_E.txt', S{n}, '\t'); n = n+1;
% dlmwrite('log_tsy1_L.txt', S{n}, '\t'); n = n+1;
% dlmwrite('log_tsy1_E.txt', S{n}, '\t'); n = n+1;
% dlmwrite('log_tsy2_L.txt', S{n}, '\t'); n = n+1;
% dlmwrite('log_tsy2_E.txt', S{n}, '\t'); n = n+1;


% 
% index = [94 153 130 130 156 148 135 148];









% dlmwrite('Logty2_L.txt', S{n}, '\t'); n = n+1;
% dlmwrite('Logty2_E.txt', S{n}, '\t'); n = n+1;
% dlmwrite('Logtsy2_L.txt', S{n}, '\t'); n = n+1;
% dlmwrite('Logtsy2_E.txt', S{n}, '\t'); n = n+1;

% 
% % nb = 151;
% % nm = 151;
% % nc = 149;
% % nd = 130;
% 
% % Xb = num2str(Xb{nb},'%0.3g'); Yb = Yb{nb}; Sb = Sb(nb,:); Pb = Pb{nb};
% % Xm = num2str(Xm{nm},'%0.3g'); Ym = Ym{nm}; Sm = Sm(nm,:); Pm = Pm{nm};
% % Xc = num2str(Xc{nc},'%0.3g'); Yc = Yc{nc}; Sc = Sc(nc,:); Pc = Pc{nc};
% % Xd = num2str(Xd{nd},'%0.3g'); Yd = Yd{nd}; Sd = Sd(nd,:); Pd = Pd{nd};
% 
% 
% figure(1)
% clf
% hold on
% h1(1) = plot([-10 30], [-10 30], '-');
% h1(2) = plot(b,Yb,'ko', 'MarkerSize',7);
% set(h1(1), 'LineWidth',2, 'Color', clr.b)
% set(gca,'TickDir', 'out', 'YMinorTick','on', 'XminorTick','on')
% grid on
% box on
% axis([-10 30 -10 30])
% xlabel('Measured $y$-intercept of yield stress curve, $b$ (Pa)')
% ylabel('Predicted $y$-intercept of yield stress curve, $\hat{b}$ (Pa)')
% text(-9,-8,'Line of Equality', 'Rotation',45)
% text(-9,29.0, ['$\hat{b} = ', Xb(1,:), ' + ', Xb(2,:), ' d_{*} + ', ...
%     Xb(3,:), ' w_{LL} +', Xb(4,:), ' \log\left( d_{50}\right) + ',...
%     Xb(5,:), ' \log\left( d_{*}\right)$'])
% text(-9,27.5, ['$R^2 = ', num2str(Sb(3), '%0.3f'), '$'])
% text(-9,26.0, ['$SE = ', num2str(Sb(2), '%0.3f'), '$'])
% % exFig(gcf, 'fig_ty1_b', 4.5, 4.5)
% 
% figure(2)
% clf
% hold on
% h1(1) = plot([-0.16 0.04], [-0.16 0.04], '-');
% h1(2) = plot(m,Ym,'ko', 'MarkerSize',7);
% set(h1(1), 'LineWidth',2, 'Color', clr.b)
% set(gca,'TickDir', 'out', 'YMinorTick','on', 'XminorTick','on')
% grid on
% box on
% axis([-0.16 0.04 -0.16 0.04])
% set(gca, 'XTick', (-0.16:0.04:0.04), 'YTick',(-0.16:0.04:0.04))
% xlabel('Measured slope of yield stress curve, $m$ (Pa)')
% ylabel('Predicted slope of yield stress curve, $m{b}$ (Pa)')
% text(-0.152,-0.145,'Line of Equality', 'Rotation',45)
% text(-0.1575,0.03, ['$\hat{b} = ', Xm(1,:), ' + ', Xm(2,:), ' d_{*} + ', ...
%     Xm(3,:), ' w_{LL} +', Xm(4,:), ' \log\left( d_{50}\right) + ',...
%     Xm(5,:), ' \log\left( d_{*}\right)$'])
% text(-0.1575,0.02, ['$R^2 = ', num2str(Sm(3), '%0.3f'), '$'])
% text(-0.1575,0.01, ['$SE = ', num2str(Sm(2), '%0.3f'), '$'])
% % exFig(gcf, 'fig_ty1_m', 4.5, 4.5)


