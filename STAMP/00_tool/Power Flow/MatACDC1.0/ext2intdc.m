function [i2edcpmt, i2edc, busdc, convdc, branchdc] = ext2intdc(busdc, convdc, branchdc)

%EXT2INTDC   Converts dc external to internal bus numbering.
%   [I2EDCPMT, I2EDC, BUSDC, CONVDC, BRANCHDC] = EXT2INT( BUSDC, ...
%       CONVDC, BRANCHDC) 
%
%   Converts external dc bus numbers (possibly non-consecutive) to 
%   consecutive internal bus numbers, starting at 1.
%
%   Also see EXT2INTAC
%
%   Inputs:
%       BUSDC : dc bus matrix
%       CONVDC : dc converter matrix
%       BRANCHDC : dc branch matrix
%
%   Outputs:
%       I2EDCPMT : Internal to external dc bus permutation
%           All dc buses with an ac grid connection are grouped, followed
%           by the dc buses without a converter or with a converter outage.
%           Buses are grouped per dc grid.
%       I2EDC : Internal to external dc indices
%       BUSDC : Updated dc bus matrix
%       CONVDC : Updated converter matrix
%       BRANCHDC : Updated dc branch matrix

%   MatACDC
%   Copyright (C) 2012 Jef Beerten
%   University of Leuven (KU Leuven)
%   Dept. Electrical Engineering (ESAT), Div. ELECTA
%   Kasteelpark Arenberg 10
%   3001 Leuven-Heverlee, Belgium

%% define named indices into busdc, convdc, branchdc matrices
[BUSDC_I, BUSAC_I, GRIDDC, PDC, VDC, BASE_KVDC, VDCMAX,...
    VDCMIN, CDC]=idx_busdc;
[DCDROOP, DCSLACK, DCNOSLACK, PVC, PQC, CONV_BUS, CONVTYPE_DC, ...
    CONVTYPE_AC, PCONV, QCONV, VCONV, RTF, XTF, BF, RCONV, XCONV, ...
    BASEKVC, VCMAX, VCMIN, ICMAX, CONVSTATUS, LOSSA, LOSSB, LOSSCR, ...
    LOSSCI, DROOP, PDCSET, VDCSET, DVDCSET, VMC, VAC, PCCONV, QCCONV, ...
    PCLOSS, VMF, VAF, PFIL, QCONVF, QCCONVF]=idx_convdc;
[F_BUSDC, T_BUSDC, BRDC_R, BRDC_L, BRDC_C, RATEDC_A, RATEDC_B, ...
    RATEDC_C, BRDC_STATUS, PFDC, PTDC]=idx_brchdc;

%%-----  Check grid numbering -----
griddc      = sort(unique(busdc(:, GRIDDC)));
%% Error when ...
if nnz( griddc == [1:length(griddc)]' ) ~= length(griddc)
   error('Non-successive dc grid numbering detected')
end
   
%%-----  Permutation of dc bus matrix  -----
%% Part 1: Group all dc busses without ac grid connection
noacbusi    = find( busdc(:,BUSAC_I)==0 );
acbusi      = find( busdc(:,BUSAC_I)    );
i2edcpmt    = [ acbusi; noacbusi    ];
busdc       = busdc( i2edcpmt,:     );

%% Part 2: Sort dc busses based on dc grid number
busdcext    =   [ busdc, i2edcpmt   ];
busdcext    =   sortrows( busdcext, GRIDDC  );
busdc       =   busdcext( :,1:size(busdc,2) );
i2edcpmt    =   busdcext(   :,end   );


%%-----  Rename dc nodes  -----
i2edc           = busdc(:, BUSDC_I);
e2idc           = zeros(max(i2edc), 1);
e2idc(i2edc)    = [1:size(busdc, 1)]';

busdc(:,BUSDC_I)        =   e2idc( busdc(:,BUSDC_I)       );
convdc(:,CONV_BUS)      =   e2idc( convdc(:,CONV_BUS)     );
branchdc(:, F_BUSDC)    =   e2idc( branchdc(:, F_BUSDC)   );
branchdc(:, T_BUSDC)    =   e2idc( branchdc(:, T_BUSDC)   );

return;
