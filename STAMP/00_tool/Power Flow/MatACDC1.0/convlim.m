function [convlimviol, Ss, plotarg] = convlim(Ss, Vs, Vc, Ztf, Bf, Zc, Icmax, Vcmax, Vcmin, convi, epslim, printopt)

% CONVLIM Check for converter operation within ac voltage and current limits.
%   [CONVLIMVIOL, SS, PLOTARG] = CONVLIM(SS, VS, VC, ZTF, BF, ZC, ICMAX, ...
%       VCMAX, VCMIN, CONVI, EPSLIM, PRINTOPT)
%
%   Converter operation checked with the converter's PQ capability diagram
%   that are calculated based on the converter limits and grid operation
%   state.
%
%   Inputs:
%       SS : grid side complex power
%       VS : grid side complex voltage
%       VC : converter side complex voltage
%       ZTF : complex transformer impedance
%       BF : filter susceptance
%       ZC : complex phase reactor
%       ICMAX : maximum converter current
%       VCMAX : maximum converter voltage
%       VCMIN : minimum converter voltage
%       CONVI : converter number
%       EPSLIM : limit value for allowed differences when a converter limit
%           is exceeded
%       PRINTOPT : print out option
%           0 = do not print results
%           1 = print results
%
%   Outputs:
%       CONVLIMVIOL : converter violation flag
%           0 = no violation
%           1 = converter reactive power violation
%           2 = converter active power violation
%       SS : Updated converter grid injection (within limits)
%       PLOTARG : arguments for converter limit plot

%   MatACDC
%   Copyright (C) 2011 Jef Beerten
%   Katholieke Universiteit Leuven
%   Dept. Electrical Engineering (ESAT), Div. ELECTA
%   Kasteelpark Arenberg 10
%   3001 Leuven-Heverlee, Belgium


fd = 1;

%% voltage limits order check
if Vcmax<Vcmin
    error([ 'Vcmin is larger than Vcmax for converter ',num2str(convi), '.']);
elseif Vcmax==Vcmin
    error([ 'Vcmin is equal to Vcmax for converter ',num2str(convi), '.']);
end


Ssold = Ss;

%% define voltage magnitudes, angles, powers
Vsm = abs(Vs);
Vsa = angle(Vs);
Vcm = abs(Vc);
Vca = angle(Vc);
Ps  = real(Ss);
Qs  = imag(Ss);

%%--- initialization ---
%% load existing parameters
Zf=1./(j*Bf);
Ytf = 1./(Ztf+eps); %% avoid division by zero. If Ztf=0, Ytf=inf is not used
Yf  = j*Bf;
Yc  = 1/Zc;

%% pi-equivalent parameters of the converter station (voltage limits)
% Implementation based on: 
% J. Beerten, S. Cole and R. Belmans: "Generalized Steady-State VSC MTDC 
% Model for Sequential AC/DC Power Flow Algorithms", IEEE Trans. Pow.
% Syst., vol. 27, no. 2, 2012, pp. 821 - 829.
%           ======
%  --------|  Z2  |---------
%    ||     ======     ||
%   ====              ====
%  |    |            |    |
%  | Z1 |            | Z3 |
%  |    |            |    |
%   ====              ====
%    ||                ||
%
% Expressions for Z3 and Y3 are not included, since not used in program

if Ztf ~=0 && Bf ~=0
    Z1 = (Ztf.*Zc+Zc.*Zf+Zf.*Ztf)./Zc;
    Z2 = (Ztf.*Zc+Zc.*Zf+Zf.*Ztf)./Zf;
elseif Ztf == 0 && Bf ~=0
    Z1 = Zf;
    Z2 = Zc;
elseif Ztf ~= 0 && Bf ==0
    Z1 = inf;
    Z2 = Ztf+Zc;
else %% Ztf == 0 && Bf ==0
    Z1 = inf;
    Z2 = Zc;
end
Y1 = 1./Z1;
Y2 = 1./Z2;
G2 = real(Y2);
B2 = imag(Y2);
Y12 = Y1+Y2;
G12 = real(Y12);
B12 = imag(Y12);


%%--- voltage and current limit parameters ----
%% maximum current limit circle parameters
MPL1    = -Vsm.^2.*(1./(conj(Zf)+conj(Ztf)))*(Bf~=0)+...
            (0+j*0)*(Bf==0);  %% center of the current limit
rL1     = Vsm.*Icmax.*(...
            (Ztf~=0)*(abs(conj(Ytf)./(conj(Yf)+conj(Ytf))))+...
            (Ztf==0)*1); %% radius of current limit circle
        
