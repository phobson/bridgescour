% tau = t_hb + k*gam_dot^m

t_hb = 2.5;
gam_dot = logspace(-4,1,100);
k = 2;

tau{1} = k.*gam_dot;
tau{2} = t_hb + k.*gam_dot.^0.33;
tau{3} = t_hb + k.*gam_dot;
tau{4} = t_hb + k.*gam_dot.^2.5;

line = {'-', '-', '-', '-'};
leg_str = {'Newtonian', 'Non-Newtonian'};

figure
hold on
for n = 1:4
  h(n) = plot(gam_dot, tau{n}, 'k', 'LineWidth', 2, 'LineStyle', line{n});
end

text(gam_dot(50), tau{1}(50)+0.2, 'Newtonian, $\tau_y = 0,\;m = 1,\;k = \eta$', 'Rotation', 13.5, 'FontSize', 11);
text(gam_dot(75), tau{2}(65)+0.70, '$\searrow$', 'FontSize', 11);
text(gam_dot(64), tau{2}(65)+0.80, 'Yield Pseudo-Plastic, $m < 1$', 'Rotation', 0, 'FontSize', 11);
text(gam_dot(65), tau{3}(65)+0.19, 'Bingham Plastic Model, $m = 1, \;k = \eta$', 'Rotation', 13.5, 'FontSize', 11);
text(gam_dot(60), tau{4}(40)-0.15, '$\nwarrow$', 'FontSize', 11);
text(gam_dot(62)+0.0075, tau{4}(40)-0.25, 'Yield Dilatant, $m > 1$', 'Rotation', 0, 'FontSize', 11);

% legend(h(1:2), leg_str, 'Location', 'NorthWest')
axis([0 1 0 5])
set(gca, 'YTick', [0 2.5 5], ...
          'YTickLabel', {'' '$\tau_y$' ''},...
          'XTick', [0 0.5 1], ...
          'XTickLabel', {'' '' ''},...
          'TickDir', 'out', 'FontSize', 11)
box on
xlabel('Strain Rate, $\dot{\gamma}$', 'FontSize', 11)
ylabel('Shear Stress, $\tau = \tau_y + k\dot{\gamma}^m$', 'FontSize', 11)
exFig(gcf, 'fig_rheoCurves', 5, 3)