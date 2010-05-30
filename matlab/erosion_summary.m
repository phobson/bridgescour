%% get the fits from FSD
N = [];     % first erosion test index
M = [];     % second erosion test index
x = 0;
LF = {};
EF = {};
tau = {};
ER = {};
for n = 1:length(FSD)
    if ~isempty(FSD(n).erD)
        x = x+1;
        LF{x} = FSD(n).erD{1,1};
        EF{x} = FSD(n).erD{1,2};
        tau{x} = FSD(n).tau{1};
        ER{x} = FSD(n).LER{1} * FSD(n).rhod/1000;
        leg_str{x} = [FSD(n).county ,' ', FSD(n).depth, ':  $tc$ = ', ...
            num2str(FSD(n).erS{1,1}(2,1), '%0.2f'), ' Pa'];
        
        leg_str3{x} = [FSD(n).county ,' ', FSD(n).depth, ':  $tc$ = ', ...
            num2str(FSD(n).erS{1,2}(2,1), '%0.2f'), ' Pa'];

        
        if size(FSD(n).erD,1) == 2
            x = x+1;
            LF{x} = FSD(n).erD{2,1};
            EF{x} = FSD(n).erD{2,2};
            tau{x} = FSD(n).tau{2};
            ER{x} = FSD(n).LER{2} * FSD(x).rhod/1000;
            leg_str{x} = [FSD(n).county ,' ', FSD(n).depth, ':  $tc$ = ', ...
                num2str(FSD(n).erS{2,1}(2,1), '%0.2f'), ' Pa'];
            leg_str3{x} = [FSD(n).county ,' ', FSD(n).depth, ':  $tc$ = ', ...
                num2str(FSD(n).erS{2,2}(2,1), '%0.2f'), ' Pa'];
           
        end
    end
end


% divide linear erosions up into fast and slow groups (fast = 2A, 4B-2)
% 2A -> n = 3l 4B-2 -> n = 7
blk = [0.00 0.00 0.00];
blu = [0.00 0.00 0.62];
grn = [0.00 0.60 0.00];
org = [1.00 0.30 0.00];
mrn = [0.40 0.00 0.00];

% dots = {'o' 'o' 's' '^' '^' 'd' 'd'};
% lines = {'--' '-' '--' '--' '-' '--' '-'};
% MEC = {'k' 'k' 'k' 'k' 'k' 'k' 'k'};
% MFC = {'none' 'k' 'none' 'none' 'k' 'none' 'k'};
dots = {'o' 'o' 's' '^' '^' 'd' 'd'};
lines = {'--' '-' '--' '--' '-' '--' '-'};
MEC = {'k' 'k' 'k' blu blu grn grn};
MFC = {'none' 'k' 'none' 'none' blu 'none' grn};


x = 0;
y = 0;
for n = 1:7
    if n == 3 || n == 7
        x = x + 1;
        LF1{x} = LF{n};
        EF1{x} = EF{n};
        tau1{x} = tau{n};
        ER1{x} = ER{n};
        leg_str1{x} = leg_str{n};
        dots1{x} = dots{n};
        lines1{x} = lines{n};
        MEC1{x} = MEC{n};
        MFC1{x} = MFC{n};
    else
        y = y + 1;
        LF2{y} = LF{n};
        EF2{y} = EF{n};
        tau2{y} = tau{n};
        ER2{y} = ER{n};
        leg_str2{y} = leg_str{n};
        dots2{y} = dots{n};
        lines2{y} = lines{n};
        MEC2{y} = MEC{n};
        MFC2{y} = MFC{n};
    end
end

% fast erosion
figure(1)
hold on
for n = length(tau1):-1:1
    h1(n,1) = plot(tau1{n}, ER1{n}, ['k' dots1{n}]);
    h1(n,2) = plot(LF1{n}(:,1),LF1{n}(:,2), ['k' lines1{n}]);
    axis([0 8 0 10])
    
    set(h1(n,1), 'MarkerSize',7, 'MarkerFaceColor', MFC1{n}, 'MarkerEdgeColor', MEC1{n})
    set(h1(n,2), 'LineWidth', 2, 'Color', MEC1{n}) 
   
