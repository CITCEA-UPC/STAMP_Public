function printdcpf(busdc, convdc, branchdc)
%PRINTDCPF  Prints power flow results related to DC network and converters.
%   PRINTDCPF(BUSDC, CONVDC, BRANCHDC)
%
%   Prints all ac/dc power flow results related to dc grid and converters.
%
%   Inputs:
%       BUSDC : dc bus matrix
%       CONVDC : dc converter matrix
%       BRANCHDC : dc branch matrix

%   MatACDC
%   Copyright (C) 2012 Jef Beerten
%   University of Leuven (KU Leuven)
%   Dept. Electrical Engineering (ESAT), Div. ELECTA
%   Kasteelpark Arenberg 10
%   3001 Leuven-Heverlee, Belgium

%% define named indices into busdc, convdc, branchdc matrices
[BUSDC_I, BUSAC_I, GRIDDC, PDC, VDC, BASE_KVDC, VDCMAX,...
    VDCMIN, CDC]=idx_busdc;
[F_BUSDC, T_BUSDC, BRDC_R, BRDC_X, BRDC_B, RATEDC_A, RATEDC_B, ...
    RATEDC_C, BRDC_STATUS, PFDC, PTDC]=idx_brchdc;
 [DCDROOP, DCSLACK, DCNOSLACK, PVC, PQC, CONV_BUS, CONVTYPE_DC, ...
    CONVTYPE_AC, PCONV, QCONV, VCONV, RTF, XTF, BF, RCONV, XCONV, ...
    BASEKVC, VCMAX, VCMIN, ICMAX, CONVSTATUS, LOSSA, LOSSB, LOSSCR, ...
    LOSSCI, DROOP, PDCSET, VDCSET, DVDCSET, VMC, VAC, PCCONV, QCCONV, ...
    PCLOSS, VMF, VAF, PFIL, QCONVF, QCCONVF]=idx_convdc;

%% define other numbers and indices
nconv   = size(convdc, 1);
nbusdc  = size(busdc, 1 );
  
fd=1;

%% dc bus data
fprintf(fd, '\n================================================================================');
fprintf(fd, '\n|     DC bus data                                                              |');
fprintf(fd, '\n================================================================================');
fprintf(fd, '\n Bus   Bus   Voltage    Power');
fprintf(fd, '\n DC #  AC #  Mag(pu)    P (MW)');
fprintf(fd, '\n-----  ----  ---------  --------');
for i = 1:nbusdc
    if busdc(i,BUSAC_I)==0
     fprintf(fd, '\n%4d%6c%10.3f%11.3f', busdc(i,[BUSDC_I]), '-', busdc(i,[VDC PDC]));   
    else
     fprintf(fd, '\n%4d%6d%10.3f%11.3f', busdc(i,[BUSDC_I BUSAC_I VDC PDC]));
    end
end
 fprintf(fd, '\n');


%% transformer losses
Plosstf = abs( convdc(:, PFIL   ) - convdc(:, PCONV ) );
Qlosstf = abs( convdc(:, QCONVF ) - convdc(:, QCONV ) );

%% reactor losses
Plossc  = abs( convdc(:, PCCONV ) - convdc(:, PFIL  ) );
Qlossc  = abs( convdc(:, QCCONV )-convdc(:, QCCONVF ) );

%% converter data
Plosstot = Plosstf + Plossc + convdc(:,PCLOSS);

%% filter reactive power
Qfilt= convdc(:,QCCONVF) - convdc(:,QCONVF);


fprintf(fd, '\n================================================================================');
fprintf(fd, '\n|     VSC Converter Data                                                       |');
fprintf(fd, '\n================================================================================');
fprintf(fd, '\n Bus     Bus injection           Converter Voltage                 Total loss  ' );
fprintf(fd, '\n DC#   P (MW)   Q (MVAr)         Mag(pu) Ang(deg)                    P (MW)    ' );
fprintf(fd, '\n-----  -------  --------         ------- --------                  ----------- ' );
for i = 1:nconv
     fprintf(fd, '\n%4d%9.2f%9.2f%17.3f%9.3f%27.2f', convdc(i,[CONV_BUS PCONV QCONV VMC VAC]),  Plosstot(i));
end
fprintf(fd, '\n                                                                      ------  ');
fprintf(fd, '\n                                                           Total: %9.2f ', sum(Plosstot));
fprintf(fd, '\n');

fprintf(fd, '\n Bus  Converter power   Filter   Transfo loss     Reactor loss    Converter loss');
fprintf(fd, '\n DC#  P (MW) Q (MVAr)  Q (MVAr)  P (MW) Q (MVAr)  P (MW) Q (MVAr)    P (MW) ');
fprintf(fd, '\n----- ------- -------  --------  ------ --------  ------ -------- --------------');
for i = 1:nconv
     fprintf(fd, '\n%4d%9.2f%8.2f%8.2f%9.2f%8.2f%9.2f%8.2f%12.2f', ...
         convdc(i,[CONV_BUS PCCONV QCCONV]), Qfilt(i), Plosstf(i), Qlosstf(i), Plossc(i), Qlossc(i), convdc(i,PCLOSS));
end

 fprintf(fd, '\n                                 ------ --------  ------ -------- --------------');
 fprintf(fd, '\n                      Total: %9.2f%8.2f%9.2f%8.2f%12.2f' , ...
    sum(Plosstf), sum(Qlosstf),sum(Plossc), sum(Qlossc), sum(convdc(:,PCLOSS)));
 fprintf(fd, '\n');

 fprintf(fd, '\n Bus  Grid power       Traf Filt.Power  Filter    Conv Filt. Pwr   Converter Power');
 fprintf(fd, '\n DC#  P (MW) Q (MVAr)  P (MW) Q (MVAr)  Q (MVAr)  Q (MVAr)         P (MW) Q (MVAr)');
 fprintf(fd, '\n----- ------ --------  ------ --------  --------  --------------   ------ --------');
for i = 1:nconv
     fprintf(fd, '\n%4d%9.2f%8.2f%8.2f%9.2f%8.2f%11.2f%16.2f%8.2f', ...
         convdc(i,[CONV_BUS PCONV QCONV PFIL QCONVF]), convdc(i,QCCONVF)-convdc(i,QCONVF), convdc(i,[QCCONVF PCCONV QCCONV]));
end
 
  %% dc branch data
 nbranch=size(branchdc,1);

P_max=max([abs(branchdc(:,PFDC)) abs(branchdc(:,PTDC))],[],2);
P_min=min([abs(branchdc(:,PFDC)) abs(branchdc(:,PTDC))],[],2);
Plossline=P_max-P_min;

fprintf(fd, '\n================================================================================');
fprintf(fd, '\n|     DC branch data                                                           |');
fprintf(fd, '\n================================================================================');

fprintf(fd, '\nBrnch   From   To     From Bus    To Bus      Loss');
fprintf(fd, '\n  #     Bus    Bus    P (MW)      P (MW)      P (MW)  ');
fprintf(fd, '\n-----  -----  -----  --------    --------    -------- ');
fprintf(fd, '\n%4d%7d%7d%10.2f%12.2f%12.2f', ...
        [   [1:nbranch]', branchdc(:,F_BUSDC), branchdc(:,T_BUSDC), branchdc(:,[PFDC PTDC]) Plossline
            ]');
 fprintf(fd, '\n                                             --------');
 fprintf(fd, '\n                                 Total: %12.2f', ...
    sum(Plossline));
 fprintf(fd, '\n');
fprintf(fd, '\n');
