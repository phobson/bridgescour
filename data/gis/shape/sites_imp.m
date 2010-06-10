% plot Physiographic regions
figure(1)
title('Physiographic Regions')
clf
hold on
axis([-3*10^5 3*10^5 0.75*10^6 1.35*10^6])
axis equal
box on

for n = 1:length(gisPhys)
    p(n) = fill(gisPhys(n).X, gisPhys(n).Y, [n n n]/7);
end

for n = 1:length(gisBridges)
    b(n) = plot(gisBridges(n).X, gisBridges(n).Y, 'ko');
    t(n) = text(gisBridges(n).X+10000, gisBridges(n).Y, ...
        gisBridges(n).COUNTY);
end

figure(2)
title('Major Land Resource Areas')
clf
hold on
axis([-3*10^5 3*10^5 0.75*10^6 1.35*10^6])
axis equal
box on

for n = 1:length(gisMLRA)
    p(n) = fill(gisMLRA(n).X, gisMLRA(n).Y, [n n n]/9);
end

for n = 1:length(gisBridges)
    b(n) = plot(gisBridges(n).X, gisBridges(n).Y, 'ko');
    t(n) = text(gisBridges(n).X+10000, gisBridges(n).Y, ...
        gisBridges(n).COUNTY);
end

clear p b t n
% %% GIS DATA
% n = 1;
% y = shaperead('bridges.shp');
% 
% gisBridges(1) = y(9);
% gisBridges(2) = y(8);
% gisBridges(3) = y(7);
% gisBridges(4) = y(6);
% gisBridges(5) = y(10);
% gisBridges(6) = y(5);
% gisBridges(7) = y(4);
% gisBridges(8) = y(3);
% gisBridges(9) = y(2);
% gisBridges(10) = y(1);
% gisBridges = gisBridges';
% % 
% % x{n} = shaperead('1.shp'); n = n + 1;
% % x{n} = shaperead('2.shp'); n = n + 1;
% % x{n} = shaperead('3.shp'); n = n + 1;
% % x{n} = shaperead('4.shp'); n = n + 1;
% % x{n} = shaperead('5s.shp'); n = n + 1;
% % x{n} = shaperead('6.shp'); n = n + 1;
% % x{n} = shaperead('7.shp'); n = n + 1;
% % x{n} = shaperead('8.shp'); n = n + 1;
% % x{n} = shaperead('9.shp'); n = n + 1;
% % x{n} = shaperead('10.shp'); n = n + 1;
% % x = x';
% %%
% % for n = [1 3 8 9]
% %     gisSites(n) = x{n};
% % end
% % 
% % gisSites(5) = x{1}(1);
% % 
% % for n = [2 4 6 7 10]
% % 
% %     gisSites(n).Geometry = x{n}.Geometry;
% %     gisSites(n).X= x{n}.X;
% %     gisSites(n).Y = x{n}.Y;
% % end
% %%