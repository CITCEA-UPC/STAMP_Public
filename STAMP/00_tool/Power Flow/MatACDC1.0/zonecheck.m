function zonecheck(bus, gen, branch, i2eac, output)

%ZONECHECK Check for non-synchronized ac zones.
%    ZONECHECK(BUS, GEN, BRANCH, I2EAC)
%
%   Check for non-synchronized ac zones. If present, the presence of one
%   and only one slack bus is checked, as well as the presence of ac 
%   connections between the zones, in wich case an error message is
%   displayed.
%
%   Inputs:
%       BUS : ac bus matrix
%       GEN : generator matrix
%       BRANCH : ac branch matrix
%       I2EAC : internal to external ac indices

%   MatACDC
%   Copyright (C) 2012 Jef Beerten
%   University of Leuven (KU Leuven)
%   Dept. Electrical Engineering (ESAT), Div. ELECTA
%   Kasteelpark Arenberg 10
%   3001 Leuven-Heverlee, Belgium

%% define named indices into bus, gen, branch matrices
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, ...
    VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, ...
    MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, ...
    QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, ...
    TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ...
    ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;

aczones = sort(unique(bus(:,ZONE)));

if length(aczones)>1
    if output; 	fprintf(1, '\nNon-synchronised zones: %d AC zones detected.\n', length(aczones)); end;
end

%% check interzonal connections
branchzone = [bus(branch(:,F_BUS),ZONE) bus(branch(:,T_BUS),ZONE)]; 
branchconfl = branchzone(:,1)~=branchzone(:,2);

if sum(branchconfl ~= 0)
    brconfl     = [branch(branchconfl,F_BUS) branch(branchconfl,T_BUS)];
    fprintf(1, '\nRemove branch between buses %d and %d.\n', i2eac(brconfl'));
    error('Connection between different AC zones detected.')
end

%% check for one ac slack bus (with a generator) in every zone
%   addition to original matpower code to avoid that MATPOWER takes a
%   voltage controlling converter (dummy generator) and uses it as an ac
%   slack bus when there is no generator present.
acslack     = find(bus(:, BUS_TYPE)==REF);
acslackz    = sort(bus(acslack,ZONE));
acinf       = find(bus(:, BUS_TYPE)==inf);
acinfz      = sort(bus(acinf,ZONE));
nogenslack  = setdiff(acslack, gen(:,GEN_BUS));

if length(acslackz) ~= length(aczones) 
    %% ac zones without slack bus
    if length(acslackz) < length(aczones)
        zone_noslack = setdiff(aczones, acslackz);
        zone_noslack_noinf = setdiff(zone_noslack, acinfz);
        if zone_noslack_noinf
            fprintf(1, '\nNo AC slack bus detected in AC zone %d.\n', zone_noslack_noinf);
            error('Define an AC slack bus for every non-synchronized zone!');
        end
    %% multiple slack buses in ac zone
    elseif length(acslackz) > length(aczones) %% could also be 2 in one zone
        acslackzs = sort(acslackz);
        multslack = acslackzs(acslackzs == circshift(acslackzs,1));
        fprintf(1, '\nMultiple AC slack bus detected in AC zone %d.\n', multslack);
        error('Reduce number of AC slack buses to 1 for every non-synchronized zone!');
    end
else %% length(acslackz) == length(aczones) %% check for multiple ac slack buses in one zone and inf bus zones
    if acinf
        acslackzs = sort(acslackz);
        multslack = acslackzs(acslackzs == circshift(acslackzs,1));
        if length(multslack)>1
            fprintf(1, '\nMultiple AC slack bus detected in AC zone %d.\n', multslack);
            error('Reduce number of AC slack buses to 1 for every non-synchronized zone!');
        end
    end
end

%% check  for a generator for every slack bus
if isempty(nogenslack) == 0
    fprintf(1, '\nAC slack bus without generator at bus %d.\n', i2eac(nogenslack));
    error('Add a generator for every AC slack bus!');
end

%% check for connections to infinite buses
fbusinf = intersect(branch(:,F_BUS), acinf);
tbusinf = intersect(branch(:,T_BUS), acinf);
brchinf = [fbusinf; tbusinf];
if ~isempty(brchinf)
    fprintf(1, '\n Connection with an infinite bus at bus %d.\n', i2eac(brchinf));
    error('Remove connections to infinite buses!');
end

%% check for one infinite bus in every zone (without other buses)
busi        = bus(:,BUS_I);                 %% bus number of dc busses
acninf      = setdiff(busi,acinf);
acninfz     = sort(bus(acninf,ZONE));
conflinfz   = intersect(acinfz, acninfz);

if conflinfz
    fprintf(1, '\n Infinite buses and regular buses detected in zone %d.\n', conflinfz);
    error('Remove infinite or regular buses!');    
end

%% check for multiple infinute buses in 1 AC zone
multinf = acinfz(acinfz == circshift(acinfz,1));
if length(multinf) > 1
    fprintf(1, '\nMultiple infinite buses detected in AC zone %d.\n', unique(multinf));
    error('Reduce number of infinite buses to 1 for every non-synchronized zone!');
end

return;