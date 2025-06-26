% Initial values for Simulink model

%Synchronous generator
% Psg0 = -results.gen(ng,2)./(Ssg/1e6);  %Results from power flow 
% Qsg0 = -results.gen(ng,3)./(Ssg/1e6);
% V = results.bus(ng,8);
% delta_bus = 0;

Psg0 = T_XX.P*(Sb/Ssg);
Qsg0 = T_XX.Q*(Sb/Ssg);
V = T_XX.V;
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

%     % Calculation from Kundur 
%     Et = abs(Vin);
%     It = sqrt(Pin^2+Qin^2)/Et;
%     phi = acos(Pin/(Et*It));
%     di = atan((Xq*It*cos(phi)-Rs_pu*It*sin(phi))/(Et+Rs_pu*It*cos(phi)+Xq*It*sin(phi)));
%     delta = di; %TEST

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
w0 = wn;%results.f*2*pi; % rad/s


e_theta0 = delta0 + delta + theta_in - delta_slk; % if SG1 as slack   
%e_theta0 = delta0 + delta + theta_in; % if voltage source as slack


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
    lp.etheta0 = e_theta0 ; 

%     lp.vq0 = Vq_NET;
%     lp.vd0 = Vd_NET;
%     lp.iq0 = Iq_NET;
%     lp.id0 = Id_NET;

    lp_SG{end+1} = lp;
    clear lp
