%% Multiple Linear Regressions
% The purpose of this m-file is to relate critical shear strength measured
% in the flume and the yield stress measured in the rheometer to the
% following sediment properties:
%   -bulk denisty (kg/m^3)
%   -water content (decimal fraction)
%   -organic matter (decimal fraction)
%   -median grain size (mm)
%   -clay content (decimal fraction)
%   -fines content (decimal fraction)

%% get ricardo's data and do his regression
RNd = dlmread('RN_lin_reg_data.txt', '\t', 1, 1);

RNtc = RNd(:,1);                    % crtical shear stress is 1st col. (Pa)
RNFC = RNd(:,2);                    % fines content is 2nd col. (% -> dec. fract)
RNOM = RNd(:,3);                    % OM content is 3rd col. (% -> dec. fract)
RNd50 = RNd(:,4);                   % d50 is 4th col. (mm)
RNrb = RNd(:,5);                    % bulk dendity is last col. (kg/m^3)


%% Get my data
% index of samples that eroded in the flume
in = [];
for n = 1:length(FSD)
    if ~isempty(FSD(n).erS)
        in = [in; n];
    end
end


rb = [FSD(in).rhob]';                       % bulk density
OM = [FSD(in).OM]';                         % organic matter content
d50 = [FSD(in).d50]';                       % median particle size
FC = [FSD(in).clay]' + [FSD(in).silt]';     % fines content
FC = FC/100;                                % convert to decimal fraction

% linear tau_c
tc = [];
for m = 1:length(in)
    tc(m) = FSD(in(m)).erS{1}(2,1);
end
tc = tc';



%% Combine datasets
rb3 = [RNrb; rb];                       % bulk density
OM3 = [RNOM; OM];                       % organic matter content
d503 = [RNd50; d50];                    % median particle size
FC3 = [RNFC; FC];                       % fines content
tc3 = [RNtc; tc];                       % critical shear stress


n2 = length(tc);    % number of my data points 
n3 = length(tc3);   % number of all data points
k = 3;              % number of predictors used

%% Ricardo's Original Regression
[X1, TC1, stats1, SE1] = lsq_multLinFit([RNFC RNOM RNd50], RNtc);
S1 = num2str(X1, '%0.3g');
TC2 = X1(1) + X1(2)*FC + X1(3)*OM + X1(4)*d50;      % My data
TC3 = X1(1) + X1(2)*FC3 + X1(3)*OM3 + X1(4)*d503;   % all data, ric's regression


SSE2 = sum((TC2 - tc).^2);          % mean square error, Ricardo's model, my data
SSE3 = sum((TC3 - tc3).^2);         % mean square error, Ricardo's model, all data


se2 = sqrt(SSE2/(n2-k-1));      % standard error of Ricardo's model on my data
se3 = sqrt(SSE3/(n3-k-1));      % standard error of Ricardo's model on all data


Rsq2 = corr(TC2, tc)^2;     % coeff. of deter., Ricardo/me
Rsq3 = corr(TC3, tc3)^2;    % coeff. of deter., Ricardo/all data
%% new regression on all data
[X4, TC4, stats4, SE4] = lsq_multLinFit([FC3 OM3 d503],tc3);
S4 = num2str(X4, '%0.3g');


%% figures
 % first figure with Ricardo's model
figure;    
clf
hold on
h(1) = plot([0 20],[0 20], 'b-');
h(2) = plot(RNtc, TC1, 'ko');
h(3) = plot(tc, TC2, 'ko');
axis equal
axis([0 20 0 20])
ylabel('Predicted Critical Shear Stress, $\hat{\tau}_c$ (Pa)', 'FontSize',11)
xlabel('Measured Critical Shear Stress, $\tau_c$ (Pa)', 'FontSize',11)
text(14.375,15,'Line of Equality', 'Rotation',45, 'FontSize',11)
text(0.25,19.25, ['$\hat{\tau}_c = ' S1(1,:) ' + ' S1(2,:) '\,Fines '...
    S1(3,:) '\,OM + ' S1(4,:) '\,d_{50}$'], 'FontSize',11)
text(0.25, 18.25, ['$R^2 = ', num2str(Rsq3, '%0.2f'), '$'], 'FontSize',11)
text(0.25, 17.25, ['$SE = ', num2str(se3, '%0.2f'), '$'], 'FontSize',11)

set(gca, 'XTick', [0 5 10 15 20])
set(gca, 'YTick', [0 5 10 15 20])
set(gca, 'XMinorTick','on', 'YMinorTick','on')
set(gca, 'TickDir', 'out', 'FontSize',11)
set(h(1), 'LineWidth',2, 'Color',[0 0 0.62])
set(h(2), 'MarkerSize', 7)
set(h(3), 'MarkerSize', 7, 'MarkerFaceColor', 'k')

