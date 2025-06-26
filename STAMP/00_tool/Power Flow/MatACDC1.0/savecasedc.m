function fname_out = savecasedc(fname, baseMVAac, baseMVAdc, pol, ...
    busdc, convdc, branchdc)

% SAVECASEDC  Saves all dc data in a function power flow.
%   FNAME_OUT = SAVECASEDC(FNAME, BASEMVAAC, BASEMVADC, POL, ...
%   BUSDC, CONVDC, BRANCHDC)
%
%   11/3 To be extended to provide a functionality for structs...
%   overall code functionality should be increased, now written to be used
%   in the dynamic program

%   MatACDC
%   Copyright (C) 2011 Jef Beerten
%   Katholieke Universiteit Leuven
%   Dept. Electrical Engineering (ESAT), Div. ELECTA
%   Kasteelpark Arenberg 10
%   3001 Leuven-Heverlee, Belgium

%% define named indices into busdc, convdc, branchdc matrices
[BUSDC_I, BUSAC_I, GRIDDC, PDC, VDC, BASE_KVDC, VDCMAX, ...
    VDCMIN, CDC]=idx_busdc;
[F_BUSDC, T_BUSDC, BRDC_R, BRDC_L, BRDC_C, RATEDC_A, RATEDC_B, ...
    RATEDC_C, BRDC_STATUS, PFDC, PTDC]=idx_brchdc;
[DCDROOP, DCSLACK, DCNOSLACK, PVC, PQC, CONV_BUS, CONVTYPE_DC, ...
    CONVTYPE_AC, PCONV, QCONV, VCONV, RTF, XTF, BF, RCONV, XCONV, ...
    BASEKVC, VCMAX, VCMIN, ICMAX, CONVSTATUS, LOSSA, LOSSB, LOSSCR, ...
    LOSSCI, DROOP, PDCSET, VDCSET, DVDCSET, VMC, VAC, PCCONV, QCCONV, ...
    PCLOSS, VMF, VAF, PFIL, QCONVF, QCCONVF]=idx_convdc;

fd = 1;
prefix = 'mpc.';

extension = '.m';
rootname = fname;
fname = [fname, extension];

%% open file
[fd, msg] = fopen(fname, 'wt');     %% print to an M-file

%% function header, etc.
fprintf(fd, 'function mpc = %s\n',rootname); %,  [baseMVAac, baseMVAdc] pol, busdc, convdc, branchdcs
%     fprintf(fd, '\n%%%% MATPOWER Case Format : Version %s\n', mpc_ver);    

fprintf(fd, '\n%%%%-----  Power Flow Data DC networks  -----%%%%\n');
fprintf(fd, '\n%%%% system MVA bases\n');
fprintf(fd, '%sbaseMVAac = %g;\n', prefix, baseMVAac);
fprintf(fd, '%sbaseMVAdc = %g;\n', prefix, baseMVAdc);

fprintf(fd, '\n%%%% dc grid topology\n');
fprintf(fd, '%spol = %g; %%%% numbers of poles (1=monopolar grid, 2=bipolar grid)\n', prefix, pol);

%% bus data
fprintf(fd, '\n%%%% dc bus data\n');
fprintf(fd, '%%\tbusdc_i\tbusac_i\tgrid\tPdc\tVdc\tbasekVdc\tVdcmax\tVdcmin\tCdc');
fprintf(fd, '\n%sbusdc = [\n', prefix);
fprintf(fd, '\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d;\n', busdc(:, 1:end).');
fprintf(fd, '];\n');

%% converter data
fprintf(fd, '\n%%%% dc converter data\n');
fprintf(fd, '%%\tbusdc_i\ttype_dc\ttype_ac\tP_g\tQ_g\tVtar\trtf\txtf\tbf\trc\txc\tbasekVac\tVmmax\tVmmin\tImax\tstatus\tLossA\tLossB\tLossCrec\tLossCinv\tdroop\tPset\tVset\tdVset'); 
fprintf(fd, '\n%sconvdc = [\n', prefix);
fprintf(fd, '\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d;\n', convdc(:, 1:end).');
fprintf(fd, '];\n');

%% branch data
%% branches

fprintf(fd, '\n%%%% dc branch data\n');
fprintf(fd, '%%\tfbusdc\ttbusdc\tr\tl\tc\trateA\trateB\trateC\tstatus'); 
fprintf(fd, '\n%sbranchdc = [\n', prefix);
fprintf(fd, '\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d\t%d;\n', branchdc(:, 1:end).');
fprintf(fd, '];\n');


%% execute userfcn callbacks for 'savecasedc' stage
if isfield(mpc, 'userfcn')
    run_userfcn(mpc.userfcn, 'savecasedc', mpc, fd, prefix);
end

%% close file
if fd ~= 1
    fclose(fd);
end


%% save data
fname_out = fname;