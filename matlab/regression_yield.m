% This script pulls out data from FSD and runs regressions to predict the
% dimensionless yield stress.  The model based solely on d* is selected and
% plotted in two forms: measured versus predicted and data and model versus
% d*.  
%% INITIALIZE VARIABLES AND RUN MODELS
C = [];             % Clay content (decimal fraction)
F = [];             % Fines content (decimal fraction)
S = [];             % Silt content (decimal fraction)
AL = [];            % Activity
LL = [];            % Liquid limit (decimal fraction)
ds = [];            % d*, dimensionless diameter
rhob = [];          % Bulk denisty 
SG = [];            % Specific gravity of soil grains
d50 = [];           % Median particle size
PL = [];            % Plastic limit (decimal fraction)
nu = 1.004 *10^-6;  % visc. water @ 20 deg. C


ty{1} = [];         % Lower yield stress, from exp. fits
ty{2} = [];         % Upper yield stress, from exp. fits

% loop through samples tested in rheometer
for n = [1 2 5 6 7 8 10 12 13 15]

    % parameters for next regression
    C = [C; FSD(n).clay/100];
    S = [S; FSD(n).silt/100];
    AL = [AL; FSD(n).AL/100];
    LL = [LL; FSD(n).LL/100];
    PL = [PL; FSD(n).PL/100];
    rhob = [rhob; FSD(n).rhob];
    SG = [SG; FSD(n).SG];
    d50 = [d50; FSD(n).d50/1000];
    
    ds = [ds; ((FSD(n).SG-1)*9.81.*FSD(n).d50/nu).^(1/3)];
    
    ty{1} = [ty{1}; FSD(n).YS{1}(2)];
    ty{2} = [ty{2}; FSD(n).YS{2}(2)];
end

PI = LL - PL;       % Plasticity index
F = C + S;          % Fines content (decimal fraction)
PC = C./F;          % Fraction of fines that are clay
PS = C./F;          % Fraction of fines that are silt

% Dimensionless yield stresses (DYS)
tsy{1} = ty{1}./(9810 .* (SG-1) .* d50);
tsy{2} = ty{2}./(9810 .* (SG-1) .* d50);

% Predictors fed into model
x = [PC LL PL log10(ds) log10(AL)];

% Run the regressions
n = 1;
[X{n} Y{n} St{n} P{n}] = lsq_bestSubsetsRegression(x, log10(tsy{1}), 3); n = n+1;
[X{n} Y{n} St{n} P{n}] = lsq_bestSubsetsRegression(x, log10(tsy{2}), 3); n = n+1;

% % % % for n = 1:length(St)
% % % %     for m = 1:length(St{n})
% % % %         Y{n}{m} = 10.^Y{n}{m} * 9810 .* (SG-1) .* d50;
% % % %         
% % % %         M = length(ty{n});      % number of points in dataset
% % % %         N = St{n}(m,1);         % number of predictors
% % % %         % Stats on the Estimation
% % % %         SSR = sum( (Y{n}{m} - mean(ty{n})).^2 );
% % % %         SSE = sum( (ty{n} - Y{n}{m}).^2 );
% % % %         SST = sum( (ty{n} - mean(ty{n})).^2 );
% % % %         St{n}(m,2) = sqrt(SSE/(M-N-1));                     % std. error
% % % %         St{n}(m,3) = 1-SSE/SST;                             % R^2
% % % %         St{n}(m,4) = 1 - ((1-St{n}(m,3)) * ((M-1)/(M-N-1)));% R^2_adj
% % % %         St{n}(m,5) = sqrt(SSE/(M-N-1));                     % std. error
% % % %         
% % % %         
% % % %     end
% % % % end
% % % % 
% % % % 
% % % % % Write regression stats to text files
% % % % n = 1;
% % % % dlmwrite('log_tys1_E.txt', St{n}, '\t'); n = n+1;
% % % % dlmwrite('log_tys2_E.txt', St{n}, '\t'); n = n+1;
% % % % 
% % % % clc
%% choose a model and back out to the non-dimensionless yield stress
n = 4;                  % index of selected 1 parameter fit (d*).
TSY{1} = 10.^Y{1}{n};   % lower predicted yield stress
TSY{2} = 10.^Y{2}{n};   % upper dimensionless yield stress

TY{1} = TSY{1} .* (9810 .* (SG-1) .* d50);
TY{2} = TSY{2} .* (9810 .* (SG-1) .* d50);




%% PLOTTING MODEL AGAINST DATA
n = 4;          % index of selected 1 parameter fit (d*).
figure(1)
clf
hold on
h1(1) = plot([0.1 10^4], [0.1 10^4], '-');
h1(2) = plot(tsy{1},10.^Y{1}{n},'ko', 'MarkerSize',7);
h1(3) = plot(tsy{2},10.^Y{2}{n},'ko', ...
        'MarkerSize',7, ...
        'MarkerFaceColor','k');
set(h1(1), 'LineWidth',2, 'Color', clr.b)
set(gca,'TickDir', 'out', ...
        'XScale', 'log',...
        'YScale', 'log',...
        'FontSize', 11)
