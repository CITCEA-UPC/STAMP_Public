% Initial values for Simulink model
ng = 1;

%Synchronous generator
Psg0 = -results.gen(ng,2)./(Ssg/1e6);  %Results from power flow 
Qsg0 = -results.gen(ng,3)./(Ssg/1e6);
V = results.bus(ng,8);
delta_bus = 0;

% SG terminals voltage
Itr = conj((Psg0+i*Qsg0)./V);
Vin = V+Itr*(Rtr+i*Xtr);
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
E = abs(Vin)+(Rs_pu+i*Xq)*(I.*cos(phi)+i*I.*sin(phi));
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

delta_bus = results.bus(ng,9)*pi/180+theta_in;
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
ikd0 = zeros(length(ng),1);
ikq10 = zeros(length(ng),1);
ikq20 = zeros(length(ng),1);
vsgq_0 = Vq; % V
vsgd_0 = Vd; % V
w0_pu = 1;%results.f/fref; % pu
w0 = wn;%results.f*2*pi; % rad/s
e_theta0 = results.bus(ng,9)*pi/180+delta+theta_in; % if voltage source as slack
% e_theta0 = results.bus(1:2,9)*pi/180+delta-delta(1); % if SG1 as slack

% Voltage reference for exciter in PSCAD
Vref = Efd/Exc.KA+abs(Vin);

%% ===============================================================================================
% GRID
%===============================================================================================
% Bus voltages
% th = delta*180/pi-90+results.bus(ng,9);
% theta0 = results.bus(:,9)*pi/180; % if voltage source as slack
% % theta0 = results.bus(:,9)*pi/180-delta(1); % if SG1 as slack
% vn = results.bus(:,8)*Vb;
% 
% % As vectors
% vb_q0 = vn.*cos(theta0)*sqrt(2/3);
% vb_d0 = -vn.*sin(theta0)*sqrt(2/3);
% 
% % Branch currents (transfomers and lines)
% ibranch_q0 = Sb*1e6*results_branch(:,3)./vn(results_branch(:,1))*sqrt(2/3);
% ibranch_d0 = Sb*1e6*results_branch(:,4)./vn(results_branch(:,1))*sqrt(2/3);
% [ibranch_q0,ibranch_d0] = rotation_vect(ibranch_q0,ibranch_d0,-(theta0(results_branch(:,1))));
% 
% %Load (inductante) currents
% % n_ld = data.load(:,1);
% % Xload = data.load(:,3)*wn;
% % idL = -(vb_q0(n_ld) + i*vb_d0(n_ld))./(i*Xload);
% % idL_q0 = real(idL);
% % idL_d0 = imag(idL);
% 
% % SG current in local reference
% [isqg0,isdg0] = rotation_vect(isq0,isd0,delta);

