%% 1C-1
clear n tau ER xhat b m c d x y h x_hat ans ER_lin ER_exp SSR SST SSE CoD 
clear tc_lin tc_exp tc_pwl x1 x2 y1 y2 m1 m2 b1 b2 in int a M M1 M2 leg_str
clear LER E_c ER_bar ER_hat seL seX seP

n = queryStruct(FSD, 'name','1C', 'num','1');   % index of 1C-1
tau = [FSD(n).tau{1}];                          % bed shear stress (Pa)
ER = [FSD(n).LER{1}] * FSD(n).rhod / 1000;      % erosion rate (kg/m^2/s)
x = (0:1:22)';                                  % x-vector for estimations
E_c = 0.0019;                                   % critical erosion rate for exp. curves

% linear fit
[xhat, seL] = lsq_linFit(tau,ER,1);
b = xhat(1);                    % y intercept
m = xhat(2);                    % slope of the best fit line
y{1} = b + m*x;                 % estimating of ER using m and b
tc_lin = -b/m;                  % critical shear stress (tau @ ER = 0)
M = tc_lin * m;                 % linear erosion constant

% exponential fit
[c d seX] = lsq_expFit(tau,ER);
y{2} = c * exp(x*d);                    % estimate ER using c and d
tc_exp = log(E_c/c)/d;                  % critical shear stress (tau @ ER = E_c)
a = d * (x - tc_exp)./((x./tc_exp) - 1);  % exponential erosion constant


% estimations (ER_hats, 1 = linear; 2 = exponential)
ER_hat{1} = b + tau*m;
ER_hat{2} = c * exp(tau*d);
ER_bar = mean(ER);

SSR{1} = sum( (ER_hat{1} - ER_bar).^2 );
SSR{2} = sum( (ER_hat{2} - ER_bar).^2 );

SSE{1} = sum( (ER - ER_hat{1}).^2 );
SSE{2} = sum( (ER - ER_hat{2}).^2 );

SST{1} = sum( (ER - ER_bar).^2 );
SST{2} = sum( (ER - ER_bar).^2 );

CoD{1}(1) = SSR{1}/SST{1};
CoD{2}(1) = SSR{2}/SST{2};



figure(1)
hold on
grid on
box on

leg_str = {'Erosion data', 'Linear fit', 'Exponential fit'};

h(2) = plot(x,y{1},'b-');
h(3) = plot(x,y{2},'g-');
h(1) = plot(tau, ER, 'ko');
legend(h, leg_str, 'location','NorthEast')
set(h(1), 'MarkerSize',7, 'MarkerFaceColor','k')
set(h(2:3), 'LineWidth',2)
set(gca, 'TickDir', 'out')
axis([0 22 0 10]);
xlabel('Bed Shear Stress, $\tau$ (Pa)')
ylabel('Erosion Rate, $E$, (kg/m\ssu{2}/s)')




%% 1C-3
clear n tau ER xhat b m c d x y h x_hat ans ER_lin ER_exp SSR SST SSE CoD 
clear tc_lin tc_exp tc_pwl x1 x2 y1 y2 m1 m2 b1 b2 in int a M M1 M2 leg_str
clear LER E_c ER_bar ER_hat seL seX seP


n = queryStruct(FSD, 'name','1C', 'num','3');   % index of 1C-1
tau = [FSD(n).tau{1}];                          % bed shear stress (Pa)
ER = [FSD(n).LER{1}] * FSD(n).rhod / 1000;      % erosion rate (kg/m^2/s)
x = (0:1:22)';                                  % x-vector for estimations
E_c = 0.0019;                                   % critical erosion rate for exp. curves

% linear fit
[xhat, seL] = lsq_linFit(tau,ER,1);
b = xhat(1);                    % y intercept
m = xhat(2);                    % slope of the best fit line
y{1} = b + m*x;                 % estimating of ER using m and b
tc_lin = -b/m;                  % critical shear stress (tau @ ER = 0)
M = tc_lin * m;                 % linear erosion constant

% exponential fit
[c d seX] = lsq_expFit(tau,ER);
y{2} = c * exp(x*d);                    % estimate ER using c and d
tc_exp = log(E_c/c)/d;                  % critical shear stress (tau @ ER = E_c)
a = d * (x(1) - tc_exp)./((x(1)/tc_exp) - 1);  % exponential erosion constant