%% maximum and minimal active power on current limit
PmaxL1  = real(MPL1)+rL1;
PminL1  = real(MPL1)-rL1;
QPmaxL1 = imag(MPL1);
QPminL1 = imag(MPL1);

%% minimum and maximum voltage limit circle parameters
MPL2    = -Vsm.^2.*conj(Y1+Y2);     %% center of the voltage limits
rL2     =  Vsm.*[Vcmin Vcmax].*abs(Y2);     %% radius of voltage limits


%%--- voltage limit compliance of min/max active power point ---
%% find intersection points of Vcmin/Vcmax and current limit circles
dL12    = sqrt((real(MPL2)-real(MPL1))^2+(imag(MPL2)-imag(MPL1))^2);
alpha   = atan((imag(MPL2)-imag(MPL1))/(real(MPL2)-real(MPL1)));
beta    = acos(((dL12^2+rL1^2)*ones(1,2)-rL2.^2)./(2*dL12*rL1));
delta   = acos(((dL12^2-rL1^2)*ones(1,2)+rL2.^2)./(2*dL12*rL2));
gamma   = [alpha-beta pi-alpha-beta];
eta     = [alpha+delta alpha-delta];

%% possible intersection points (current limit) => intersection vector
x1(1,:) = real(MPL1)+rL1*cos(gamma)';
x1(2,:) = real(MPL1)-rL1*cos(gamma)';
y1(1,:) = imag(MPL1)+rL1*sin(gamma)';
y1(2,:) = imag(MPL1)-rL1*sin(gamma)';

%% possible intersection points (voltage limits) => intersection vector
x2(1,:) = real(MPL2)+[rL2 rL2].*cos(eta);
x2(2,:) = real(MPL2)-[rL2 rL2].*cos(eta);
y2(1,:) = imag(MPL2)+[rL2 rL2].*sin(eta);
y2(2,:) = imag(MPL2)-[rL2 rL2].*sin(eta);

%% vectorize intersection point matrices
x1v     = x1(1:end)';
x2v     = x2(1:end)';
y1v     = y1(1:end)';
y2v     = y2(1:end)';

%% decrease accuracy to detect the intersection points
eps2 = 1e-8;
x1r = round(x1v/eps2)*eps2;
x2r = round(x2v/eps2)*eps2;
y1r = round(y1v/eps2)*eps2;
y2r = round(y2v/eps2)*eps2;

%% corresponding elements in intersections vectors
[x12r,x1i, x2i] = intersect(x1r,x2r);
[y12r,y1i, y2i] = intersect(y1r,y2r);

x12r1 = sortrows([x1i x12r]);
x12r2 = sortrows([x2i x12r]);
y12r1 = sortrows([y1i y12r]);
y12r2 = sortrows([y2i y12r]);

%% define intersection points (full accuracy)
VcminPQ1 = x1v(x12r1(1))+j*y1v(y12r1(1));
VcminPQ2 = x1v(x12r1(3))+j*y1v(y12r1(3));
VcmaxPQ1 = x1v(x12r1(2))+j*y1v(y12r1(2));
VcmaxPQ2 = x1v(x12r1(4))+j*y1v(y12r1(4));

%% Remove imaginary intersection points (no intersections, due to low/high voltage limits)
if isreal(x12r2(1,2))==0 || isreal(y12r2(1,2))==0 || isreal(x12r2(3,2))==0 || isreal(y12r2(3,2))==0
    VcminPQ1 = [];      %% Imaginary intersection points are found in pairs
    VcminPQ2 = [];
    if printopt == 1 
        fprintf(fd, '\n  Lower voltage limit at converter %d : No intersections with current limit were found.\n', convi );
    end
end
if isreal(x12r2(2,2))==0 || isreal(y12r2(2,2))==0 || isreal(x12r2(4,2))==0 || isreal(y12r2(4,2))==0
    VcmaxPQ1 = [];
    VcmaxPQ2 = [];
    if printopt == 1 
        fprintf(fd, '\n  Upper voltage limit at converter %d : No intersections with current limit were found.\n', convi );
    end
end