grid on
grid minor
box on
axis([0.1 10^4 0.1 10^4])
xlabel('Measured Dimensionless Yield Stress, $\tau^*_y$','FontSize', 11)
ylabel('Predicted Dimensionless Yield Stress, $\hat{\tau}^*_y$','FontSize', 11)
legend(h1(2:3), ...
    {'Lower dimensionless yield     stress', ...
    'Upper dimensionless yield     stress'},...
    'location', 'NorthWest','FontSize', 11)

% Convert coefficients to strings for figure
D = num2str([10^X{1}{n}(1); 10^X{2}{n}(1)], '%0.6g');
E = num2str([X{1}{n}(2); X{2}{n}(2)], '%0.3g');

% Pull out coeff. of determination
R2 = num2str([St{1}(n,3); St{2}(n,3)], '%0.2g');

% % Sum square errors of models transformed back to linear space
% SSE(1,1) = sum((tsy{1} - 10.^Y{1}{n}).^2);          
% SSE(2,1) = sum((tsy{2} - 10.^Y{1}{n}).^2);

% Standard errors of models in linear space
SE = num2str([St{1}(n,2); St{2}(n,2)], '%0.3g');      

% Strings for model equations and stats for figure
str1 = {['Lower Dimensionless Yield Stress\\',...
        '\toprule',...
        '$\hat{\tau}^*_{y1} =', D(1,:), '\, d_{*}^{', E(1,:), '}$\\',...
        '$R^2_{\mathrm{logs}} = ', R2(1,:),'$\\',...
        '$SE_{\mathrm{logs}} = ', SE(1,:), '$']};

str2 = {['Upper Dimensionless Yield Stress\\',...
        '\toprule',...
        '$\hat{\tau}^*_{y2} =', D(2,:), '\, d_{*}^{', E(2,:), '}$\\',...
        '$R^2_{\mathrm{logs}} = ', R2(2,:),'$\\',...
        '$SE_{\mathrm{logs}} = ', SE(2,:), '$']};
    
% Place text on figure and export
text(0.2, 510, str1,'FontSize', 11)
text(12, 0.51, str2,'FontSize', 11)
text(0.155,0.15,'$\leftarrow$ Line of Equality','FontSize', 11)
exFig(gcf, 'fig_mlr_tsy1', 4.5, 4.5)

%% PLOTTING MODEL AND DATA AGAINST d* (y = D * d*^E)
n=4;
ds_ = logspace(1,log10(150),100);       % d* vector for generating curve
D = [10^X{1}{n}(1); 10^X{2}{n}(1)];     % model coefficient
E = [X{1}{n}(2); X{2}{n}(2)];           % model coefficient
tsy_{1} = D(1) * ds_.^E(1);             % predicted lower DYS
tsy_{2} = D(2) * ds_.^E(2);             % predicted DYS


figure(2)
hold on
h1 = plot(ds,tsy{1}, 'ko', 'MarkerSize',7);
h2 = plot(ds_, tsy_{1}, '--', 'LineWidth',2, 'Color', clr.b);
h3 = plot(ds,tsy{2}, 'ko', 'MarkerFaceColor','k', 'MarkerSize',7);
h4 = plot(ds_, tsy_{2}, '-', 'LineWidth',2, 'Color', clr.b);
set(gca, 'XScale','lin', 'YScale','log',...
    'XGrid', 'on','YGrid','on',...
    'YMinorGrid','off', 'XMinorGrid','off');
xlabel('Dimensionless Particle Diameter, $d_*$','FontSize', 11)
ylabel('Dimensionless Yield Stress, $\tau^*_y$','FontSize', 11)
legend([h1 h3], ...
    {'Lower dimensionless yield     stress', ...
    'Upper dimensionless yield     stress'},...
    'location', 'NorthEast','FontSize', 11)

D = num2str([10^X{1}{n}(1); 10^X{2}{n}(1)], '%0.6g');
E = num2str([X{1}{n}(2); X{2}{n}(2)], '%0.3g');
str1 = {['Lower Dimensionless Yield Stress\\',...
        '\toprule',...
        '$\hat{\tau}^*_{y1} =', D(1,:), '\, d_{*}^{', E(1,:), '}$\\',...
        '$R^2_{\mathrm{logs}} = ', R2(1,:),'$\\',...
        '$SE_{\mathrm{logs}} = ', SE(1,:), '$']};

str2 = {['Upper Dimensionless Yield Stress\\',...
        '\toprule',...
        '$\hat{\tau}^*_{y2} =', D(2,:), '\, d_{*}^{', E(2,:), '}$\\',...
        '$R^2_{\mathrm{logs}} = ', R2(2,:),'$\\',...
        '$SE_{\mathrm{logs}} = ', SE(2,:), '$']};
box on
text(5, 0.5, str1,'FontSize', 11)
text(92, 500, str2,'FontSize', 11)
exFig(gcf, 'fig_mlr_tsy1_ds', 6, 4)