% estimations (ER_hats, 1 = linear; 2 = exponential)
ER_hat{1} = b + tau*m;
ER_hat{2} = c * exp(tau*d);
ER_bar = mean(ER);

SSR{1} = sum( (ER_hat{1} - ER_bar).^2 );
SSR{2} = sum( (ER_hat{2} - ER_bar).^2 );

SSE{1} = sum( (ER - ER_hat{1}).^2 );
SSE{2} = sum( (ER - ER_hat{2}).^2 );

SST{1} = sum( (ER - ER_bar).^2 );
SST{2} = sum( (ER - ER_bar).^2 );

CoD{1}(1) = SSR{1}/SST{1};
CoD{2}(1) = SSR{2}/SST{2};

r{1} = ER_hat{1} - ER;
r{2} = ER_hat{2} - ER;

S{1} = sum(r{1}.^2);
S{2} = sum(r{2}.^2);

SE(1) = sqrt((S{1}/(length(tau) - 2)) * inv(xhat'*xhat));
SE(2) = sqrt((S{2}/(length(tau) - 2)) * inv(xhat'*xhat));

figure(2)
hold on
grid on
box on

leg_str = {'Erosion data', 'Linear fit', 'Exponential fit'};

h(2) = plot(x,y{1},'b-');
h(3) = plot(x,y{2},'g--');
h(1) = plot(tau, ER, 'ko');
legend(h, leg_str, 'location','NorthEast')
set(h(1), 'MarkerSize',7, 'MarkerFaceColor','k')
set(h(2:3), 'LineWidth',2)
set(gca, 'TickDir', 'out')
axis([0 22 0 10]);
xlabel('Bed Shear Stress, $\tau$ (Pa)')
ylabel('Erosion Rate, $E$, (kg/m\ssu{2}/s)')



%% 2As

clear n tau ER xhat b m c d x y h x_hat ans ER_lin ER_exp SSR SST SSE CoD 
clear tc_lin tc_exp tc_pwl x1 x2 y1 y2 m1 m2 b1 b2 in int a M M1 M2 leg_str
clear LER E_c ER_bar ER_hat seL seX seP


n = queryStruct(FSD, 'name','2A', 'num','1');   % index of 1C-1
tau = [FSD(n).tau{1}];                          % bed shear stress (Pa)
ER = [FSD(n).LER{1}] * FSD(n).rhod / 1000;      % erosion rate (kg/m^2/s)
x{1} = (0:1:22)';                                  % x-vector for estimations
x{2} = (0:1:22)';                                  % x-vector for estimations
E_c = 0.0019;                                   % critical erosion rate for exp. curves

% linear fit
[xhat seL] = lsq_linFit(tau,ER,1);
b1 = xhat(1);                    % y intercept
m1 = xhat(2);                    % slope of the best fit line
y{1} = b1 + m1*x{1};                 % estimating of ER using m and b
tc_lin = -b1/m1;                  % critical shear stress (tau @ ER = 0)
M1 = tc_lin * m1;                 % linear erosion constant

% exponential fit
[c d seX] = lsq_expFit(tau,ER);
y{2} = c * exp(x{2}*d);                    % estimate ER using c and d
tc_exp = log(E_c/c)/d;                  % critical shear stress (tau @ ER = E_c)
a = d * (x{2}(1) - tc_exp)./((x{2}(1)/tc_exp) - 1);  % exponential erosion constant

% piece-wise linear fit
[x_hat, int, seP] = lsq_pwlFit(tau,ER,2);
m2 = [x_hat{1}(2); x_hat{2}(2)];             % slopes of both fits
b2 = [x_hat{1}(1); x_hat{2}(1)];             % intercepts of both fits

x1 = linspace(1,int, 20);                   % x-vector, first fit
y1 = m2(1)*x1 + b2(1);                        % estimation, first fit

x2 = linspace(int,21,20);                   % x-vector, second fit
y2 = m2(2)*x2 + b2(2);                        % estimation, second fit

% combine estimations
x{3} = [x1'; x2'];
y{3} = [y1'; y2'];
tc_pwl = -b2(1)/m2(1);                         % critical shear stres (Pa)
M2 = m2(1) * tc_pwl;



% estimations (ER_hats, 1 = linear; 2 = exponentia; 3 = piece-wise linear)
ER_hat{1} = b1 + tau*m1;
ER_hat{2} = c * exp(tau*d);
ER_hat{3} = zeros(4,1);
ER_hat{3}(1:2) = b2(1) + tau(1:2)*m2(1);
ER_hat{3}(3:4) = b2(2) + tau(3:4)*m2(2);
ER_bar = mean(ER);

SSR{1} = sum( (ER_hat{1} - ER_bar).^2 );
SSR{2} = sum( (ER_hat{2} - ER_bar).^2 );
SSR{3} = sum( (ER_hat{3} - ER_bar).^2 );

SSE{1} = sum( (ER - ER_hat{1}).^2 );
SSE{2} = sum( (ER - ER_hat{2}).^2 );
SSE{3} = sum( (ER - ER_hat{3}).^2 );

SST{1} = sum( (ER - ER_bar).^2 );
SST{2} = sum( (ER - ER_bar).^2 );
SST{3} = sum( (ER - ER_bar).^2 );

CoD{1}(1,1) = SSR{1}/SST{1};
CoD{2}(1,1) = SSR{2}/SST{2};
CoD{3}(1,1) = SSR{3}/SST{3};


figure(3)
hold on
grid on
box on

leg_str = {'Erosion data', 'Linear fit', 'Exponential fit', 'Piece-wise linear fit'};

h(2) = plot(x{1},y{1},'b-');
h(3) = plot(x{2},y{2},'g--');
h(4) = plot(x{3},y{3},'r.-');
h(1) = plot(tau, ER, 'ko');
legend(h, leg_str, 'location','NorthEast')
set(h(1), 'MarkerSize',7, 'MarkerFaceColor','k')
set(h(2:4), 'LineWidth',2)
set(gca, 'TickDir', 'out')
axis([0 22 0 10]);
xlabel('Bed Shear Stress, $\tau$ (Pa)')
ylabel('Erosion Rate, $E$, (kg/m\ssu{2}/s)')




%% 2B-1
clear n tau ER xhat b m c d x y h x_hat ans ER_lin ER_exp SSR SST SSE CoD 
clear tc_lin tc_exp tc_pwl x1 x2 y1 y2 m1 m2 b1 b2 in int a M M1 M2 leg_str
clear LER E_c ER_bar ER_hat seL seX seP


n = queryStruct(FSD, 'name','2B', 'num','1');   % index of 1C-1
tau = [FSD(n).tau{1}];                          % bed shear stress (Pa)
ER = [FSD(n).LER{1}] * FSD(n).rhod / 1000;      % erosion rate (kg/m^2/s)
x = linspace(0,22);                                  % x-vector for estimations
E_c = 0.0019;                                   % critical erosion rate for exp. curves

% linear fit
[xhat seL] = lsq_linFit(tau,ER,1);
b = xhat(1);                    % y intercept
m = xhat(2);                    % slope of the best fit line
y{1} = b + m*x;                 % estimating of ER using m and b
tc_lin = -b/m;                  % critical shear stress (tau @ ER = 0)
M = tc_lin * m;                 % linear erosion constant

% exponential fit
[c d seX] = lsq_expFit(tau,ER);
y{2} = c * exp(x*d);                    % estimate ER using c and d
tc_exp = log(E_c/c)/d;                  % critical shear stress (tau @ ER = E_c)
a = d * (x(1) - tc_exp)./((x(1)/tc_exp) - 1);  % exponential erosion constant


% estimations (ER_hats, 1 = linear; 2 = exponential)
ER_hat{1} = b + tau*m;
ER_hat{2} = c * exp(tau*d);
ER_bar = mean(ER);

SSR{1} = sum( (ER_hat{1} - ER_bar).^2 );
SSR{2} = sum( (ER_hat{2} - ER_bar).^2 );

SSE{1} = sum( (ER - ER_hat{1}).^2 );
SSE{2} = sum( (ER - ER_hat{2}).^2 );

SST{1} = sum( (ER - ER_bar).^2 );
SST{2} = sum( (ER - ER_bar).^2 );

CoD{1}(1) = SSR{1}/SST{1};
CoD{2}(1) = SSR{2}/SST{2};

figure(4)
hold on
grid on
box on

leg_str = {'Erosion data', 'Linear fit', 'Exponential fit'};

h(2) = plot(x,y{1},'b-');
h(3) = plot(x,y{2},'g--');
h(1) = plot(tau, ER, 'ko');
legend(h, leg_str, 'location','NorthEast')
set(h(1), 'MarkerSize',7, 'MarkerFaceColor','k')
set(h(2:3), 'LineWidth',2)
set(gca, 'TickDir', 'out')
axis([0 22 0 1]);
xlabel('Bed Shear Stress, $\tau$ (Pa)')
ylabel('Erosion Rate, $E$, (kg/m\ssu{2}/s)')



%% 2B-2
clear n tau ER xhat b m c d x y h x_hat ans ER_lin ER_exp SSR SST SSE CoD 
clear tc_lin tc_exp tc_pwl x1 x2 y1 y2 m1 m2 b1 b2 in int a M M1 M2 leg_str
clear LER E_c ER_bar ER_hat seL seX seP

n = queryStruct(FSD, 'name','2B', 'num','1');   % index of 1C-1
tau = [FSD(n).tau{2}];                          % bed shear stress (Pa)
ER = [FSD(n).LER{2}] * FSD(n).rhod / 1000;      % erosion rate (kg/m^2/s)
x = linspace(0,22);                                  % x-vector for estimations
E_c = 0.0019;                                   % critical erosion rate for exp. curves

% linear fit
[xhat, seL] = lsq_linFit(tau,ER,1);
b = xhat(1);                    % y intercept
m = xhat(2);                    % slope of the best fit line
y{1} = b + m*x;                 % estimating of ER using m and b
tc_lin = -b/m;                  % critical shear stress (tau @ ER = 0)
M = tc_lin * m;                 % linear erosion constant

% exponential fit
[c d seX] = lsq_expFit(tau,ER);
y{2} = c * exp(x*d);                    % estimate ER using c and d
tc_exp = log(E_c/c)/d;                  % critical shear stress (tau @ ER = E_c)
a = d * (x(1) - tc_exp)./((x(1)/tc_exp) - 1);  % exponential erosion constant


% estimations (ER_hats, 1 = linear; 2 = exponential)
ER_hat{1} = b + tau*m;
ER_hat{2} = c * exp(tau*d);
ER_bar = mean(ER);

SSR{1} = sum( (ER_hat{1} - ER_bar).^2 );
SSR{2} = sum( (ER_hat{2} - ER_bar).^2 );

SSE{1} = sum( (ER - ER_hat{1}).^2 );
SSE{2} = sum( (ER - ER_hat{2}).^2 );

SST{1} = sum( (ER - ER_bar).^2 );
SST{2} = sum( (ER - ER_bar).^2 );

CoD{1}(1) = SSR{1}/SST{1};
CoD{2}(1) = SSR{2}/SST{2};

figure(5)
hold on
grid on
box on

leg_str = {'Erosion data', 'Linear fit', 'Exponential fit'};

h(2) = plot(x,y{1},'b-');
h(3) = plot(x,y{2},'g--');
h(1) = plot(tau, ER, 'ko');
legend(h, leg_str, 'location','NorthEast')
set(h(1), 'MarkerSize',7, 'MarkerFaceColor','k')
set(h(2:3), 'LineWidth',2)
set(gca, 'TickDir', 'out')
axis([0 22 0 1]);
xlabel('Bed Shear Stress, $\tau$ (Pa)')
ylabel('Erosion Rate, $E$, (kg/m\ssu{2}/s)')


%% 4B-1
clear n tau ER xhat b m c d x y h x_hat ans ER_lin ER_exp SSR SST SSE CoD 
clear tc_lin tc_exp tc_pwl x1 x2 y1 y2 m1 m2 b1 b2 in int a M M1 M2 leg_str
clear LER E_c ER_bar ER_hat seL seX seP

n = queryStruct(FSD, 'name','4B', 'num','1');   % index of 1C-1
tau = [FSD(n).tau{1}];                          % bed shear stress (Pa)
ER = [FSD(n).LER{1}] * FSD(n).rhod / 1000;      % erosion rate (kg/m^2/s)
x = linspace(0,22);                                  % x-vector for estimations
E_c = 0.0019;                                   % critical erosion rate for exp. curves

% linear fit
[xhat seL] = lsq_linFit(tau,ER,1);
b = xhat(1);                    % y intercept
m = xhat(2);                    % slope of the best fit line
y{1} = b + m*x;                 % estimating of ER using m and b
tc_lin = -b/m;                  % critical shear stress (tau @ ER = 0)
M = tc_lin * m;                 % linear erosion constant

% exponential fit
[c d seX] = lsq_expFit(tau,ER);
y{2} = c * exp(x*d);                    % estimate ER using c and d
tc_exp = log(E_c/c)/d;                  % critical shear stress (tau @ ER = E_c)
a = d * (x(1) - tc_exp)./((x(1)/tc_exp) - 1);  % exponential erosion constant


% estimations (ER_hats, 1 = linear; 2 = exponential)
ER_hat{1} = b + tau*m;
ER_hat{2} = c * exp(tau*d);
ER_bar = mean(ER);

SSR{1} = sum( (ER_hat{1} - ER_bar).^2 );
SSR{2} = sum( (ER_hat{2} - ER_bar).^2 );

SSE{1} = sum( (ER - ER_hat{1}).^2 );
SSE{2} = sum( (ER - ER_hat{2}).^2 );

SST{1} = sum( (ER - ER_bar).^2 );
SST{2} = sum( (ER - ER_bar).^2 );

CoD{1}(1) = SSR{1}/SST{1};
CoD{2}(1) = SSR{2}/SST{2};

figure(6)
hold on
grid on
box on

leg_str = {'Erosion data', 'Linear fit', 'Exponential fit'};

h(2) = plot(x,y{1},'b-');
h(3) = plot(x,y{2},'g--');
h(1) = plot(tau, ER, 'ko');
legend(h, leg_str, 'location','NorthEast')
set(h(1), 'MarkerSize',7, 'MarkerFaceColor','k')
set(h(2:3), 'LineWidth',2)
set(gca, 'TickDir', 'out')
axis([0 22 0 10]);
xlabel('Bed Shear Stress, $\tau$ (Pa)')
ylabel('Erosion Rate, $E$, (kg/m\ssu{2}/s)')


%% 4B-2
clear n tau ER xhat b m c d x y h x_hat ans ER_lin ER_exp SSR SST SSE CoD 
clear tc_lin tc_exp tc_pwl x1 x2 y1 y2 m1 m2 b1 b2 in int a M M1 M2 leg_str
clear LER E_c ER_bar ER_hat seL seX seP

n = queryStruct(FSD, 'name','4B', 'num','1');   % index of 1C-1
tau = [FSD(n).tau{2}];                          % bed shear stress (Pa)
ER = [FSD(n).LER{2}] * FSD(n).rhod / 1000;      % erosion rate (kg/m^2/s)
x = linspace(0,22);                                  % x-vector for estimations
E_c = 0.0019;                                   % critical erosion rate for exp. curves

% linear fit
[xhat seL] = lsq_linFit(tau,ER,1);
b = xhat(1);                    % y intercept
m = xhat(2);                    % slope of the best fit line
y{1} = b + m*x;                 % estimating of ER using m and b
tc_lin = -b/m;                  % critical shear stress (tau @ ER = 0)
M = tc_lin * m;                 % linear erosion constant

% exponential fit
[c d seX] = lsq_expFit(tau,ER);
y{2} = c * exp(x*d);                    % estimate ER using c and d
tc_exp = log(E_c/c)/d;                  % critical shear stress (tau @ ER = E_c)
a = d * (x(1) - tc_exp)./((x(1)/tc_exp) - 1);  % exponential erosion constant


% estimations (ER_hats, 1 = linear; 2 = exponential)
ER_hat{1} = b + tau*m;
ER_hat{2} = c * exp(tau*d);
ER_bar = mean(ER);

SSR{1} = sum( (ER_hat{1} - ER_bar).^2 );
SSR{2} = sum( (ER_hat{2} - ER_bar).^2 );

SSE{1} = sum( (ER - ER_hat{1}).^2 );
SSE{2} = sum( (ER - ER_hat{2}).^2 );

SST{1} = sum( (ER - ER_bar).^2 );
SST{2} = sum( (ER - ER_bar).^2 );

CoD{1}(1) = SSR{1}/SST{1};
CoD{2}(1) = SSR{2}/SST{2};

figure(7)
hold on
grid on
box on

leg_str = {'Erosion data', 'Linear fit', 'Exponential fit'};

h(2) = plot(x,y{1},'b-');
h(3) = plot(x,y{2},'g--');
h(1) = plot(tau, ER, 'ko');
legend(h, leg_str, 'location','NorthEast')
set(h(1), 'MarkerSize',7, 'MarkerFaceColor','k')
set(h(2:3), 'LineWidth',2)
set(gca, 'TickDir', 'out')
axis([0 22 0 10]);
xlabel('Bed Shear Stress, $\tau$ (Pa)')
ylabel('Erosion Rate, $E$, (kg/m\ssu{2}/s)')