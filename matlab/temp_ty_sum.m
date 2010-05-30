% %%
% x = 0:425;
% % for n = 1:length(FSD)
% for n = 5
%     if ~isempty(FSD(n).tauy)
%         figure(n)
%         title([FSD(n).county FSD(n).depth])
%         %         subplot(2,1,1)
%         hold on
%         y1 = FSD(n).Xys(1,1) * exp(FSD(n).Xys(2,1).*x);
%         y2 = FSD(n).Xys(1,2) * exp(FSD(n).Xys(2,2).*x);
%         plot(FSD(n).tauy(:,1), FSD(n).tauy(:,3), 'ko')%, 'MarkerFaceColor', 'k');
%         plot(FSD(n).tauy(:,1), FSD(n).tauy(:,4), 'ko', 'MarkerFaceColor', 'k');
%         plot(x,y1, 'k--')
%         plot(x,y2, 'k-')
%         xlabel('Water Content (\%)')
%         ylabel('Yield Stress (Pa)')
%         %         title(['Sample ' FSD(n).name ' - ' FSD(n).num])
%         grid on
%         set(gca, 'TickDir', 'out', 'YScale', 'log')
%         axis([0 425 0.01 100])
%         box on
%         legend('Lower Yield Stress', 'Upper Yield Stress', 'Location' ,'SouthEast')
%         hold off
% 
%         %         subplot(2,1,2)
%         %         hold on
%         %         semilogy(FSD(n).tauy(:,2), FSD(n).tauy(:,3), 'ko')%, 'MarkerFaceColor', 'k');
%         %         semilogy(FSD(n).tauy(:,2), FSD(n).tauy(:,4), 'ko', 'MarkerFaceColor', 'k');
%         %         xlabel('Bulk Density  (kg/m\ssu{3})')
%         % %         ylabel('Lower Yield Stress (Pa)')
%         % %         title(['Sample ' FSD(n).name ' - ' FSD(n).num])
%         %         grid on
%         %         set(gca, 'TickDir', 'out', 'YScale', 'log')
%         %         axis([800 1200 0.01 100])
%         %         box on
%         %         legend('Lower Yield Stress', 'Upper Yield Stress', 'Location' ,'SouthEast')
%         %         hold off
% 
%         %         subplot(2,2,3)
%         %         semilogy(FSD(n).tauy(:,1), FSD(n).tauy(:,4), 'ko', 'MarkerFaceColor', 'k');
%         %         xlabel('Water Content (\%)')
%         %         ylabel('Upper Yield Stress (Pa)')
%         % %         title(['Sample ' FSD(n).name ' - ' FSD(n).num])
%         %         grid on
%         %         set(gca, 'TickDir', 'out')
%         %         axis([0 425 0.01 100])
%         %
%         %         subplot(2,2,4)
%         %         semilogy(FSD(n).tauy(:,2), FSD(n).tauy(:,4), 'ko', 'MarkerFaceColor', 'k');
%         %         xlabel('Bulk Density  (kg/m\ssu{3})')
%         % %         ylabel('Upper Yield Stress (Pa)')
%         % %         title(['Sample ' FSD(n).name ' - ' FSD(n).num])
%         %         grid on
%         %         set(gca, 'TickDir', 'out')
%         %         axis([800 1200 0.01 100])
% 
%         %         filename = ['fig_' FSD(n).name '_ys_sum'];
%         %         cd /Users/paul/Documents/School/Thesis/Thesis/tex
%         %         laprint(gcf, filename, 'width', 6*2.54, 'figcopy','off')
%         %         cd /Users/paul/Documents/School/Thesis/work
%     end
% 
% 
% end
%%
n = 2; % sample 2A
x = 0:425; % x-scale
WC = 150;
a1 = FSD(n).Xys{1}(1,2);
b1 = FSD(n).Xys{1}(2,2);
a2 = FSD(n).Xys{2}(1,2);
b2 = FSD(n).Xys{2}(2,2);
y1 = a1 * exp(b1.*x);     % best fit of lower ys
y2 = a2 * exp(b2.*x);     % best fit of lower ys

% 

figure(1)
clf
hold on
h1 = plot(FSD(n).tauy(:,1), FSD(n).tauy(:,3), 'ko', 'MarkerSize', 7);
text(105, 0.42, ['$\hat{\tau}_{y1} = ', num2str(a1,'%0.0f'), '\, e^{', num2str(b1*100,'%0.3g'), 'w}$\\'...
    '$R^2 = ' , num2str(FSD(n).ysSt{1}(4,2),'%0.3g'),'$\\',...
    '$SE = ' , num2str(FSD(n).ysSt{1}(3,2),'%0.3g'),'$ Pa'],...
    'FontSize', 11)
% text(318.5, 0.95, '$\swarrow$')


h2 = plot(FSD(n).tauy(:,1), FSD(n).tauy(:,4), 'ko', 'MarkerFaceColor', 'k', 'MarkerSize', 7);
text(172, 10.05, ['$\hat{\tau}_{y2} = ', num2str(a2,'%0.0f'), '\, e^{', num2str(b2*100,'%0.3g'), 'w}$\\',...
    '$R^2 = ' , num2str(FSD(n).ysSt{2}(4,2),'%0.3g'),'$\\',...
    '$SE = ' , num2str(FSD(n).ysSt{2}(3,2),'%0.3g'),'$ Pa'],...
    'FontSize', 11)
% text(318.5, 15.5, '$\swarrow$')


h3 = plot(x,y1, 'k--', 'LineWidth', 2);
h4 = plot(x,y2, 'k-', 'LineWidth', 2);

h5 = plot([WC WC], [0.01 100], 'k-');
% text(WC - 5, 0.022, '\textit{In situ} water content', 'rotation', 90)

h6 = plot([WC WC], [FSD(n).YS{1}(2) FSD(n).YS{2}(2)], 'kp', 'MarkerSize',10, 'MarkerFaceColor', 'r');
% text(WC+2, FSD(n).YS(1)+0.7, '$\swarrow$')
% text(WC+13.2, FSD(n).YS(1)+1.7, ['$\tau^{*}_{y1} = ', num2str(FSD(n).YS(1), '%0.3g'), '$ Pa'])

% text(WC+2, FSD(n).YS(2)+5.5, '$\swarrow$')
% text(WC+13.2, FSD(n).YS(2)+12, ['$\tau^{*}_{y2} = ', num2str(FSD(n).YS(2), '%0.3g'), '$ Pa'])

xlabel('Water Content, $w$ (\%)','FontSize', 11)
ylabel('Yield Stress, $\tau_y$ (Pa)','FontSize', 11)
grid on
set(gca, 'TickDir', 'out', 'YScale', 'log','FontSize', 11)
axis([100 200 0.1 100])
box on
legend([h1 h2 h6], {'Lower yield stress', 'Upper yield stress', ...
    'Estimated yield stress at $w = 150$\%'}, 'Location' ,'NorthEast',...
    'FontSize', 11)
hold off

exFig(gcf, 'fig_ex_up_low_ys', 6,3)














