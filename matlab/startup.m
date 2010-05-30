% OS = pwd;
% if strcmp(OS, 'g:\work')
%     addpath G:\work\
%     addpath G:\work\BasicStats
%     addpath G:\work\MiscUtil
%     addpath G:\work\Datasets
%     addpath G:\work\MatrixDiff
%     addpath G:\work\Erosion
%     addpath G:\work\Calibrations
%     addpath G:\work\Figures
%     addpath G:\work\Rheo
%     cd G:\work
%     clear all
%     load G:\work/datasets/erosion
%     
% elseif strcmp(OS, 'e:\work')
%     addpath E:\work\
%     addpath E:\work\BasicStats
%     addpath E:\work\MiscUtil
%     addpath E:\work\Datasets
%     addpath E:\work\MatrixDiff
%     addpath E:\work\Erosion
%     addpath E:\work\Calibrations
%     addpath E:\work\Figures
%     addpath E:\work\Rheo
%     cd E:\work
%     clear all
%     load E:\work/datasets/erosion
% else
%     addpath /Volumes/GTG611A_FD/work/
%     addpath /Volumes/GTG611A_FD/work/BasicStats
%     addpath /Volumes/GTG611A_FD/work/MiscUtil
%     addpath /Volumes/GTG611A_FD/work/Datasets
%     addpath /Volumes/GTG611A_FD/work/MatrixDiff
%     addpath /Volumes/GTG611A_FD/work/Erosion
%     addpath /Volumes/GTG611A_FD/work/Calibrations
%     addpath /Volumes/GTG611A_FD/work/Figures
%     addpath /Volumes/GTG611A_FD/work/Rheo
%     cd /Volumes/GTG611A_FD/work
%     clear all
%     load /Volumes/GTG611A_FD/work/datasets/erosion
% end

addpath /Users/paul/Documents/School/Thesis/work/
addpath /Users/paul/Documents/School/Thesis/work/BasicStats
addpath /Users/paul/Documents/School/Thesis/work/MiscUtil
addpath /Users/paul/Documents/School/Thesis/work/Datasets
addpath /Users/paul/Documents/School/Thesis/work/MatrixDiff
addpath /Users/paul/Documents/School/Thesis/work/Erosion
addpath /Users/paul/Documents/School/Thesis/work/Calibrations
addpath /Users/paul/Documents/School/Thesis/work/Figures
addpath /Users/paul/Documents/School/Thesis/work/Rheo
clear all
load /Users/paul/Documents/School/Thesis/work/datasets/erosion

set(0, 'defaulttextinterpreter', 'none')
beep off










% set(0,'defaulttextinterpreter','none')



% % first LVDT calibration
% x1 = lvdtCalibration('calib1_', 'displacement1');
%
% % second LDVT calibration
% x2 = lvdtCalibration('calib2_', 'displacement2');
%
% % Calibration factor is the average of two results
% V2mm = mean([x1 x2])
%
% % calibrate hydrometer
% CF = hydrometerCalibration('hydrometer')
