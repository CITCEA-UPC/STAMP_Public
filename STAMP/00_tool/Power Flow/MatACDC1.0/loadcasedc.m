function [baseMVAac, baseMVAdc, pol, busdc, convdc, branchdc] = loadcasedc(casefile)

% LOADCASEDC Load dc system data (in .m, .mat or data struct)
%   [BASEMVAAC, BASEMVADC, POL, BUSDC, CONVDC, BRANCHDC] = LOADCASEDC(...
%   CASEFILEDC)   
%   MPCDC = LOADCASEDC(CASEFILEDC)   
% 
%   Returns the individual data matrices.
%   Here CASEFILEDC is either (1) a struct containing the fields baseMVAac,
%   baseMVAdc, pol, busdc, convdc, branchdc, or (2) a string containing the
%    name of the file. 
%
%   Inputs:
%       CASEFILEDC : struct or .m-file or .mat-file with dc grid data
%
%   Outputs:
%       BASEMVAAC : apparent power base of ac quantatities
%       BASEMVADC : apparent power base of dc quantatities
%       POL : topology of dc grids
%       BUSDC : dc bus matrix
%       CONVDC : dc converter matrix
%       BRANCHDC : dc branch matrix   
%
%   Alternatively to loading the individual data matrices, it is also 
%   possible to load the outputs in a data struct.

%   MatACDC
%   Copyright (C) 2012 Jef Beerten
%   University of Leuven (KU Leuven)
%   Dept. Electrical Engineering (ESAT), Div. ELECTA
%   Kasteelpark Arenberg 10
%   3001 Leuven-Heverlee, Belgium

%%file based on MATPOWER4.1 loadcase.m file

info = 0;
if nargout < 2
    return_as_struct = true;
else
    return_as_struct = false;
end


%%-----  read data into struct  -----
if ischar(casefile)
    %% check for explicit extension
    l = length(casefile);
    if l > 2
        if strcmp(casefile(l-1:l), '.m')
            rootname = casefile(1:l-2);
            extension = '.m';
        elseif l > 4
            if strcmp(casefile(l-3:l), '.mat');
                rootname = casefile(1:l-4);
                extension = '.mat';
            end
        end
    end

    %% set extension if not specified explicitly
    if ~exist('rootname', 'var')
        rootname = casefile;
        if exist([casefile '.mat'], 'file') == 2
            extension = '.mat';
        elseif exist([casefile '.m'], 'file') == 2
            extension = '.m';
        else
            info = 2;
        end
    end
    
    %% attempt to read file
    if info == 0
        if strcmp(extension,'.mat')         %% from MAT file
            try
                s = load(rootname);
                if isfield(s, 'mpc')        %% it's a struct
                    s = s.mpc;
                else                        %% individual data matrices
                    s.version = '1';
                end
            catch
                info = 3;
            end
        elseif strcmp(extension,'.m')       %% from M file
            try                             %% assume it returns a struct
                s = feval(rootname);
            catch
                info = 4;
            end
            if info == 0 && ~isstruct(s)    %% if not try individual data matrices
                clear s;
                s.version = '1';
                    if return_as_struct
                        try
                            [s.baseMVAac, s.baseMVAdc, s.pol, s.busdc, ...
                                s.convdc, s.branchdc] = feval(rootname);
                        catch
                            try
                                [s.baseMVAac, s.baseMVAdc, s.pol, s.busdc, ...
                                    s.convdc, s.branchdc] = feval(rootname);
                            catch
                                info = 4;
                            end
                        end
                    else
                        try
                            [s.baseMVAac, s.baseMVAdc, s.pol, s.busdc, ...
                                s.convdc, s.branchdc] = feval(rootname);
                        catch
                            info = 4;
                        end
                    end
            end
            if info == 4 && exist([rootname '.m'], 'file') == 2
                info = 5;
                err5 = lasterr;
            end
        end
    end
elseif isstruct(casefile)
    s = casefile;
else
    info = 1;
end


%%-----  check contents of struct  -----
if info == 0
    %% check for required fields
    if ~( isfield(s,'baseMVAac') && isfield(s,'baseMVAdc') && ...
        isfield(s,'busdc') && isfield(s,'convdc') && ...
        isfield(s,'branchdc') ) 
        info = 5;           %% missing some expected fields
        err5 = 'missing data';
    else
        %% all fields present, copy to mpc
        mpc = s;
    end
end

%%-----  define output variables  -----
if return_as_struct
    bus = info;
end

if info == 0    %% no errors
    %% add voltage droop parameters if not defined in input files
    if size(mpc.convdc,2)<24
        ii = 24-size(mpc.convdc,2);
        mpc.convdc(:,[25-ii: 24]) = zeros(size(mpc.convdc,1),ii);
    end
    
    if return_as_struct
        baseMVAac = mpc;
    else
        baseMVAac   = mpc.baseMVAac;
        baseMVAdc   = mpc.baseMVAdc;
        pol         = mpc.pol;
        busdc       = mpc.busdc;
        convdc      = mpc.convdc;
        branchdc    = mpc.branchdc;
    end
else            %% we have a problem captain
    if nargout == 2 || nargout == 7   %% return error code
        if return_as_struct
            baseMVA = struct([]);
        else
            baseMVA = []; bus = []; gen = []; branch = [];
            areas = []; gencost = [];
        end
    else                                            %% die on error
        switch info
            case 1,
                error('loadcasedc: input arg should be a struct or a string containing a filename');
            case 2,
                error('loadcasedc: specified case not in MATLAB''s search path');
            case 3,
                error('loadcasedc: specified MAT file does not exist');
            case 4,
                error('loadcasedc: specified M file does not exist');
            case 5,
                error('loadcasedc: syntax error or undefined data matrix(ices) in the file\n%s', err5);
            otherwise,
                error('loadcasedc: unknown error');
        end
    end
end

return;