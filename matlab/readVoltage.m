 function [f, t, d] = readVoltage(N, base_filename, calFact)
% READ VOLTAGE VALUES AND SAMPLING FREQUENCY FROM ONE OR MULTIPLE
% POTENTIOMETER DATA RECORDS
% This function takes a number of files (N) with a standard filename and a
% calibration factor (calFact, to be loaded at startup) and reads the 
% voltages to spit out a displacement vector in millimeters with a 
% corresponding time vector in seconds.  If N is 1, then basic vectors are
% used during the fuction and in the output.  If N is greater than 1, cell 
% arrays are used to account for datafiles of different lengths.  Files 
% should be created with erosion_daq.vi in the /work/ directory.
%
% Input:
%   N - number of files to be read
%   base_filename - the basic, serialized files to read if N > 1.
%       Otherwise, just the filename of the one file to be read (N = 1).
%       No file extension should be included in this variable though the
%       actuall file should be a *.txt file.
%   calFact - calibration factor to convert from voltage reading (V) to
%       potentiometer cable extension (piston displacement) in mm.
%       Sample sets 1 and 2 should use V2mm(1).  Sample sets 3, 4, and 5
%       should use V2mm(2).
%
% Output:
%   t - time vector (or cell array of vectors).  The first entry in each
%       data file is the sampling frequency.  This value is used to create
%       time values corresponding to each voltage reading.  Units are in
%       seconds.
%   d - displacement vector or cell array of vectors.  All of the
%       non-sampling frequency values in the data file are converting to
%       displacement (millimeters) using the calibration factor.
%   f - sampling frequency of data record (Hz)
%
%
% Other functions called:
%   smoothData.m - this function reduces some of the basic "noisiness" of
%   the potentiometer data records.  Input variables 'del' and 'type' are
%   fed directly into this function.
%
% Examples:
%   A single file:
%       [t4, d4] = readVoltage(1, '3B_Ex4', V2mm(2), 2);
%       This will read only 3B_Ex4.txt and spit out vectors t4 and d4 that
%       are ready for plotting and manipulation.
%
%   Multiple files
%       [t, d] = readVoltage(4, '2B_', V2mm(1), 12);
%       Will read files 2B_1.txt, 2B_2.txt...2B_4.txt.  To access the time
%       and displacement records for any Nth file, use t{N} and d{N}.
%
%   See also smoothData.

if N == 1

    filename = [base_filename, '.txt'];         % file being read
    tmp = dlmread(filename);                    % data from file

    % examine sampling frequency and assign output for f and determine
    % smoothData.m input 'del' and 'type'.
    if tmp(1) <= 10
        type = 'roll';
        del = ceil(tmp(1)/4);
        f = tmp(1);

    elseif tmp(1) > 10 && tmp(1) <= 50
        type = 'roll';
        del = ceil(tmp(1)/5);
        f = tmp(1);

    elseif tmp(1) > 50 && tmp(1) <=100
        type = 'step';
        del = ceil(tmp(1)/10);
        f = round(tmp(1)/del);
        
    elseif tmp(1) > 100 
        type = 'step';
        del = ceil(tmp(1)/10);
        f = round(tmp(1)/del);
    end

    d1 = tmp(2:end) * calFact;                  % displacement data
    d = smoothData(d1, del, type);              % smoothing function for data
    t = (0 : 1 : (length(d)-1))'/f;             % time vector for data

elseif N > 1

    for n = 1:N
        filename = [base_filename, num2str(n), '.txt'];     % file being read
        tmp = dlmread(filename);                            % data from file

        % examine sampling frequency and assign output for f and determine
        % smoothData.m input 'del' and 'type'.
        if tmp(1) <= 10
            type = 'roll';
            del = ceil(tmp(1)/4);
            f{n} = tmp(1);

        elseif tmp(1) > 10 && tmp(1) <= 50
            type = 'roll';
            del = ceil(tmp(1)/5);
            f{n} = tmp(1);

        elseif tmp(1) >= 50
            type = 'step';
            del = ceil(tmp(1)/20);
            f{n} = round(tmp(1)/del);
        end


        d1{n} = tmp(2:end) * calFact;                       % displacement data
        d{n} = smoothData(d1{n}, del, type);                % smoothing function for data
        t{n} = (0:1:(length(d{n})-1))'/f{n};                % time vector for data
    end

end