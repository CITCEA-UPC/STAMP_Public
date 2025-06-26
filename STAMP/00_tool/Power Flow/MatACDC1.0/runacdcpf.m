function [baseMVA, bus , gen ,branch, busdc, convdc, branchdc, converged, timecalc] = runacdcpf(caseac, casedc, macdcopt, mpopt)
%format long
%RUNACDCPF  Runs a sequential ac/dc power flow.
%   [RESULTSAC, RESULTSDC, CONVERGED, ...
%       TIMECALC] = RUNACDCPF(CASEAC, CASEDC, MACDCOPT, MPOPT)
%
%   Runs a sequential power flow, optionally
%   returning the results, a convergence flag and the time.
%
%   Inputs (optional):
%       CASEAC : ac power flow data
%           either a MATPOWER case struct or a string containing the name 
%           of the file with the data (default ac case is 'case5_stagg', 
%           only used when both ac and dc power flow data are not defined)
%           (see also CASEFORMAT and LOADCASE and MATPOWER)
%       CASEDC : dc power flow data
%           either a MATACDC case struct or a string containing
%           the name of the file with the data (default dc case is 
%           'case5_stagg_MTDCslack')
%           (see also LOADCASEDC)
%       MACDCOPT : MATACDC options vector to override default ac/dc power 
%           flow options. Can be used to specify tolerances, inclusion of
%           limits, plot options and more (see also MACDCOPTION).
%       MPOPT : MATPOWER options vector to override default options
%           can be used to specify the solution algorithm, output options
%           termination tolerances, and more (see also MPOPTION).
%
%   Outputs (optional):
%       RESULTSAC : results struct, with the following fields from the 
%       input MATPOWER case: baseMVA, bus, branch, gen  (but with solved 
%       voltages, power flows, etc.)
%       RESULTSDC : results struct, with the following fields:
%       input MATACDC dc case: baseMVAac, baseMVAdc, pol, busdc, convdc,
%       branchdc (but with solved voltages, power flows, etc.)
%       CONVERGED : converge flag, can additionally be returned
%       TIMECALC : elapsed time, can additionally be returned
%
%       Alternatively, ac and dc power flow results can also be 
%       returned as individual outputs by having:
%
%       [baseMVA, bus gen ,branch, busdc, convdc, branchdc, converged, ...
%       timecalc] = runacdcpf(...);
%
%       Only baseMVA is returned, and not baseMVAac and
%       baseMVAdc defined in the input case files.
%
%   Examples of usage:
%       [resultsac, resultsdc] = runacdcpf('case5_stagg',...
%       'case5_stagg_MTDCdroop');
%       [baseMVA, bus gen ,branch, busdc, convdc, branchdc] = ...
%       runacdcpf('case3_inf', 'case5_stagg_MTDCslack');

%   MatACDC
%   Copyright (C) 2012 Jef Beerten
%   University of Leuven (KU Leuven)
%   Dept. Electrical Engineering (ESAT), Div. ELECTA
%   Kasteelpark Arenberg 10
%   3001 Leuven-Heverlee, Belgium

%% start of time calculation
tic 

%% add subdirectories to path
namedir = cd;
if strcmp('MatACDC',namedir(end-9:end-3) )
    addpath([cd '/Cases/PowerflowAC/']);
    addpath([cd '/Cases/PowerflowDC/']);
end

%% default arguments
if nargin < 4
    %% ac power flow options
    mpopt = mpoption;
    %mpopt(31)=0;    %% default: no ac pf progress printed after each ac pf
    %mpopt(32)=0;    %% default: no ac pf results printed after each ac pf
    if nargin < 3
        macdcopt = macdcoption;   %% use default options
        if nargin<1
            caseac = 'case5_stagg';             %% default ac data file is 'case5_stagg.m'
            casedc = 'case5_stagg_MTDCslack';   %% default dc data file is 'case5_stagg_MTDCslack.m'
        end
    end
end

%% program options
tolacdc            = macdcopt(1);     %% tolerance ac/dc power flow
itmaxacdc          = macdcopt(2);     %% maximum iterations ac/dc power flow
toldc              = macdcopt(3);     %% tolerance dc power flow
itmaxdc            = macdcopt(4);     %% maximum iterations dc power flow
tolslackdroop      = macdcopt(5);     %% tolerance slack/droop bus loss iteration
itmaxslackdroop    = macdcopt(6);     %% maximum iterations slack/droop bus iteration
tolslackdroopint   = macdcopt(7);     %% tolerance internal slack/droop bus iteration
itmaxslackdroopint = macdcopt(8);     %% maximum iterations internal slack/droop bus iteration
multslack     = macdcopt(9);     %% multiple DC slack buses in single DC grid (0 = not allowed, 1 = allowed)