end
set(gca, 'TickDir', 'out', 'FontSize', 11)
grid on
box on
xlabel('Bed Shear Stress, $\tau_b$ (Pa)', 'FontSize', 11)
ylabel('Erosion Rate, $E$ (kg/m\ssu{2}/s)', 'FontSize', 11)
legend(h1(:,1), leg_str1, 'Location', 'NorthWest', 'FontSize', 11)
hold off
exFig(gcf, 'fig_er_lin1', 5,3)


% slow erosion
figure(2)
hold on
for n = 1:length(tau2)
    h2(n,1) = plot(tau2{n}, ER2{n}, ['k' dots2{n}]);
    h2(n,2) = plot(LF2{n}(:,1),LF2{n}(:,2), ['k' lines2{n}]);
    axis([0 22 0 1])
    
    set(h2(n,1), 'MarkerSize',7, 'MarkerFaceColor', MFC2{n}, 'MarkerEdgeColor', MEC2{n})
    set(h2(n,2), 'LineWidth', 2, 'Color', MEC2{n}) 
   
end
set(gca, 'TickDir', 'out', 'FontSize', 11)
grid on
box on
xlabel('Bed Shear Stress, $\tau_b$ (Pa)', 'FontSize', 11)
ylabel('Erosion Rate, $E$ (kg/m\ssu{2}/s)', 'FontSize', 11)
legend(h2(:,1), leg_str2, 'Location', 'NorthEast', 'FontSize', 11)
hold off
exFig(gcf, 'fig_er_lin2', 5,4)



% % "fast" erosion - 2A & 4B-2
% figure(1)
% hold on
% h1(1,1) = plot(tau{3}, ER{3}, ['k', dots{3}]);
% h1(1,2) = plot(LF{3}(:,1), LF{3}(:,2), ['k' lines{3}]);
% h1(2,1) = plot(tau{7}, ER{7}, ['k', dots{7}]);
% h1(2,2) = plot(LF{7}(:,1), LF{7}(:,2), ['k' lines{7}]);
% 
% set(gca, 'TickDir', 'out')
% grid on
% box on
% xlabel('Bed Shear Stress, $\tau$ (Pa)')
% ylabel('Erosion Rate, $E$ (kg/m\ssu{2}/s)')
% legend(h1(:,1), leg_str1, 'Location', 'NorthEast')
% hold off
% exFig(gcf, 'fig_er_lin', 6,4)

figure(3)
hold on
for n = 4:5
    h3(n-3,1) = plot(tau{n}, ER{n}, ['k' dots{n}]);
    h3(n-3,2) = plot(EF{n}(:,1),EF{n}(:,2), ['k' lines{n}]);
    h4 = plot([0 22], [0.019 0.019], 'k-');
    axis([0 22 0 0.301])
    
    set(h3(n-3,1), 'MarkerSize',7, 'MarkerFaceColor', MFC{n}, 'MarkerEdgeColor', MEC{n})
    set(h3(n-3,2), 'LineWidth', 2, 'Color', MEC{n}) 
end
set(gca, 'TickDir', 'out', 'FontSize', 11)
text(0.5, 0.03, 'Critical erosion, $E_c = 0.0190$ kg/m\ssu{2}/s', 'FontSize', 11)
grid on
box on
xlabel('Bed Shear Stress, $\tau_b$ (Pa)', 'FontSize', 11)
ylabel('Erosion Rate, $E$ (kg/m\ssu{2}/s)', 'FontSize', 11)
hL = legend(h3(1:2,1), leg_str3{4:5});
set(hL, 'Location', 'NorthWest', 'FontSize', 11)
hold off
hold off
exFig(gcf, 'fig_er_exp', 5,3)