%% Define maximum and minimum power points
% Initialisation
Pmin    = PminL1;
QPmin   = QPminL1;
Pmax    = PmaxL1;
QPmax   = QPmaxL1;
% Redefine max and min power points if min/max voltage limits are high/low
if isempty(VcminPQ1) == 0 ||isempty(VcminPQ2) == 0 
    if printopt == 1 && (imag(VcminPQ1) > QPminL1 || imag(VcminPQ2) > QPmaxL1) 
        fprintf(fd, '\n  High lower voltage limit detected at converter %d. \n', convi);
    end
    if imag(VcminPQ1) > QPminL1 
        Pmin  = real(VcminPQ1);
        QPmin = imag(VcminPQ1);
    end
    if imag(VcminPQ2) > QPmaxL1 
        Pmax = real(VcminPQ2);
        QPmax = imag(VcminPQ2);
    end
end
if isempty(VcmaxPQ1) == 0 || isempty(VcmaxPQ2) == 0 
    if printopt == 1 && (imag(VcmaxPQ1) < QPminL1 || imag(VcmaxPQ2) < QPmaxL1) 
        fprintf(fd, '\n  Low upper voltage limit detected at converter %d. \n ', convi);
    end
    if imag(VcmaxPQ1) < QPminL1 
        Pmin  = real(VcmaxPQ1);
        QPmin = imag(VcmaxPQ1);
    end
    if imag(VcmaxPQ2) < QPmaxL1 
        Pmax = real(VcmaxPQ2);
        QPmax = imag(VcmaxPQ2);
    end
end


%%--- Limit check ---
if Pmin < Ps && Ps < Pmax
    %% maximum current limit (L1) 
    if imag(MPL1)<Qs 
       Qs1     = imag(MPL1) + sqrt(rL1^2-(Ps-real(MPL1))^2);
    else %% if Qs<imag(MPL1)
       Qs1     = imag(MPL1) - sqrt(rL1^2-(Ps-real(MPL1))^2);
    end

    %% minimum and maximum voltage limits (L2)
    Qs2 = imag(MPL2)+sqrt(rL2.^2-(Ps-real(MPL2)).^2);
    a    = 1+(B2/G2)^2*ones(1,2);
    b    = -2*B2/G2*(Ps+Vsm^2*G12)./(Vsm*[Vcmin Vcmax]*G2);
    c    = ((Ps+Vsm^2*G12)./(Vsm*[Vcmin Vcmax]*G2)).^2-1;
    
    %% only positive solution retained (neg. solution refers to lower part)
    sinDd   = (-b + sqrt(b.^2-4*a.*c))./(2*a);
    Dd      = asin(sinDd);
    cosDd   = cos(Dd);
    Qs2     =  Vsm^2*B12+Vsm*[Vcmin Vcmax].*(G2*sinDd-B2*cosDd);
  
    
    %% adopt working point to limits
    if Qs > imag(MPL1) 
        if Qs > min([Qs1 Qs2(2)])
            convlimviol = 1;
            Qs          = min([Qs1 Qs2(2)]);
        elseif Qs < Qs2(1)
            convlimviol = 1;
            Qs          = Qs2(1);
        else %% Qs < min([Qs1 Qs2(2)])
            convlimviol = 0;
        end
    else %% Qs < imag(MPL1) 
       if Qs < max([Qs1 Qs2(1)])
            convlimviol = 1;
            Qs          = max([Qs1 Qs2(1)]);
       elseif Qs > Qs2(2)
            convlimviol = 1;
            Qs          = Qs2(2);
       else %% Qs < min([Qs1 Qs2(2)])
            convlimviol = 0;
       end
    end


%% active power outside of current limit active power range
elseif Ps <= Pmin %% grid injected active power lower than minimum value
    %% set active power to minimum
    convlimviol = 2;
    Ps  = Pmin;
    Qs  = QPmin;   
    

else  %% if PmaxL1 <= Ps %% grid injected active power higher than maximum value
    %% set active power to maximum
    convlimviol = 2;
    Ps  = Pmax;
    Qs  = QPmax;  
    
end
  
%% define output argument Ss
Ss = Ps + j*Qs;

%% remove violation when difference is small
if abs(Ssold-Ss)<epslim
    convlimviol = 0;
end

%% define plot arguments
if convlimviol == 1
    SsIcmax = Ps+j*Qs1;
    SsVcmin = Ps+j*Qs2(1);
    SsVcmax = Ps+j*Qs2(2);
    plotarg = [convlimviol Ztf Zf Zc Y1 Y2 Yf Ytf Vs Icmax Vcmax Vcmin ...
        Ssold Ss SsIcmax SsVcmax SsVcmin];
else
    plotarg = [convlimviol Ztf Zf Zc Y1 Y2 Yf Ytf Vs Icmax Vcmax Vcmin ...
        Ssold Ss 0 0 0];
end

return;
