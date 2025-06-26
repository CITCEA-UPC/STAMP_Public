function [busdc, conv0busi, conv1, conv1i, conv0, conv0i] = convout(busdc, convdc)

%CONVOUT  Remove converters facing outages from converter matrix. 
%   [BUSDC, CONV0BUSI, CONV1, CONV1I, CONV0, CONV0I] = CONVOUT(BUSDC, CONVDC)
%
%   The dc converter matrix is split into working (conv1) and non working
%   (conv0) converter matrices. The corresponding ac bus connection is
%   removed from the busdc matrix.
%
%   Input:
%       BUSDC : dc bus matrix
%       CONVDC : dc converter matrix
%        
%   Outputs:
%       BUSDC : updated dc bus matrix with ac buses of converters facing
%           outages removed
%       CONV0BUSI : 2 column matrix
%           column 1: index of converter outages in converter matrix
%           column 2: ac bus to which converter was connected before outage
%       CONV1 : dc converter matrix with operating converters
%       CONV1I : indices of operating converters in original converter
%           matrix
%       CONV0 : dc converter matrix without operating converters
%       CONV0I : indices of converters with outages in original converter 
%           matrix

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

%% converter status validity check
if any( (convdc(:, CONVSTATUS) ~= 0) & (convdc(:, CONVSTATUS) ~= 1) )
    error('converter status flags must be either 0 or 1');
end


%% define
conv0i      = find(convdc(:, CONVSTATUS)==0);
conv1i      = find(convdc(:, CONVSTATUS)==1);

%% define converter outage matrix
conv0      = convdc(conv0i,:);
conv1      = convdc(conv1i,:);

%% reset converter powers and voltages 
conv0(:, PCONV ) = 0;
conv0(:, QCONV ) = 0;


%% remove ac bus of converter with outage in busdc matrix
conv0busi = [];
if size(conv0i,1)>0
    for ii = 1:length(conv0i)
        jj = 1;
        flag = 0;
        while jj <= size(busdc,1) && flag==0
            %% check for same dc bus number
            if conv0(ii,CONV_BUS) == busdc(jj, BUSDC_I)
                conv0busi         = [conv0busi;
                                     jj busdc(jj,BUSAC_I)];
                busdc(jj,BUSAC_I) = 0;   
                flag = 1;
            end
            jj = jj + 1;
        end
    end
end
return;