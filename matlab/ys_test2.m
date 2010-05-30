%%
file = '4Ays_4.txt';
x = dlmread(file, '\t', 2, 0);
gam = x(:,1);
tau = x(:,2);


tH = logspace(-1,2);

inA = [61 72];
inB = [92 105];


figure(1)
clf
hold on
h1 = loglog(tau,gam,'k.');
h2 = loglog(tau(inA(1):inA(2)),gam(inA(1):inA(2)),'bo');
h4 = loglog(tau(inB(1):inB(2)),gam(inB(1):inB(2)),'go');

set(gca, 'YScale', 'log', 'XScale', 'log')
set(h2, 'MarkerSize', 8)

axis([0.01 100 10^-4 10^5])
% hold off

clear x gam tau tH h1 h2 h4 inA inB file


%%
figure
hold on
d1 = FSD(7).tauy;
d2 = FSD(8).tauy;

h(1,1) = plot(d1(:,1), d1(:,3), 'ko');
h(1,2) = plot(d2(:,1), d2(:,3), 'ks');
set(h(1,:), 'MarkerSize',7, 'MarkerFaceColor','k')


[a b] = lsq_powerFit(d1(:,1), d1(:,3));
[c d] = lsq_powerFit(d2(:,1), d2(:,3));

x = logspace(1,3);
y1 = a * x.^b;
y2 = c * x.^d;

h(2,1) = plot(x,y1,'b-');
h(2,2) = plot(x,y2,'g-');
grid on
box on
set(h(2,:), 'LineWidth', 2)
set(gca, 'XScale','log', 'YScale','log')
% set(gca, 'XMinorGrid','off', 'YMinorGrid','off')
xlabel('Water Content (%)')
ylabel('Yield Stress (Pa)')
axis([10 1000 0.1 100])