% LF = {};
% EF = {};
% tau = {};
% ER = {};
% for n = 1:length(FSD)
%     if ~isempty(FSD(n).erD)
%         LF = {LF; FSD(n).erD(1,1)};
%         EF = {EF; FSD(n).erD(1,2)};
%         
%         tau = {tau; FSD(n).tau(1)};
%         x = [FSD(n).LER(1)];
%         ER = {ER; x{1}*FSD(n).rhod/1000};
%         
%         if size(FSD(n).erD,1) == 2
%             LF = {LF; FSD(n).erD(2,1)};
%             EF = {EF; FSD(n).erD(2,2)};
%             
%             tau = {tau; FSD(n).tau(2)};
%             x = [FSD(n).LER(2)];
%             ER = {ER; x{1}.*FSD(n).rhod/1000};
% 
%         end
%     end
% end
% 
% 
% 
% 
% % %% erosion curves by sample location
% % %%%%% 1C 1C 1C %%%%%
% % N = queryStruct(FSD, 'name','1C', 'num','1');
% % tau{1} = FSD(N).tau{1};
% % ER{1} = FSD(N).LER{1} * FSD(N).rhod / 1000;
% % x{1} = FSD(N).x;
% % y{1} = FSD(N).y{1};
% % leg_str{1} = [FSD(N).county ,' ', FSD(N).depth, ':  $tc$ = ', num2str(FSD(N).tauc{1}, '%0.2f'), ' Pa'];
% %
% % N = queryStruct(FSD, 'name','1C', 'num','3');
% % tau{2} = FSD(N).tau{1};
% % ER{2} = FSD(N).LER{1} * FSD(N).rhod / 1000;
% % x{2} = FSD(N).x;
% % y{2} = FSD(N).y{1};
% % leg_str{2} = [FSD(N).county ,' ', FSD(N).depth, ':  $tc$ = ', num2str(FSD(N).tauc{1}, '%0.2f'), ' Pa'];
% %
% % figure
% % hold on
% % h(1,1) = plot(tau{1}, ER{1}, 'ko');
% % h(1,2) = plot(x{1}, y{1}, 'k-');
% % h(2,1) = plot(tau{2}, ER{2}, 'ko');
% % h(2,2) = plot(x{2}, y{2}, 'k--');
% %
% % set(h(1,1), 'MarkerSize',7, 'MarkerFaceColor','k')
% % set(h(:,2), 'LineWidth', 2);
% % set(gca, 'TickDir', 'out')
% % grid on
% % box on
% % legend(h(:,1), leg_str, 'Location', 'NorthEast')
% % axis([0 22 0 2])
% % xlabel('Bed Shear Stress, $\tau$ (Pa)')
% % ylabel('Erosion Rate, $E$ (kg/m\ssu{2}/s')
% % hold off
% % % exFig(gcf, 'fig_1erosion', 6, 4)
% % exFig(gcf, 'fig_1erosion', 5, 3)
% %
% % clear N tau ER x y leg_str h
% % %% erosion curves by sample location
% % %%%%% 2A 2B 2A 2B %%%%%
% % N = queryStruct(FSD, 'name','2A', 'num','1');
% % tau{1} = FSD(N).tau{1};
% % ER{1} = FSD(N).LER{1} * FSD(N).rhod / 1000;
% % x{1} = FSD(N).x;
% % y{1} = FSD(N).y;
% % leg_str{1} = [FSD(N).county ,' ', FSD(N).depth, ':  $tc$ = ', num2str(FSD(N).tauc{1}, '%0.2f'), ' Pa'];
% %
% % N = queryStruct(FSD, 'name','2B', 'num','1');
% % tau{2} = FSD(N).tau{1};
% % ER{2} = FSD(N).LER{1} * FSD(N).rhod / 1000;
% % x{2} = FSD(N).x;
% % y{2} = FSD(N).y{1};
% % leg_str{2} = [FSD(N).county ,' ', FSD(N).depth, ' (fine):  $tc$ = ', num2str(FSD(N).tauc{1}, '%0.2f'), ' Pa'];
% %
% % tau{3} = FSD(N).tau{2};
% % ER{3} = FSD(N).LER{2} * FSD(N).rhod / 1000;
% % x{3} = FSD(N).x;
% % y{3} = FSD(N).y{2};
% % leg_str{3} = [FSD(N).county ,' ', FSD(N).depth, ' (coarse):  $tc$ = ', num2str(FSD(N).tauc{2}, '%0.2f'), ' Pa'];
% %
% % figure
% % hold on
% % h(1,1) = plot(tau{1}, ER{1}, 'ks');
% % h(1,2) = plot(x{1}, y{1}, 'k-');
% % h(2,1) = plot(tau{2}, ER{2}, 'ko');
% % h(2,2) = plot(x{2}, y{2}, 'k--');
% % h(3,1) = plot(tau{3}, ER{3}, 'ko');
% % h(3,2) = plot(x{3}, y{3}, 'k-');
% %
% % set(h(1:2,1), 'MarkerSize',7, 'MarkerFaceColor','k')
% % set(h(:,2), 'LineWidth', 2);
% % set(gca, 'TickDir', 'out')
% % legend(h(:,1), leg_str, 'Location', 'NorthEast')
% % grid on
% % box on
% % axis([0 22 0 10])
% % xlabel('Bed Shear Stress, $\tau$ (Pa)')
% % ylabel('Erosion Rate, $E$ (kg/m\ssu{2}/s')
% % % exFig(gcf, 'fig_2erosion', 6, 4)
% % exFig(gcf, 'fig_2erosion', 5.5, 3.33)
% %
% % clear N tau ER x y leg_str h
% %
% % %% erosion curves by sample location
% % %%%%% 4B 4B 4B 4B %%%%%
% % N = queryStruct(FSD, 'name','4B', 'num','1');
% % tau{1} = FSD(N).tau{1};
% % ER{1} = FSD(N).LER{1} * FSD(N).rhod / 1000;
% % x{1} = FSD(N).x;
% % y{1} = FSD(N).y{1};
% % leg_str{1} = [FSD(N).county ,' ', FSD(N).depth, ' :  $tc$ = ', num2str(FSD(N).tauc{1}, '%0.2f'), ' Pa'];
% %
% % tau{2} = FSD(N).tau{2};
% % ER{2} = FSD(N).LER{2} * FSD(N).rhod / 1000;
% % x{2} = FSD(N).x;
% % y{2} = FSD(N).y{2};
% % leg_str{2} = [FSD(N).county ,' ', FSD(N).depth, ' :  $tc$ = ', num2str(FSD(N).tauc{2}, '%0.2f'), ' Pa'];
% %
% % figure
% % hold on
% % h(1,1) = plot(tau{1}, ER{1}, 'ko');
% % h(1,2) = plot(x{1}, y{1}, 'k-');
% % h(2,1) = plot(tau{2}, ER{2}, 'ko');
% % h(2,2) = plot(x{2}, y{2}, 'k--');
% %
% %
% % set(h(1,1), 'MarkerSize',7, 'MarkerFaceColor','k')
% % set(h(:,2), 'LineWidth', 2);
% % set(gca, 'TickDir', 'out')
% % legend(h(:,1), leg_str, 'Location', 'NorthEast')
% % grid on
% % box on
% % axis([0 22 0 10])
% % xlabel('Bed Shear Stress, $\tau$ (Pa)')
% % ylabel('Erosion Rate, $E$ (kg/m\ssu{2}/s')
% % % exFig(gcf, 'fig_4erosion', 6, 4)
% % exFig(gcf, 'fig_4erosion', 5, 3)
% %
% % clear N tau ER x y leg_str h
