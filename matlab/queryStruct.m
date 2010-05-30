function ii = queryStruct(varargin)
% sueryStruct - QUERY DATA OUT OF A DATA STRUCTURE BASED ON CRITERIA 
% APPLIED TO UP TO THREE FIELDS
%   This function finds the indices of data stored in data structures based
% on criteria passed as inputs to the function.
%
% Inputs:
%   data_struct - data structure in which data is stored (req'd)
%   fname1  - field to which first criterion will be applied (req'd)
%   fvalue1 - first field value criterion (req'd)
%   fname2  - field to which second criterion will be applied (optional)
%   fvalue2 - second field value criterion (optional)
%   fname3  - field to which third criterion will be applied (optional)
%   fvalue3 - third field value criterion (optional)
%
% Outputs:
%   ii - vector of indices at which requested data records are stored
%
% Other functions called:
%   NONE
%
% Example:
%   >> ii = queryStruct(WCS, 'name','1B', 'type','hydrometer')

ii = [];
struct_in = varargin{1};
switch nargin
    case 0 
        error('Need a structure and some fields and values, bro')

    case 1
        error('OK, you got a structure, now try some fields and values, broham')
        
    case 2 
        error('Gimme a value and we''re in business, broham')

    case 3
        fname = varargin{2};
        fvalue = varargin{3};
        for n = 1:length(struct_in)
            if strcmp(getfield(struct_in(n),fname),fvalue);
                ii = [ii; n];
            end
        end

    case 4
        error('Almost got that last value in there, eh, brophalactic?')

    case 5
        fname1 = varargin{2}; fvalue1 = varargin{3};
        fname2 = varargin{4}; fvalue2 = varargin{5};
        for n = 1:length(struct_in)
            if (strcmp(getfield(struct_in(n),fname1),fvalue1) ...
                    && strcmp(getfield(struct_in(n),fname2),fvalue2));
                ii = [ii; n];
            end
        end

    case 7
        fname1 = varargin{2}; fvalue1 = varargin{3};
        fname2 = varargin{4}; fvalue2 = varargin{5};
        fname3 = varargin{6}; fvalue3 = varargin{7};
        for n = 1:length(struct_in)
            if (strcmp(getfield(struct_in(n),fname1),fvalue1) ...
                    && strcmp(getfield(struct_in(n),fname2),fvalue2)...
                    && strcmp(getfield(struct_in(n),fname3),fvalue3));
                ii = [ii; n];
            end
        end
        
    otherwise
        error('That''s it!  Get the hell out of my shop, bromeo!') 


end