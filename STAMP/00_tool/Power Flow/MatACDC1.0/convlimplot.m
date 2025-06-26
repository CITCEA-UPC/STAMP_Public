function convlimplot (plotarg, convi)

% CONVLIMPLOT Plots converter limits and violations in PQ capability chart.
%   CONVLIMPLOT (PLOTARG, CONVI)
%
%   Graphical representation of converter limit violations
%
%   Inputs:
%       PLOTARG : arguments for converter limit plot
%       CONVI : converter number
%
%           The PLOTARG elements are:  
%           idx - NAME      description
%           ---   --------  ---------------------------------------
%            1  - VIOL      converter limit violation type
%                               0 - no limit hit
%                               1 - reactive power violation
%                               2 - active power violation
%            2  - ZTF       transformer impedance
%            3  - ZF        filter impedance
%            4  - ZC        converter impedance
%            5  - Y1        pi-equivalent admitance 1 (see convlim)
%            6  - Y2        pi-equivalent admitance 2 (see convlim)
%            7  - YF        filter admitance
%            8  - YTF       transformer admitance
%            9  - VS        grid voltage
%           10  - ICMAX     converter current limit
%           11  - VCMMAX    converter upper voltage limit
%           12  - VCMMIN    converter lower voltage limit
%           13  - SSOLD     grid side apparent power before limiting
%           14  - SSNEW     grid side apparent power after limiting
%           15  - SSICMAX   grid side apparent power: converter current
%                           limit (Ps constant)
%           16  - SSVCMAX   grid side apparent power: converter upper 
%                           voltage limit (Ps constant)
%           17  - SSVCMIN   grid side apparent power: converter lower 
%                           voltage limit (Ps constant)

%   MatACDC
%   Copyright (C) 2012 Jef Beerten
%   University of Leuven (KU Leuven)
%   Dept. Electrical Engineering (ESAT), Div. ELECTA
%   Kasteelpark Arenberg 10
%   3001 Leuven-Heverlee, Belgium

% Implementation based on: 
% J. Beerten, S. Cole and R. Belmans: "Generalized Steady-State VSC MTDC 
% Model for Sequential AC/DC Power Flow Algorithms", IEEE Trans. Pow.
% Syst., vol. 27, no. 2, 2012, pp. 821 - 829.

%%--- initialisation ---
%% define arguments
viol    = plotarg(1);
Ztf     = plotarg(2);
Zf      = plotarg(3);
Zc      = plotarg(4);
Y1      = plotarg(5);
Y2      = plotarg(6);
Yf      = plotarg(7);
Ytf     = plotarg(8);
Vs      = plotarg(9);
Icmax   = plotarg(10);
Vcmmax  = plotarg(11);
Vcmmin  = plotarg(12);
Ssold   = plotarg(13);
Ssnew   = plotarg(14);
SsIcmax = plotarg(15);
SsVcmax = plotarg(16);
SsVcmin = plotarg(17);
    
%% plot assumptions in code:
%%      Vs = Vsm * exp(j*0) with Vsm constant (defined in input)
%% converter upper and lower voltage limit:
%%      Vc = Vcm * exp(Vca) with Vcm constant and Vca defined as variable
%% converter current limit:
%%      Ic = Icm * exp(Ica) with Icm constant and Ica defined as variable

%% grid side voltage amplitude
Vsm = abs(Vs);

%%--- current limits ---
%% current limit with current converter set-up
i1 = 0.001; %% plot current angle step size
Ica = [0:i1:2*pi];
SsIlim  = Vs*Icmax*exp(-j.*Ica)*...
          ((Ztf~=0 && Yf ~=0)*(conj(Ytf)/(conj(Ytf)+conj(Yf)))+...
          (Ztf==0 || Yf ==0)*1) +...
          -Vsm^2.*ones(1,length(Ica))*(1/(conj(Zf)+conj(Ztf)));
SsIlimMP = -Vsm^2.*(1/(conj(Zf)+conj(Ztf))); %middelpunt van figuur

%% current limit without filter
SsIlim1  = Vs*Icmax*exp(-j.*Ica);   %% current limit

%%--- voltage limits ---
%% voltage limits with current converter set-up
i2 = 0.001; %% plot voltage angle step size
Vca = [0:i2:2*pi];
SsVmax = -Vsm^2*conj(Y1+Y2)+Vs*Vcmmax*exp(-j.*Vca)*conj(Y2); %% upper voltage limit
SsVmin = -Vsm^2*conj(Y1+Y2)+Vs*Vcmmin*exp(-j.*Vca)*conj(Y2); %% lower voltage limit

%% voltage limits without filter
SsVmax1 = -Vsm^2*conj(1/(Ztf+Zc))+Vs*Vcmmax*exp(-j.*Vca)*conj(1/(Ztf+Zc));  %% upper voltage limit (no filter bus)
SsVmin1 = -Vsm^2*conj(1/(Ztf+Zc))+Vs*Vcmmin*exp(-j.*Vca)*conj(1/(Ztf+Zc));  %% lower voltage limit (no filter bus)


%%--- plot converter limits ---
%% plot options
xmin = -1.5/1.2*Icmax;
xmax = 1.5/1.2*Icmax;
ymin = -1.5/1.2*Icmax;
ymax = 1.5/1.2*Icmax;
ix = 0.001;
iy = 0.001;
xx = [xmin:ix:xmax];
yy = [ymin:ix:ymax];

figure
hold on
axis equal 
axis([xmin xmax ymin ymax])
box on
xlabel('P_s (p.u.)')
ylabel('Q_s (p.u.)')

%% plot graph title
if viol ~= 0
    title(['Converter station ', num2str(convi), ' operating outside its limits.']);
elseif viol == 0
    title(['Normal operation of converter station ', num2str(convi)]);
end

%% plot axes
plot(xx,zeros(length(xx),1), 'k')
plot(zeros(length(yy),1),yy, 'k')

%% center of current limit
scatter(real(SsIlimMP), imag(SsIlimMP),'b+')

%% old active and reactive powers
scatter(real(Ssold), imag(Ssold),'k')

%% new active and reactive powers
scatter(real(Ssnew), imag(Ssnew),'k^')

%% actual limit plots
plot(real(SsIlim), imag(SsIlim),'b')
plot(real(SsVmax), imag(SsVmax),'r')
plot(real(SsVmin), imag(SsVmin),'g')

%% limit plots neglecting filter effect
plot(real(SsIlim1), imag(SsIlim1),'b:')
plot(real(SsVmax1), imag(SsVmax1),'r:')
plot(real(SsVmin1), imag(SsVmin1),'g:')

%% plot limit points
if viol == 1
    scatter(real(SsIcmax), imag(SsIcmax),'bx');
    scatter(real(SsVcmax), imag(SsVcmax),'rx');
    scatter(real(SsVcmin), imag(SsVcmin),'gx');
end

return;