leg_str = {['Navarro 2004: R2 = ', num2str(stats1(2), '%0.2f'), ' , SE = ', num2str(stats1(1), '%0.2f')]...
    ['Hobson 2008: R2 = ', num2str(Rsq2, '%0.2f'), ' , SE = '...
    num2str(se2, '%0.2f')]};

legend(h(2:3), leg_str, 'Location', 'SouthEast', 'FontSize',11)
grid on
box on
hold off
exFig(gcf, 'fig_mlr_tc1', 4.5, 4.5)

%%
% second figure with new model
figure;     
clf
hold on
h(1) = plot([0 20],[0 20], 'b-');
h(2) = plot(tc3(1:16), TC3(1:16), 'ko');
h(3) = plot(tc3(17:end), TC3(17:end), 'ko');
axis equal
axis([0 20 0 20])
ylabel('Predicted Critical Shear Stress, $\hat{\tau}_c$ (Pa)', 'FontSize',11)
xlabel('Measured Critical Shear Stress, $\tau_c$ (Pa)', 'FontSize',11)
text(14.375,15,'Line of Equality', 'Rotation',45)
text(0.25,19.25, ['$\hat{\tau}_c = ' S4(1,:) ' + ' S4(2,:) '\,Fines '...
    S4(3,:) '\,OM + ' S4(4,:) '\,d_{50}$'], 'FontSize',11)
text(0.25, 18.25, ['$R^2 = ', num2str(stats4(2), '%0.2f'), '$'], 'FontSize',11)
text(0.25, 17.25, ['$SE = ', num2str(stats4(1), '%0.2f'), '$'], 'FontSize',11)

set(gca, 'XTick', [0 5 10 15 20])
set(gca, 'YTick', [0 5 10 15 20])
set(gca, 'XMinorTick','on', 'YMinorTick','on')
set(gca, 'TickDir', 'out', 'FontSize',11)
set(h(1), 'LineWidth',2, 'Color',[0 0 0.62])
set(h(2), 'MarkerSize', 7)
set(h(3), 'MarkerSize', 7, 'MarkerFaceColor', 'k')

leg_str = {'Navarro   2004' 'Hobson   2008'};

legend(h(2:3), leg_str, 'Location', 'SouthEast', 'FontSize',11)
grid on
box on
hold off
exFig(gcf, 'fig_mlr_tc2', 4.5,4.5)

% clear n ans N X E TC h stats ii in RN* S d50* 
% clear filename rb* tau tc* var OM OM2 FC*

















































