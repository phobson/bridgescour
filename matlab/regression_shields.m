%% Import Ricardo Navarro's Shields Diagram data
x = importdata('RN_shields_data.txt', '\t');
sites = {x.textdata{:,1}}';                     % names/depths of samples
fRN = x.data(:,1);                              % percent fines of samples
dstarRN = x.data(:,2);                          % dimensionless diameters
tstarRN = x.data(:,3);                          % Shields parameters

%% Calculate my dstar, tstar
n = [];
for m = 1:length(FSD)
    if ~isempty(FSD(m).erD)
        n = [n; m];
    end
end



d50 = [FSD(n).d50]'/1000;               % median particle size converted to meters
SG = [FSD(n).SG]';                      % specific gravity of soil grains
pf = [FSD(n).silt]' + [FSD(n).clay]';   % percent fines
f = pf/100;                             % decimal fraction fines
nu = 1*10^-6;                           % viscosity of water (m^2/s)


tc = [];
for m = 1:length(n)                     
    tc(m) = FSD(n(m)).erS{1}(2,1);      
end
tc = tc';

dstar = (((SG - 1) * 9.81 .* d50.^3)/nu^2).^(1/3);
tstar = tc./((SG - 1) * 9810 .* d50);

n2 = length(tstar);
k = 2;

%% Regressions
% Ricardo's regression + data
[X{1}, TS{1}, stats{1}, SE{1}] = lsq_multLinFit([fRN log10(dstarRN)],log10(tstarRN));
X{1}(1) = 10^X{1}(1);       
TS{1} = X{1}(1) * 10.^(X{1}(2).*fRN) .* dstarRN.^X{1}(3);
% TC{1} = TS{1} * 


% stats{1}(1) = 10^stats{1}(1); % log correction to the stanard error


% Ricardo's regression + my data
TS{2} = X{1}(1) * 10.^(X{1}(2).*f) .* dstar.^X{1}(3);
SSE2 = sum((log10(tstar) - log10(TS{2})).^2);     % sum square error, Ricardo's model, my data
se2 = sqrt(SSE2/(n2-k-1));               % standard error of Ricardo's model on my data
Rsq2 = corr(log10(TS{2}), log10(tstar))^2;         % coeff. of deter., Ricardo/me

% Combined regressions
f3 = [fRN; f];
dstar3 = [dstarRN; dstar];
tstar3 = [tstarRN; tstar];
[X{3}, TS{3}, stats{3}, SE{3}] = lsq_multLinFit([f3 log10(dstar3)],log10(tstar3));
X{3}(1) = 10^X{3}(1);
TS{3} = X{3}(1) * 10.^(X{3}(2).*f3) .* dstar3.^X{3}(3);
n3 = length(tstar3);
% SSE_tmp = sum((tstar3 - TS{3}).^2);     % sum square error, Ricardo's model, my data
% stats{3}(1) = sqrt(SSE_tmp/(n3-k-1));               % standard error of Ricardo's model on my data
% stats{3}(1) = 10^stats{3}(1); % log correction to the stanard error






% Fines only
[X{4}, TS{4}, stats{4}, SE{4}] = lsq_multLinFit(f3,log10(tstar3));
X{4}(1) = 10^X{4}(1);
TS{4} = X{4}(1) * 10.^(X{4}(2).*f3);
% SSE_tmp = sum((tstar3 - TS{4}).^2);     % sum square error, Ricardo's model, my data
% stats{4}(1) = sqrt(SSE_tmp/(n3-k-1));               % standard error of Ricardo's model on my data
% stats{4}(1) = 10^stats{4}(1); % log correction tothe stanard error

x = linspace(0,1,100);
y = X{4}(1) * 10.^(X{4}(2).*x);

% overall stats of orig. model on all data
TS_ = X{1}(1) * 10.^(X{1}(2).*f3) .* dstar3.^X{1}(3);
% SSE1 = sum((tstar3 - TS_).^2);     % mean square error, Ricardo's model, my data
% se1 = sqrt(SSE1/(n3-1-1));               % standard error of Ricardo's model on my data
% Rsq1 = corr(TS_, tstar3)^2;         % coeff. of deter., Ricardo/me

