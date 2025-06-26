function [baseMVAac, baseMVAdc, pol, busdc, convdc, branchdc]= case5_stagg_HVDCptp

%dc case 2 nodes  dc power flow data for point-to-point link
%
%   3 node system (constant voltage and power controlled) can be used 
%   together with ac case files 'case5_stagg.m' and 'case'3_inf.m'
%   
%   Network data based on ...
%   J. Beerten, D. Van Hertem, R. Belmans, "VSC MTDC systems with a 
%   distributed DC voltage control – a power flow approach", in IEEE 
%   Powertech2011, Trondheim, Norway, Jun 2011.
%
%   MATACDC case file data provided by Jef Beerten.


%% system MVA base
baseMVAac = 100;
baseMVAdc = 100;

%% dc grid topology
pol=2;  % numbers of poles (1=monopolar grid, 2=bipolar grid)

%% bus data
%   busdc_i busac_i grid    Pdc     Vdc     basekVdc    Vdcmax  Vdcmin  Cdc 
busdc = [
    1       2       1       0       1       345         1.1     0.9     0;
    2       3       1       0       1       345         1.1     0.9     0;  
];

%% converters
% %   busdc_i type_dc type_ac P_g   Q_g   Vtar    rtf     xtf     bf     rc     xc     basekVac    Vmmax   Vmmin   Imax    status   LossA LossB  LossCrec LossCinv  
convdc = [ 
    1       1       1       -60    -40    1     0.0015  0.1121  0.0887 0.0001   0.16428  345         1.1     0.9     1.2     1       1.103 0.887  2.885    4.371;
    2       2       2         0      0    1     0.0015  0.1121  0.0887 0.0001   0.16428  345         1.1     0.9     1.2     1       1.103 0.887  2.885    4.371;
    ];

%% branches
%   fbusdc  tbusdc  r      l    c   rateA   rateB   rateC   status
branchdc = [  
    1       2       0.052   0   0    100     100     100     1;
 ];