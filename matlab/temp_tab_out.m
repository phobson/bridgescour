%%
n = 2;
figure(n)
x1 = FSD(n).tauy;
x2 = FSD(n).Xys;
hold on
plot(x1(:,1), x1(:,3), 'ko')
hold on
plot(x1(:,1), x1(:,4), 'bs')
set(gca, 'YScale', 'log')
grid on
x = linspace(100,350);
clc
ty1 = x2(1,1) * exp(x.*x2(2,1));
hold on
plot(x,ty1, 'k-')
ty2 = x2(1,2) * exp(x.*x2(2,2));
plot(x,ty2, 'b--')
%% lower yield stress summary table
clc
% m =1 for lower, m = 2 for upper
m = 1;

R2 = [];
SE = [];
SE_ty = [];

for n = [1 2 5 6 7 8 10 12 13 15]
t0 = [FSD(n).county, ' ', FSD(n).depth];
t1 = num2str(FSD(n).WC*100, '%0.3g');
t2 = num2str(FSD(n).ysSt{m}(4,1), '%0.3g');
t3 = num2str(FSD(n).ysSt{m}(3,1), '%0.3g');
t4 = num2str(FSD(n).YS{m}(1), '%0.3g');
t5 = num2str(FSD(n).ysSt{m}(3,1)/FSD(n).YS{m}(1), '%0.3g');
t6 = num2str(FSD(n).ysSt{m}(4,2), '%0.3g');
t7 = num2str(FSD(n).ysSt{m}(3,2), '%0.3g');
t8 = num2str(FSD(n).YS{m}(2), '%0.3g');
t9 = num2str(FSD(n).ysSt{m}(3,2)/FSD(n).YS{m}(2), '%0.3g');
t = ['\multicolumn{2}{l}{', t0, '} & ', t4, ' & ', t2, ...
    ' & ', t3, ' & ', t5, ' & ', t8, ' & ' t6, ' & ' t7,  ' & ', t9, ' \\']

R2 = [R2; FSD(n).ysSt{m}(4,1) FSD(n).ysSt{m}(4,2)];
SE = [SE; FSD(n).ysSt{m}(3,1) FSD(n).ysSt{m}(3,2)];
SE_ty = [SE_ty; FSD(n).ysSt{m}(3,1)/FSD(n).YS{m}(1) FSD(n).ysSt{m}(3,2)/FSD(n).YS{m}(2)];
end

mean(R2)
mean(SE)
mean(SE_ty)


% %%
% m = 1
% R2 = [];
% SE = [];
% SE_ty = []
% for n = [1 2 5 6 7 8 10 12 13 15]