%% Figures
% % % first figure with Ricardo's model
figure; 
S = num2str(X{1}, '%0.3g');
clf
hold on
h(1) = plot([0.01 100],[0.01 100], 'b-');
h(2) = plot(tstarRN, TS{1}, 'ko');
h(3) = plot(tstar, TS{2}, 'ko');
axis equal
axis([0.01 100 0.01 100])
ylabel('Predicted Shields Parameter, $\hat{\tau}_{*c}$', 'FontSize',11)
xlabel('Measured Shields Parameter, $\tau_{*c}$', 'FontSize',11)
text(0.015,0.02,'Line of Equality', 'Rotation',45, 'FontSize',11)
text(0.012, 40,['$\hat{\tau}_{*c}= ' S(1,:) ...
            '\times 10^{' S(2,:) 'Fines}d_*^{' S(3,:) '}$\\',...
            '$R^2_{\mathrm{logs}} = ', num2str(stats{1}(2),'%0.2f'),'$\\',...
            '$SE_{\mathrm{logs}} = ',num2str(stats{1}(1),'%0.2f'),'$'], 'FontSize',11)
set(gca, 'TickDir', 'out', 'YScale', 'log', 'XScale', 'log', 'FontSize',11)
grid on
box on
set(gca, 'YMinorGrid','off', 'XMinorGrid','off')
set(h(1), 'LineWidth',2, 'Color',[0 0 0.62])
set(h(2), 'MarkerSize', 7)
set(h(3), 'MarkerSize', 7, 'MarkerFaceColor', 'k')

% leg_str = {['Navarro 2004: $R^2 = ', num2str(stats{1}(2),'%0.3g'),...
%     '$, $SE = ',num2str(stats{1}(1),'%0.3g'),'$']...
%     ['Hobson 2008: $R^2 = ', num2str(Rsq2,'%0.3g'),...
%     '$, $SE = ',num2str(se2,'%0.3g'),'$']};

 leg_str = {['Navarro   2004']...
     ['Hobson   2008']};


legend(h(2:3), leg_str, 'Location', 'SouthEast', 'FontSize',11)
hold off
exFig(gcf, 'fig_mlr_shields1', 4.5, 4.5)

% % % second figure with new regression
figure; 
S = num2str(X{3}, '%0.3g');
clf
hold on
h(1) = plot([0.01 100],[0.01 100], 'b-');
h(2) = plot(tstar3(1:16), TS{4}(1:16), 'ko');
h(3) = plot(tstar3(17:end), TS{4}(17:end), 'ko');
axis equal
axis([0.01 100 0.01 100])
ylabel('Predicted Shields Parameter, $\hat{\tau}_{*c}$', 'FontSize',11)
xlabel('Measured Shields Parameter, $\tau_{*c}$', 'FontSize',11)
text(0.015,0.02,'Line of Equality', 'Rotation',45, 'FontSize',11)
text(0.012, 40,['$\hat{\tau}_{*c}= ' S(1,:) ...
        '\times 10^{' S(2,:) 'Fines}d_*^{' S(3,:) '}$\\',...
        '$R^2_{\mathrm{logs}} = ', num2str(stats{3}(2),'%0.2f'),'$\\',... 
        '$SE_{\mathrm{logs}} = ',num2str(stats{3}(1),'%0.2f'),'$'], 'FontSize',11)
set(gca, 'TickDir', 'out', 'YScale', 'log', 'XScale', 'log', 'FontSize',11)
grid on
box on
set(gca, 'YMinorGrid','off', 'XMinorGrid','off')
set(h(1), 'LineWidth',2, 'Color',[0 0 0.62])
set(h(2), 'MarkerSize', 7)
set(h(3), 'MarkerSize', 7, 'MarkerFaceColor', 'k')

leg_str = {'Navarro   2004' 'Hobson   2008'};

legend(h(2:3), leg_str, 'Location', 'SouthEast', 'FontSize',11)
hold off
exFig(gcf, 'fig_mlr_shields2', 4.5, 4.5)

    
% % % third figure with fines only regression
figure; 
S = num2str(X{4}, '%0.3g');
clf
hold on
h(1) = plot([0.01 100],[0.01 100], 'b-');
h(2) = plot(tstar3(1:16), TS{3}(1:16), 'ko');
h(3) = plot(tstar3(17:end), TS{3}(17:end), 'ko');
axis equal
axis([0.01 100 0.01 100])
ylabel('Predicted Shields Parameter, $\hat{\tau}_{*c}$', 'FontSize',11)
xlabel('Measured Shields Parameter, $\tau_{*c}$', 'FontSize',11)
text(0.015,0.02,'Line of Equality', 'Rotation',45, 'FontSize',11)
text(0.012, 40,['$\hat{\tau}_{*c}= ' S(1,:) ...
        '\times 10^{' S(2,:) 'Fines}$\\',...
        '$R^2_{\mathrm{logs}} = ', num2str(stats{4}(2),'%0.2f'),'$\\',... 
        '$SE_{\mathrm{logs}} = ',num2str(stats{4}(1),'%0.2f'),'$'], 'FontSize',11)
