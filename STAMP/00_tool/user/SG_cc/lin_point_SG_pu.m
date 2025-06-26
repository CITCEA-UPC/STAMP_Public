% Initial values for Simulink model

% k = 1; % if non-linear is in peak-fn pu base
% k = sqrt(2/3); % if non-linear is in rms-ll pu base

Psg0 = T_XX.P*(Sb/Ssg);
Qsg0 = T_XX.Q*(Sb/Ssg);
V = T_XX.V/sqrt(3); %rms ph-gnd
delta0 = T_XX.delta*pi/180; 


% SG terminals voltage
Itr = conj((Psg0+1i*Qsg0)./V);
Vin = V + Itr*(Rtr+1i*Xtr);
theta_in = atan(imag(Vin)/real(Vin));

% Snubber current
Isnb = Vin/(Rsnb);

%SG current
Isg = Isnb+Itr;
I = abs(Isg);

% Aparent power (inside the transformer)
Sin = Vin*conj(Isg);
Pin = real(Sin);
Qin = imag(Sin);
phi = -acos(Pin./(sqrt(Pin.^2+Qin.^2))).*sign(Qin./Pin);

% Internal voltage
E = abs(Vin)+(Rs_pu+1i*Xq)*(I.*cos(phi)+1i*I.*sin(phi));
Eq = real(E);
Ed = imag(E);

Emag = abs(E);
delta = atan(Ed./Eq); %rotor angle

% qd currents
Iq = I.*cos(-delta+phi);
Id = -I.*sin(-delta+phi);

% qd terminal voltage
vsgq_g0 = abs(Vin).*cos(-delta); %local
vsgd_g0 = -abs(Vin).*sin(-delta); %local

delta_bus = delta0 + theta_in - delta_slk;

% qd terminal voltage (REF: NET)
Vq = abs(Vin).*cos(delta_bus); % global
Vd = -abs(Vin).*sin(delta_bus);% global

% Field voltage
Eq_tr = Emag-Id*(Xq-Xd_tr);
Efd = Eq_tr + (Xd-Xd_tr)*Id;
Ifd = Efd/Lmd_pu;

% Governor
Pm0 = Pin+(Iq.^2+Id.^2)*Rs_pu;

% Initial values for linear model
isq0 = Iq;  % pu
isd0 = Id;  % pu
ifd0 = Ifd; % pu
ikd0 = 0;
ikq10 = 0;
ikq20 = 0;
vsgq_0 = Vq; % V
vsgd_0 = Vd; % V
w0_pu = 1;%results.f/fref; % pu
w0 = wb;%results.f*2*pi; % rad/s


e_theta0 = delta0 + delta + theta_in - delta_slk; % if SG1 as slack   


% Voltage reference for exciter in PSCAD
%Vref = Efd/Exc.KA+abs(Vin);

%% Store linearization point

    lp.isq0 = Iq;  % pu
    lp.isd0 = Id;  % pu
    lp.ifd0 = Ifd; % pu
    lp.ikd0 = 0;
    lp.ikq10 = 0;
    lp.ikq20 = 0;
    lp.vsgq_pu0 = Vq; % V
    lp.vsgd_pu0 = Vd; % V
    lp.w0_pu = 1; %results.f/fref; % pu
    lp.w0 = w0; %results.f*2*pi; % rad/s
    lp.etheta0 = e_theta0; 

%     lp.vq0 = Vq_NET;
%     lp.vd0 = Vd_NET;
%     lp.iq0 = Iq_NET;
%     lp.id0 = Id_NET;

    lp_SG{end+1} = lp;
    clear lp