% %% Evavulate regressions
% [X{1}, TC{1}, stats{1}] = lsq_multLinFit([RNFC RNOM RNd50],RNtc);
% [X{2}, TC{2}, stats{2}] = lsq_multLinFit([RNFC RNOM RNrb],RNtc);
% [X{3}, TC{3}, stats{3}] = lsq_multLinFit([FC OM d50],tc);
% [X{4}, TC{4}, stats{4}] = lsq_multLinFit([FC OM rb],tc);
% [X{5}, TC{5}, stats{5}] = lsq_multLinFit([FC2 OM2 d502],tc2);
% [X{6}, TC{6}, stats{6}] = lsq_multLinFit([FC2 OM2 rb2],tc2);
% 
% filename = {'fig_MLR_tcritd50_RN'
%     'fig_MLR_tcritrb_RN'
%     'fig_MLR_tcritd50_PH'
%     'fig_MLR_tcritrb_PH'
%     'fig_MLR_tcritd50_all'
%     'fig_MLR_tcritrb_all'};
% 
% tau = {RNtc; RNtc; tc; tc; tc2; tc2};
% var = {'d_{50}$'
%         '\rho_b$'
%         'd_{50}$'
%         '\rho_b$'
%         'd_{50}$'
%         '\rho_b$'};
% 
% for n = 1:length(X)
%     S = num2str(X{n}, '%0.3g');
%     figure(n)
%     hold on
%     h(1) = plot(TC{n}, tau{n}, 'ko');
%     h(2) = plot([0 20],[0 20], 'b-');
%     set(h(1), 'MarkerFaceColor', 'k')
%     set(h(2), 'LineWidth',2)
%     axis equal
%     axis([0 20 0 20])
%     xlabel('Predicted Critical Shear Stress, $\hat{\tau}_c$ (Pa)')
%     ylabel('Measured Critical Shear Stress, $\tau_c$ (Pa)')
%     set(gca, 'XTick', [0 4 8 12 16 20])
%     set(gca, 'YTick', [0 4 8 12 16 20])
%     text(14.375,15,'Line of Equality', 'Rotation',45)
%     if n <= 2 || n >= 5
%         text(0.25,19.25, ['$\hat{\tau}_c = ' S(1,:) ' + ' S(2,:) 'Fines + '...
%             S(3,:) 'OM + ' S(4,:) var{n}])
% %     elseif n == 3 || n == 4
% %         text(1,19, ['$\tau_c = ' S(1,:) ' + ' S(2,:) 'Fines + '...
% %             % S(3,:) 'OM + ' S(4,:) 'd_{50}$'])
% %             S(3,:) var{n}])
%         
%     end
%     text(13, 8.5, ['$R^2 = ', num2str(stats{n}(1),'%0.3f'), '$'])
%     box on
%     grid on
%     exFig(gcf,filename{n},4,4)
% end
% 
% % figure(2)
% % hold on
% % h(1) = plot(TC2, RNtc, 'ko');
% % h(2) = plot([0 20],[0 20], 'b-');
% % set(h(1), 'MarkerFaceColor', 'k')
% % set(h(2), 'LineWidth',2)
% % axis equal
% % axis([0 20 0 20])
% % xlabel('Predicted Critical Shear Stress, $\hat{\tau_c}$ (Pa)')
% % ylabel('Measured Critical Shear Stress, $\tau_c$ (Pa)')
% % set(gca, 'XTick', [0 4 8 12 16 20])
% % set(gca, 'YTick', [0 4 8 12 16 20])
% % text(14.5,15,'Line of Equality', 'Rotation',45)
% % text(13, 9, ['$R^2 = ', num2str(stats2(1),'%0.5f'), '$'])
% % box on
% % grid on
% % 
% % 
% % 
% % 
% % % evaluate regression
% % 
% % 
% % % figure(3)
% % % hold on
% % % h(1) = plot(TC3, tc, 'ko');
% % % h(2) = plot([0 20],[0 20], 'b-');
% % % set(h(1), 'MarkerFaceColor', 'k')
% % % set(h(2), 'LineWidth',2)
% % % axis equal
% % % axis([0 20 0 20])
% % % xlabel('Predicted Critical Shear Stress, $\hat{\tau_c}$ (Pa)')
% % % ylabel('Measured Critical Shear Stress, $\tau_c$ (Pa)')
% % % set(gca, 'XTick', [0 4 8 12 16 20])
% % % set(gca, 'YTick', [0 4 8 12 16 20])
% % % text(14.4,15,'Line of Equality', 'Rotation',45)
% % % text(13, 9, ['$R^2 = ', num2str(stats3(1),'%0.5f'), '$'])
% % % box on
% % % grid on
% % %
% % %
% % % figure(4)
% % % hold on
% % % h(1) = plot(TC4, tc, 'ko');
% % % h(2) = plot([0 20],[0 20], 'b-');
% % % set(h(1), 'MarkerFaceColor', 'k')
% % % set(h(2), 'LineWidth',2)
% % % axis equal
% % % axis([0 20 0 20])
% % % xlabel('Predicted Critical Shear Stress, $\hat{\tau_c}$ (Pa)')
% % % ylabel('Measured Critical Shear Stress, $\tau_c$ (Pa)')
% % % set(gca, 'XTick', [0 4 8 12 16 20])
% % % set(gca, 'YTick', [0 4 8 12 16 20])
% % % text(14.4,15,'Line of Equality', 'Rotation',45)
% % % text(13, 9, ['$R^2 = ', num2str(stats4(1),'%0.5f'), '$'])
% % % box on
% % % grid on
% % 
% % 
% % 
% % 
% % 
% % 
% % % figure(5)
% % % hold on
% % % h(1) = plot(TC5, tc2, 'ko');
% % % h(2) = plot([0 20],[0 20], 'b-');
% % % set(h(1), 'MarkerFaceColor', 'k')
% % % set(h(2), 'LineWidth',2)
% % % axis equal
% % % axis([0 20 0 20])
% % % xlabel('Predicted Critical Shear Stress, $\hat{\tau_c}$ (Pa)')
% % % ylabel('Measured Critical Shear Stress, $\tau_c$ (Pa)')
% % % set(gca, 'XTick', [0 4 8 12 16 20])
% % % set(gca, 'YTick', [0 4 8 12 16 20])
% % % text(14.4,15,'Line of Equality', 'Rotation',45)
% % % text(13, 9, ['$R^2 = ', num2str(stats5(1),'%0.5f'), '$'])
% % % box on
% % % grid on
% % %
% % %
% % % figure(6)
% % % hold on
% % % h(1) = plot(TC6, tc2, 'ko');
% % % h(2) = plot([0 20],[0 20], 'b-');
% % % set(h(1), 'MarkerFaceColor', 'k')
% % % set(h(2), 'LineWidth',2)
% % % axis equal
% % % axis([0 20 0 20])
% % % xlabel('Predicted Critical Shear Stress, $\hat{\tau_c}$ (Pa)')
% % % ylabel('Measured Critical Shear Stress, $\tau_c$ (Pa)')
% % % set(gca, 'XTick', [0 4 8 12 16 20])
% % % set(gca, 'YTick', [0 4 8 12 16 20])
% % % text(14.4,15,'Line of Equality', 'Rotation',45)
% % % text(13, 9, ['$R^2 = ', num2str(stats6(1),'%0.5f'), '$'])
% % % box on
% % % grid on
% % 
% % 
% % % %% clear variables