set(gca, 'TickDir', 'out', 'YScale', 'log', 'XScale', 'log', 'FontSize',11)
grid on
box on
set(gca, 'YMinorGrid','off', 'XMinorGrid','off')
set(h(1), 'LineWidth',2, 'Color',[0 0 0.62])
set(h(2), 'MarkerSize', 7)
set(h(3), 'MarkerSize', 7, 'MarkerFaceColor', 'k')

leg_str = {'Navarro   2004' 'Hobson   2008'};

legend(h(2:3), leg_str, 'Location', 'SouthEast', 'FontSize',11)
hold off
exFig(gcf, 'fig_mlr_shields3', 4.5, 4.5)


% % % Fines versus tstar
figure
hold on
h(1) = plot(x,y,'-', 'Color',[0 0 0.62], 'LineWidth',2);
h(2) = plot(f3(1:16), tstar3(1:16), 'ko', 'MarkerSize', 7);
h(3) = plot(f3(17:end), tstar3(17:end), 'ko', 'MarkerSize', 7, 'MarkerFaceColor','k');
xlabel('Fines Content of Soil', 'FontSize',11)
ylabel('Shields Parameter, $\tau_{*c}$', 'FontSize',11)
grid on
box on
set(gca, 'TickDir','out', 'YScale','log', 'YMinorGrid','off', 'FontSize',11)
text(0.012, 350,['$\hat{\tau}_{*c}= ' S(1,:) '\times 10^{' S(2,:) 'Fines}$\\',...
                    '$R^2_{\mathrm{logs}} = ', num2str(stats{4}(2),'%0.2f'),'$\\', ... 
                    '$SE_{\mathrm{logs}} = ',num2str(stats{4}(1),'%0.2f'),'$'], 'FontSize',11)

legstr = {'Navarro   2004' 'Hobson   2008', 'Best-fit curve'};
legend([h(2) h(3) h(1)], legstr, 'Location', 'SouthEast')
hold off
exFig(gcf, 'fig_mlr_shields3_fines', 6, 4)

% %% plot
% filename = {'fig_MLR_tstar_RN' 'fig_MLR_tstar_PH' ...
%     'fig_MLR_tstar_all' 'fig_MLR_tstar_fines'};
% tauS = {tstarRN; tstar; tstar2; tstar2};
% for n = 1:length(X)
%     S = num2str(X{n}, '%0.3g');
%     figure(n)
%     clf
%     hold on
%     h(1) = plot(TS{n}, tauS{n}, 'ko');
%     h(2) = plot([0.01 100],[0.01 100], 'b-');
%     set(h(1), 'MarkerFaceColor', 'k')
%     set(h(2), 'LineWidth',2)
%     axis equal
%     axis([0.01 100 0.01 100])
% %     xlabel(['Predicted Shields Parameter, $\hat{\tau}_{*c}= ' S(1,:) ...
% %         '\cdot 10^{' S(2,:) 'Fines}d_*^{' S(3,:) '}$'])
%     xlabel('Predicted Shields Parameter, $\hat{\tau}_{*c}$')
%     ylabel('Measured Critical Shear Stress, $\tau_{*c}$')
%     set(gca, 'XScale','log', 'YScale','log')
%     grid on
%     set(gca, 'YMinorGrid','off', 'XMinorGrid','off')
%     set(gca, 'TickDir', 'out')
%     text(0.0135,0.02,'Line of Equality', 'Rotation',45)
% %     text(0.011, 75, ['$\hat{\tau}_{*c} = ' S(1,:) ...
% %         '\cdot 10^{' S(2,:) 'Fines}d_*^{' S(3,:) '}$'])
%     text(0.035, 4, ['$R^2 = ', num2str(R2{n}(2),'%0.3f'), '$'])
%     box on
%     hold off
%     exFig(gcf,filename{n},4,4)
% end

%% clear variables
% clear x sites *RN n m d50  SG pf f nu tc dstar* tstar*
% clear X TS stats tauS S h n2 r seb ser sem
% clear f2 R2 SE filename
