% Initial values for Simulink model
Ssg_base = 100;
ng = 1;
%Synchronous generator
Psg0 = -results.gen(ng,2)./Ssg_base;  %Results from power flow 
Qsg0 = -results.gen(ng,3)./Ssg_base;
V = results.bus(ng,8);
delta_bus = 0;

% SG terminals voltage
Itr = conj((Psg0+i*Qsg0)./V);
Vin = V+Itr*(Rtr/Zb+i*Ltr*wn/Zb);
theta_in = atan(imag(Vin)/real(Vin));

% Snubber current
Isnb = Vin/(Rsnb/Zb);

%SG current
Isg = Isnb+Itr;
I = abs(Isg);

% Aparent power (inside the transformer)
Sin = Vin*conj(Isg)
Pin = real(Sin);
Qin = imag(Sin);
phi = -acos(Pin./(sqrt(Pin.^2+Qin.^2))).*sign(Qin./Pin);

% Internal voltage
E = abs(Vin)+(Rs_pu+i*Xq)*(I.*cos(phi)+i*I.*sin(phi));
Eq = real(E);
Ed = imag(E);

Emag = abs(E);
delta = atan(Ed./Eq); %rotor angle

% qd currents
Iq = I.*cos(-delta+phi);
Id = -I.*sin(-delta+phi);

% qd terminal voltage
Vq = abs(Vin).*cos(delta_bus-delta);
Vd = -abs(Vin).*sin(delta_bus-delta);

% Field voltage
Eq_tr = Emag-Id*(Xq-Xd_tr);
Efd = Eq_tr + (Xd-Xd_tr)*Id;
Ifd = Efd/Lmd_pu;

% Governor
Pm0 = Psg0+(Iq.^2+Id.^2)*Rs_pu;

% Initial values for the model
% Syncronous Machine pu Fundamental
% Initial conditions [ dw(%)  th(deg)  ia,ib,ic(pu)  pha,phb,phc(deg)  Vf(pu) ]
dw = zeros(length(ng),1);
th = delta*180/pi-90+results.bus(ng,9);
ia = I;
ib = I;
ic = I;
pha = phi*180/pi+results.bus(ng,9);
phb = pha - 120;
phc = pha+120;
Vf = Efd;
init_values_SG = [dw,th,ia,ib,ic,pha,phb,phc,Vf];
 % [0  -69.2101    0.228436    0.228436    0.228436   -6.86493 -126.865  113.135 1.12876]
 % [0  -51.3784    0.507986    0.507986    0.507986   -8.63889 -128.639  111.361 1.47645]

% Simulink initialization
% [0 -69.2106 0.228365 0.228365 0.228365 -6.86883 -126.869 113.131 1.12878]
% [0 -51.3781 0.507986 0.507986 0.507986 -8.63855 -128.639 111.361 1.47645]
%Pm = [0.22725 0.50258]

% Governor
Pm = Psg0+(Iq.^2+Id.^2)*Rs_pu;
% Pm = [0.22725 0.50258]

%Exciter
Vref = Vf/Exc.KA+V;

er_theta = results.bus(1:2,9)*pi/180+delta-pi/2;
% Display results
% disp('Initial values for Simulink model: Synchronous Machine pu Fundamental')
% disp(['delta = ',num2str(delta*180/pi-90), ' degrees']) %rotate -90º to match reference of Simulink model
% disp(['I = ',num2str(I), ' pu'])
% disp(['phi = ',num2str(phi*180/pi), ' degrees'])  
% disp(['Vfd = ',num2str(Efd), ' pu'])