limac         = macdcopt(10);    %% limits AC (0 = disable, 1 = enable)
limdc         = macdcopt(11);    %% limits DC (0 = disable, 1 = enable) ==> not used
tollim        = macdcopt(12);    %% maximum error between subsequent limit violations

output        = macdcopt(13);    %% print output
convplotopt   = macdcopt(14);    %% plot converter station limit violations (1 = only viol, 2 = viol + end situation)

%% print options
fd=1;


%%-----  initialise  -----        
%% load data
[baseMVA, bus, gen, branch] = loadcase(caseac);
[baseMVAac, baseMVAdc, pol, busdc, convdc, branchdc] = loadcasedc(casedc);


%% define named indices into bus, gen, branch matrices
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
 [GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
     MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
     QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;

%% define named indices into busdc, convdc, branchdc matrices
[BUSDC_I, BUSAC_I, GRIDDC, PDC, VDC, BASE_KVDC, VDCMAX, ...
    VDCMIN, CDC] = idx_busdc;
[DCDROOP, DCSLACK, DCNOSLACK, PVC, PQC, CONV_BUS, CONVTYPE_DC, ...
    CONVTYPE_AC, PCONV, QCONV, VCONV, RTF, XTF, BF, RCONV, XCONV, ...
    BASEKVC, VCMAX, VCMIN, ICMAX, CONVSTATUS, LOSSA, LOSSB, LOSSCR, ...
    LOSSCI, DROOP, PDCSET, VDCSET, DVDCSET, VMC, VAC, PCCONV, QCCONV, ...
    PCLOSS, VMF, VAF, PFIL, QCONVF, QCCONVF] = idx_convdc;
[F_BUSDC, T_BUSDC, BRDC_R, BRDC_L, BRDC_C, RATEDC_A, RATEDC_B, ...
    RATEDC_C, BRDC_STATUS, PFDC, PTDC] = idx_brchdc;


%%-----  Data preparation -----
%% converter outage are considered as stations without ac grid connection
[busdc, conv0busi, conv1, conv1i, conv0, conv0i]  = convout(busdc, convdc);
convdc = conv1; %% only use converters without outage

%% dc branch outages (remove branches from input data)
[brchdc1, brchdc1i, brchdc0, brchdc0i]  = brchdcout(branchdc);
branchdc = brchdc1;     %% only include branches in operation

%% ac branch outages (remove branches from input data)
[brch1, brch1i, brch0, brch0i]  = brchout(branch);
branch = brch1;     %% only include branches in operation

%% generator outages (remove non-operational generators from input data)
gon  = find(gen(:, GEN_STATUS) > 0);    %% which generators are on?
goff = find(gen(:, GEN_STATUS) == 0);   %% which generators are off?
gen0 = gen(goff, :);                    %% non-operational generator data
gen  = gen(gon,  :);                    %% keep operational generators

%%-----  External to internal numbering  -----
%% dc network external to internal bus numbering
[i2edcpmt, i2edc, busdc, convdc, branchdc] = ext2intdc(busdc, convdc, branchdc);

%% ac network external to internal bus numbering
[i2eac, acdmbus, busdc, bus, gen, branch] = ext2intac(busdc, bus, gen, branch);

%% sort matrices by new bus numbers
[bus, i2ebus]           = sortrows( bus       );
[gen, i2egen]           = sortrows( gen       );
[branch, i2ebrch]       = sortrows( branch    );
[busdc, i2ebusdc]       = sortrows( busdc     );
[convdc, i2econvdc]     = sortrows( convdc    );
[branchdc, i2ebrchdc]   = sortrows( branchdc  );

%% Per unit external to internal data conversion
[busdc, convdc, branchdc]=ext2intpu(baseMVA,baseMVAac,...
    baseMVAdc,busdc,convdc,branchdc);


%%-----  Additional data preparation & index initialisation  -----
%% zero rows addition to convdc matrix (dc buses without converter)
convdc1 = zeros(size(busdc,1), size(convdc,2));
convdc1(convdc(:, CONV_BUS), :) = convdc;
convdc  = convdc1;

%% indices initialisation 
bdci    = busdc(:,BUSAC_I);                                         %% bus number of dc buses
cdci    = find(convdc(:,CONV_BUS));                                 %% converter bus numbers
slackdc = convdc(  convdc(:, CONVTYPE_DC) == DCSLACK  , CONV_BUS);  %% bus number of dc slack converters
droopdc = convdc(  convdc(:, CONVTYPE_DC) == DCDROOP  , CONV_BUS);  %% bus number of voltage droop converters
ngriddc = max( busdc(:, GRIDDC) );                                  %% number of dc grids


%%-----  Violation check  -----
%% dc slack bus and distributed voltage bus violation check
gridviol = setdiff( [1:ngriddc]', busdc([slackdc; droopdc], GRIDDC));
if ~isempty(gridviol)
    fprintf(fd, '\n No slack or droop bus in dc grid %d.\n', sortrows(gridviol) );
    error( 'No droop controlled bus or slack bus defined for every dc grid !' );
end

%% remove multiple slack buses
if multslack == 0
    for ii= 1:ngriddc
        slackdcii = intersect(slackdc, find(busdc(:,GRIDDC)==ii));
        if length(slackdcii)>1
            convdc(slackdcii(1), CONVTYPE_DC )      = DCSLACK;
            convdc(slackdcii(2:end), CONVTYPE_DC )  = DCNOSLACK;    
            slackdcii = slackdcii(1);

            %% printout changes
            fprintf(fd, '\n Multiple dc slack busses defined in grid %d', ii);
            fprintf(fd, '\n     Bus %d kept as the slack bus', i2edc(slackdcii));      
        end
    end
    
    %% redefine slack buses
    slackdc  = convdc(  convdc(:, CONVTYPE_DC) == DCSLACK  , CONV_BUS);     %% bus number of dc slack converters
end

%% define indices of slack, droop and power controlled buses
slackdroopdc = union(slackdc, droopdc);                                     %% combined slack and droop indices
noslackbdc   = setdiff(busdc(:,BUSDC_I), slackdc);                          %% bus number of non dc slack buses (do not need converter!)

%% remove converter and generator V control violations 
vcontrvsc       = find( convdc(:, CONVTYPE_AC) == PVC);     %% V controlling converters 
vcontrgen       = sort([find( bus(:, BUS_TYPE) == PV);...
                    find(bus(:, BUS_TYPE) == REF)]);        %% V controlling generators
vconfl          = intersect(vcontrvsc, vcontrgen);          %% buses with V control conflicts
convdc(vconfl, CONVTYPE_AC )   = PQC;   %% control mode of conflicting converters: PV=>PQ with Q=0
convdc(vconfl, QCONV       )   = 0;
convdc( :    , QCONV       )   = ...    %% Q injection of all V controlling converters is reset
    convdc( : , QCONV).*(convdc( :, CONVTYPE_AC) == PQC);    
if isempty(vconfl)==0                   %% printout conflicting buses
    fprintf(fd, '\n Generator & VSC converter on the same bus');
    fprintf(fd, '\n     Conflicting voltage control on bus %d', sortrows(i2eac(vconfl)) );
    fprintf(fd, '\n => Corresponding VSC Converter set to PQ control without Q injections.');
end    


%%-----  initialisation ac network  -----
%% dummy generator initialisation 
Vcref       = convdc(:, VCONV);         %% voltage setpoints
busVSC      = bus;                      %% initialisation of ac busmatrix including converters (in V control and added as loads)
gendm       = zeros(0, size(gen,2) );   %% dummy generator matrix (converters in V control at nodes without generator)
genPQ       = [];       %% bus numbers of PQ generators
genPQi      = [];       %% index of PQ generator in gen matrix
Qcmin_dum   = -99999;   %% minimum Q limit dummy generator (MVar)
Qcmax_dum   =  99999;   %% minimum Q limit dummy generator (MVar)
Pcmin_dum   =      0;   %% minimum P limit dummy generator (MW)
Pcmax_dum   =  99999;   %% maximum P limit dummy generator (MW)

%% dummy generator addition
for ii = 1:size(convdc,1)
    
    %% change control from PQ to PV for buses with converter in PV control
    if bus(ii,BUS_TYPE) == PQ && convdc(ii,CONVTYPE_AC)==PVC 
        busVSC(ii,BUS_TYPE) = PV;       %% change bustype into PV
        
        %% add dummy generator to V controlling converter bus without generator 
        if ismember(ii,gen(:,GEN_BUS))==0           %% no generator present at bus
            gendm      = [gendm;                   
                            zeros(1,size(gen,2));   %% addition of dummy generator
                            ];
            gendm(end,[GEN_BUS,PG,QG,QMAX,QMIN,VG,MBASE,GEN_STATUS,PMAX,PMIN]) =...
                [ii,0,0,Qcmax_dum,Qcmin_dum,Vcref(ii),baseMVAac,1,Pcmax_dum,Pcmin_dum]; %% define dummy generator parameters
        
        %% no generator is added when a PQ generator is present at the bus
        else                                    %% PQ generator present at bus 
            genPQ    = [genPQ;ii];              %% bus numbers of PQ generators
            genPQii  = find(gen(:,GEN_BUS)==ii);
            genPQi   = [genPQi; genPQii];       %% index of PQ generator in gen matrix
        end       
    end
end

%% define buses with dummy generator
gdmbus          = gendm(:, GEN_BUS);

%% converter stations power injections into ac network
Pvsc = convdc(:, PCONV)/baseMVA;
Qvsc = convdc(:, QCONV)/baseMVA;

%% dc voltage droop setpoints and parameters
PVdroop     = zeros( size( busdc,    1), 1);
Pdcset      = zeros( size( busdc,    1), 1);
Vdcset      = zeros( size( busdc,    1), 1);
dVdcset     = zeros( size( busdc,    1), 1);

PVdroop(cdci) =   convdc(cdci, DROOP)*baseMVA;
Pdcset(cdci)  =   convdc(cdci, PDCSET)/baseMVA;
Vdcset(cdci)  =   convdc(cdci, VDCSET);
dVdcset(cdci) =   convdc(cdci, DVDCSET);

%% voltage droop converter power initialisation 
Pvsc(droopdc) = Pdcset(droopdc);     %% assumption: operating in reference set-point & no converter losses

%% dc slack converter power injection initialisation
if size(slackdc)~=0 
    for ii= 1:ngriddc
        slackdcii = find(busdc(:, GRIDDC)==ii & convdc(:, CONVTYPE_DC)==DCSLACK); %% slack buses in grid ii
        if size(slackdcii)~=0
            Pvscii    = Pvsc.*(busdc(:,GRIDDC)==ii & convdc(:, CONVTYPE_DC)~=DCSLACK); 
            Pvsc(slackdcii) = -sum(Pvscii)/length(slackdcii); %% assumption: no dc and converter losses
        end
    end
end

%% Inclusion of converters as loads
busVSC(cdci,PD) = bus(cdci,PD) - Pvsc(cdci)*baseMVA;  %% converter P injection from input files included as load
busVSC(cdci,QD) = bus(cdci,QD) - Qvsc(cdci)*baseMVA;  %% only Q from input files is included, not for V control


%%-----  initialisation of converter quantities -----
%% per unit converter loss coefficients values
basekA  =   baseMVA./(sqrt(3)*convdc(:,BASEKVC));
lossa   =   convdc(:,LOSSA);%/baseMVA;
lossb   =   convdc(:, LOSSB).*(basekA/baseMVA);
%losscr  =   convdc(:, LOSSCR).*basekA.^2/baseMVA;
%lossci  =   convdc(:, LOSSCI).*basekA.^2/baseMVA;
losscr  =   convdc(:, LOSSCR);
lossci  =   convdc(:, LOSSCI);

%% converter reactor parameters
Rc      = convdc(:, RCONV);
Xc      = convdc(:, XCONV);
Zc      = Rc+j.*Xc;

%% converter limits data
Icmax   = convdc(:, ICMAX);
Vcmax   = convdc(:, VCMAX);
Vcmin   = convdc(:, VCMIN);

%% filter reactance
Bf      = convdc(:, BF);

%% transformer parameters
Rtf     = convdc(:, RTF);
Xtf     = convdc(:, XTF);
Ztf     = Rtf+j.*Xtf;


%%-----  initialisation of dc network quantities -----
%% build dc bus matrix
[Ybusdc, Yfdc, Ytdc] = makeYbusdc( busdc, branchdc );

%% detect ac islands errors (non-synchronised zones => to be solved independently)
zonecheck(bus,gen, branch, i2eac, output);
aczones = sort(unique(bus(:,ZONE)));


%%-----  main iteration loop -----
%% initialise
Vdc         = busdc(:,VDC);         %% dc bus voltages
genVSC      = [gen; gendm];         %% inclusion of dummy generators for ac solution
gendmidx    = find( ismember(genVSC(:, GEN_BUS), gen(:, GEN_BUS) )==0);     %% index of dummy generators in genVSC matrix
Ps          = Pvsc;                 %% grid side converter power initialisation
Pdc         = zeros( size( busdc,    1), 1);
Ifdc        = zeros( size( branchdc, 1), 1);
Pfdc        = zeros( size( branchdc, 1), 1);
Ptdc        = zeros( size( branchdc, 1), 1);

%% iteration options
it        = 0;
converged = 0;

%% main loop
while ~converged && it<=itmaxacdc
    %% update iteration counter
    it = it + 1;
    
    %% reset grid side converter reactive power injection
    Qs      = Qvsc;         %% grid side reactive power injection reset
    Ss      = Ps + j*Qs;    %% grid side active power injection reset
   

    %%-----  ac network power flow  -----
    %% ac power flow with converters as loads (PQ mode) or load+generator (PV mode)
    busVSCext = zeros(0, size(bus, 2)    );
    genVSCext = zeros(0, size(gen, 2)    );
    branchext = zeros(0, QT );
    for i = 1:length(aczones)
        %% select buses, generators and branches in the specified ac zone
        buszi       = find(bus(:,ZONE)==aczones(i));
        genVSCzi    = find(bus(genVSC(:,GEN_BUS),ZONE) == aczones(i));
        brchzi      = find(bus(branch(:,F_BUS),ZONE) == aczones(i));
        
        busVSCz     = busVSC(buszi,:);
        genVSCz     = genVSC(genVSCzi,:);
        branchz     = branch(brchzi,:);
        
        %% solve ac power flow for specified ac zone (if not infinite bus)
        if size(busVSCz,1)>1
            accaseVSCz  = struct('baseMVA', baseMVA, 'bus', busVSCz, ...
                'gen', genVSCz, 'branch', branchz);
            [baseMVA, busVSCz, genVSCz, branchz] = runpf(accaseVSCz, mpopt);
        end
        
        %% store solutions for specified ac zone in extended matrices
        busVSCext(buszi,:)     = busVSCz;
        genVSCext(genVSCzi, :) = genVSCz;
        branchext(brchzi,:)    = branchz;
    end
    
    busVSC = busVSCext;
    genVSC = genVSCext;
    branch = branchext;
    
    %% dummy generator update
    gendm       = genVSC(size(gen, 1)+1:end, :); 

    %% dummy generator on converter V controlled bus 
    Ss(gdmbus)   =   Ss(gdmbus)+j*gendm(:,QG)/baseMVA;  %% update converter grid side injection

    %% PQ generator on converter V controlled bus 
    Ss(genPQ, 1)   =   Ss(genPQ, 1)+ ...
        j*(genVSC(genPQi, QG)-gen(genPQi, QG))/baseMVA; %% update converter grid side injection with reactive power for V control
    
    %% update grid side converter power injections
    Ps      =   real(Ss);
    Qs      =   imag(Ss);
    
    %% generator reset
    genVSC(gendmidx,QG)     = 0;                %% dummy generator reset
    genVSC(genPQi,QG)       = gen(genPQi,QG);   %% PQ generators Q injection reset

    
    %%----- Converter calculations -----
    %% converter reactor voltages and power
    Vs       = busVSC(bdci,VM).*exp(j*busVSC(bdci,VA)*pi/180);
    Itf      = conj(Ss./Vs);         %% transformer current
    Vf       = Vs + Itf.*Ztf;        %% filter side voltage
    Ssf      = Vf.*conj(Itf);        %% filter side transformer complex power
    Qf       = -Bf.*abs(Vf).^2;      %% filter reactive power
    Scf      = Ssf+j*Qf;             %% filter side converter complex power
    Ic       = conj(Scf./Vf);        %% converter current
    Vc       = Vf + Ic.*Zc;          %% converter side voltage
    Sc       = Vc.*conj(Ic);         %% converter side complex power

    %% converter active and reactive powers
    Pc       = real(Sc);
    Qc       = imag(Sc);
    Pcf      = real(Scf);
    Qcf      = imag(Scf);
    Psf      = real(Ssf); 
    Qsf      = imag(Ssf);
    
    %% initialisation
    Ps_old          =   Ps;
    
    if limac == 1 
        %%--- converter limit check ---
        %% initialisation
        limviol = zeros(size(busdc,1), 1 );
        SsL     = zeros(size(busdc,1), 1 );
        plotarg = zeros(size(busdc,1), 17);

        for ii= 1:ngriddc
            %% remove slack converters from limit check
            cdcii = convdc( busdc(:,GRIDDC)==ii ,CONV_BUS);     %% converters in grid ii
            [~,cdcslackii] = intersect(cdcii,slackdc);
            if ~isempty(cdcslackii)
                cdcii(cdcslackii) = [];                         %% remove slack converter  
            end
            cdcii = nonzeros(cdcii); %% remove zero elements (converter outages)
            
            %% converter limit check
            for jj = 1:length(cdcii)
                cvjj = cdcii(jj);
                [limviol(cvjj),SsL(cvjj), plotarg(cvjj,:)] = convlim(Ss(cvjj), Vs(cvjj), Vc(cvjj), Ztf(cvjj), ...
                    Bf(cvjj), Zc(cvjj), Icmax(cvjj), Vcmax(cvjj), Vcmin(cvjj), i2edc(cvjj), tollim, convplotopt ); %
            end

            %% converter limit violations (1 = Q limit, 2 = P limit)
            limviolii   = limviol.*(busdc(:,GRIDDC)==ii);
            dSii  = (SsL-Ss).*(busdc(:,GRIDDC)==ii).*(convdc(:,CONVTYPE_DC)~=DCSLACK);
            if ismember(2, limviolii) || ismember(1, limviolii)
                if ismember(2, limviolii)
                    dSii                  = dSii.*(limviolii==2);
                    [~, dSiimaxi]   = max(abs(real(dSii)));
                    fprintf(fd, '\n  Active power setpoint of converter %d changed from %.2f MW to %.2f MW.', ...
                        i2edc(dSiimaxi), real(Ss(dSiimaxi))*baseMVA, real(SsL(dSiimaxi))*baseMVA);
                    fprintf(fd, '\n  Reactive power setpoint of converter %d changed from %.2f MVAr to %.2f MVAr.\n', ...
                        i2edc(dSiimaxi), imag(Ss(dSiimaxi))*baseMVA, imag(SsL(dSiimaxi))*baseMVA);
                else %%if ismember(1, limviolii)
                    dSii                  = dSii.*(limviolii==1);
                    [~, dSiimaxi]   = max(abs(imag(dSii)));
                    fprintf(fd, '\n  Reactive power setpoint of converter %d changed from %.2f MVAr to %.2f MVAr. \n', ...
                        i2edc(dSiimaxi), imag(Ss(dSiimaxi))*baseMVA, imag(SsL(dSiimaxi))*baseMVA);
                end
                
                %% plot converter setpoint adaptation 
                if convplotopt ~= 0  
                    convlimplot(plotarg(dSiimaxi,:), i2edc(dSiimaxi));
                end

                %% update converter powers
                Ss(dSiimaxi)    = SsL(dSiimaxi);
                Pvsc(dSiimaxi)  =   real(Ss(dSiimaxi));
                Qvsc(dSiimaxi)  =   imag(Ss(dSiimaxi)); 
                busVSC(dSiimaxi,PD) = bus(dSiimaxi,PD) - ...
                    Pvsc(dSiimaxi)*baseMVA;  %% converter P injection from input files included as load
                busVSC(dSiimaxi,QD) = bus(dSiimaxi,QD) - ...
                    Qvsc(dSiimaxi)*baseMVA;  %% only Q from input files is included, not for V control
            else
                dSiimaxi = [];
            end

            %% Remove voltage control on violated converter
            if convdc(dSiimaxi, CONVTYPE_AC)== PVC
                convdc(dSiimaxi, CONVTYPE_AC) = PQC;
                fprintf(fd, '  Voltage control at converter bus %d removed.\n', i2edc(dSiimaxi) );
                
                busVSC(dSiimaxi, BUS_TYPE)  = PQ;
                %% Remove dummy generator (PV bus changed to PQ bus)
                if ismember(dSiimaxi, gdmbus) 
                    dSidx       =   find(gdmbus == dSiimaxi);
                    dSgenidx    =   gendmidx(dSidx);
                    gendm(dSidx, :)     =   [];
                    genVSC(dSgenidx,:)  =   [];
                    gdmbus(dSidx)       =   [];
                    gendmidx    = find( ismember(genVSC(:, GEN_BUS), gen(:, GEN_BUS) )==0); %% index of dummy generators in genVSC matrix
                end
                
                %% Remove VSC voltage control at genPQ bus
                if ismember(dSiimaxi, genPQ)
                    dSidx           =   find(genPQ == dSiimaxi);
                    genPQ(dSidx)    = [];
                    genPQi(dSidx)   = [];
                end
            end
            
            %% Remove droop control on violated converter
            if convdc(dSiimaxi, CONVTYPE_DC)== DCDROOP;
               convdc(dSiimaxi, CONVTYPE_DC) = DCNOSLACK;
               droopdc      = setdiff( droopdc, dSiimaxi);    %% remove converter from droop converters
               slackdroopdc = setdiff(slackdroopdc,dSiimaxi); %% remove converter from slack/droop converters (additional loss iteration)
                fprintf(fd, '  Droop control at converter bus %d disabled.\n', i2edc(dSiimaxi) );
            end
        end
        
        %% recalculate converter quantities after limit check
        Itf      = conj(Ss./Vs);         %% transformer current
        Vf       = Vs + Itf.*Ztf;        %% filter side voltage
        Ssf      = Vf.*conj(Itf);        %% filter side transformer complex power
        Qf       = -Bf.*abs(Vf).^2;      %% filter reactive power
        Scf      = Ssf+j*Qf;             %% filter side converter complex power
        Ic       = conj(Scf./Vf);        %% converter current
        Vc       = Vf + Ic.*Zc;          %% converter side voltage
        Sc       = Vc.*conj(Ic);         %% converter side complex power

        %% converter active and reactive powers after limit check
        Ps       = real(Ss);
        Qs       = imag(Ss);
        Pc       = real(Sc);
        Qc       = imag(Sc);
        Pcf      = real(Scf);
        Qcf      = imag(Scf);
        Psf      = real(Ssf); 
        Qsf      = imag(Ssf);
    end
    
    %% converter losses and dc side power
    %Ploss      = calclossac(Pc, Qc, Vc, lossa, lossb, losscr, lossci);
    [Ploss,Pdc(cdci)]       = calclossdc(Pc, Qc, Vc, Pdc, Vdc, lossa, lossb, losscr, lossci);

    %Pdc(cdci)   = Pc(cdci)+Ploss(cdci);



    %%-----  dc networks power flow  -----
    %% calculate dc networks
    [Vdc, Pdc] = dcnetworkpf(Ybusdc, Vdc, Pdc,slackdc, noslackbdc, ...
        droopdc, PVdroop, Pdcset, Vdcset, dVdcset, pol, toldc, itmaxdc);

    %% calculate dc line powers
    Ifdc            = Yfdc*Vdc;                                   %% current through dc lines
    Pfdc            = pol * Vdc(branchdc(:, F_BUSDC)).*Ifdc;      %% power at the "from" bus
    Ptdc            = pol * Vdc(branchdc(:, T_BUSDC)).*(-Ifdc);   %% power at the "to" bus

    
    %%----- slack/droop bus voltage and converter loss -----
    %% Initialisation 
    Pc(slackdroopdc)    =   Pdc(slackdroopdc) - Ploss(slackdroopdc); %% Pc initialisation
    itslack             =   0;
    convergedslackdroop =   0;

    %% dc slack bus loss calculation
    while ~convergedslackdroop && itslack<=itmaxslackdroop
       %% update iteration counter and convergence variable
       itslack      =   itslack+1;
       Pcprev       =   Pc;  

       %% update slack bus powers Ps, Qc and voltage Vc
       [Ps(slackdroopdc), Qc(slackdroopdc), Vc(slackdroopdc)] = calcslackdroop( ...
           Pc(slackdroopdc), Qs(slackdroopdc),  Vs(slackdroopdc), Vf(slackdroopdc),...
           Vc(slackdroopdc), Ztf(slackdroopdc), Bf(slackdroopdc), Zc(slackdroopdc),...
           tolslackdroopint, itmaxslackdroopint);    

       %% update slack bus losses
       %Ploss(slackdroopdc)  = calclossac( ...
       %    Pc(slackdroopdc), Qc(slackdroopdc), Vc(slackdroopdc), lossa(slackdroopdc), ...
       %    lossb(slackdroopdc), losscr(slackdroopdc), lossci(slackdroopdc));
        
       [Ploss(slackdroopdc),Pdc(slackdroopdc),Pc(slackdroopdc)]  = calclossdc( ...
           Pc(slackdroopdc), Qc(slackdroopdc), Vc(slackdroopdc),Pdc(slackdroopdc),Vdc(slackdroopdc), lossa(slackdroopdc), ...
           lossb(slackdroopdc), losscr(slackdroopdc), lossci(slackdroopdc));
       %% update slack bus converter side power Pc
       %Pc(slackdroopdc) =   Pdc(slackdroopdc)-Ploss(slackdroopdc);
      

       %% slack bus tolerance check
       if max( abs(Pcprev(slackdroopdc) - Pc(slackdroopdc)) ) < tolslackdroop
           convergedslackdroop = 1;
       end
    end
    if ~convergedslackdroop
        fprintf(1, '\nSlackbus/Droop converter loss calculation of grid did NOT converge in %d iterations\n', itslack);
    end

    %% extended bus matrix update 
    busVSC(cdci,PD) = bus(cdci,PD) - Ps(cdci)*baseMVA;
    
    %% convergence check
    if max( abs(Ps_old - Ps) ) < tolacdc
        converged = 1;
    end
end

%% end of iteration
timecalc = toc;


%%-----  Post processing  -----
%% convergence
    if converged
        if output; fprintf(1, '\nSequential solution method converged in %d iterations\n', it); end
    else
        fprintf(1, '\nSequential solution method did NOT converge after %d iterations\n', it);
    end
    
%% converter limit check
if limac == 1 
    for ii = 1:length(cdci)
        cvii = cdci(ii);
        [limviol, ~, plotarg] = convlim(Ss(cvii), Vs(cvii), Vc(cvii), Ztf(cvii), ...
            Bf(cvii), Zc(cvii), Icmax(cvii), Vcmax(cvii), Vcmin(cvii), i2edc(cvii), tollim, 1);
        if limviol ~= 0     %% limits are hit
            if (convdc(cvii,CONVTYPE_DC))== DCSLACK
                fprintf(fd, '\n  Slackbus converter %d is operating outside its limits.\n', i2edc(cvii));
            elseif (convdc(cvii,CONVTYPE_DC))== DCNOSLACK
                fprintf(fd, '\n  Converter %d is operating outside its limits.\n', i2edc(cvii));
            end
        end
        if convplotopt == 2  
            convlimplot(plotarg, i2edc(cvii));
        end
    end
end

%% update bus matrix
bus(:,VM) = busVSC(:,VM);      
bus(:,VA) = busVSC(:,VA);

%% dummy generators removal
gen = genVSC(1:size(gen,1),:); 

%% update busdc matrix
busdc(:,PDC)       = Pdc*baseMVA;   
busdc(:,VDC)       = Vdc;

%% update convdc matrix
convdc(:,PCONV)    = Ps*baseMVA; 
convdc(:,QCONV)    = Qs*baseMVA;
convdc(:,VMC)      = abs(Vc); 
convdc(:,VAC)      = angle(Vc)*180/pi;
convdc(:,PCCONV)   = Pc*baseMVA;
convdc(:,QCCONV)   = Qc*baseMVA;
convdc(:,PCLOSS)   = Ploss*baseMVA;
convdc(:,VMF)      = abs(Vf);
convdc(:,VAF)      = angle(Vf)*180/pi;
convdc(:,PFIL)     = Psf*baseMVA;
convdc(:,QCONVF)   = Qsf*baseMVA;
convdc(:,QCCONVF)  = Qcf*baseMVA;

%% update branchdc matrix
branchdc(:,PFDC)   = Pfdc*baseMVA;
branchdc(:,PTDC)   = Ptdc*baseMVA;


%%-----  internal to external bus renumbering  -----
%% remove dummy converters 
convdc = convdc(cdci,:);

%% Per unit internal to external data conversion
[busdc, convdc, branchdc]=int2extpu(baseMVA,baseMVAac,...
    baseMVAdc,busdc,convdc,branchdc);

%% Undo the matrices sorting based on the bus numbers
bus( i2ebus,: )          = bus;
gen( i2egen,: )          = gen;
branch( i2ebrch,: )      = branch;
busdc( i2ebusdc,:)       = busdc;
convdc( i2econvdc,: )    = convdc;
branchdc( i2ebrchdc,: )  = branchdc;

%% ac network internal to external bus numbering
[busdc, bus, gen, branch] = int2extac(i2eac, acdmbus, busdc, bus, gen, branch);

%% dc network internal to external bus numbering
[busdc, convdc, branchdc] = int2extdc(i2edcpmt, i2edc, busdc, convdc, branchdc);

%% generator outage inclusion
gen1                = gen;      %% operational generators
gen0(:,[PG, QG])    = 0;        %% reset generator power injection
gen                 = zeros(length(gon)+length(goff), size(gen1,2));
gen(gon,  : )       = gen1;             %% include operational generators
gen(goff, 1:size(gen0,2) )  = gen0;     %% include non-operational generators

%% converter with outages inclusion
conv1               = convdc;
conv0               = [conv0, zeros(size(conv0,1), size(conv1,2)-size(conv0,2))];
convdc(conv0i, :)   = conv0;
convdc(conv1i, :)   = conv1;
if size(conv0busi,1)>0
    busdc(conv0busi(:,1), BUSAC_I) = conv0busi(:,2);
end

%% dc branch outages inclusion
brchdc1                 = branchdc;
brchdc0                 = [brchdc0, zeros(size(brchdc0,1), size(brchdc1,2)-size(brchdc0,2))];
branchdc(brchdc0i, :)   = brchdc0;
branchdc(brchdc1i, :)   = brchdc1;

%% ac branch outages inclusion
if size(branch,1) == 0 %% all infinite buses
    brch0               = [brch0, zeros(size(brch0,1), QT-size(brch0,2))]; % not necessary anymore after rewriting the code
    branch              = brch0;
else
    brch1               = branch;
    brch0               = [brch0, zeros(size(brch0,1), size(brch1,2)-size(brch0,2))];
    branch(brch0i, :)   = brch0;
    branch(brch1i, :)   = brch1;
end


%%-----  output results  -----
%% print results
if output
    printpf(baseMVA, bus, gen, branch,[],converged,timecalc);
    printdcpf(busdc, convdc, branchdc);
end

%% output results
resultsac = ([]);
resultsac.baseMVA = baseMVA;
resultsac.bus = bus;
resultsac.gen = gen;
resultsac.branch = branch;

resultsdc = ([]);
resultsdc.baseMVAac = baseMVAac;
resultsdc.baseMVAdc = baseMVAdc;
resultsdc.pol = pol;
resultsdc.busdc = busdc;
resultsdc.convdc = convdc;
resultsdc.branchdc = branchdc;

if nargout == 2 || nargout == 3 || nargout == 4
    baseMVA = resultsac;
    bus = resultsdc;
    gen = converged;
    branch =  timecalc;
end