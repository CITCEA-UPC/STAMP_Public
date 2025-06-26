%% SG as slack

function delta_slk = sg_slack(T_XX, Sb, Vb)

    Ssg  = T_XX.Sb;       % SG rated power, SG power base  
    Vsg = T_XX.Vb;
              
    % Data from the power-flow
    Psg0     = T_XX.P*(Sb/Ssg);
    Qsg0     = T_XX.Q*(Sb/Ssg);
    V        = T_XX.V*(Vb/(Vsg*sqrt(3)/sqrt(2)));   

    % SG parameters
    Rs_pu = T_XX.Rs;
    Rtr   = T_XX.Rtr;
    Xtr   = T_XX.Xtr;
    Rsnb  = T_XX.Rsnb;
    Xq    = T_XX.Xq;

    % SG terminals voltage
    Itr = conj((Psg0+1i*Qsg0)./V);
    Vin = V+Itr*(Rtr+1i*Xtr);
    theta_in = atan(imag(Vin)/real(Vin));
    
    % Snubber current
    Isnb = Vin/(Rsnb);
    
    %SG current
    Isg = Isnb+Itr;
    I = abs(Isg);
    
    % Aparent power (inside the transformer)
    Sin = Vin.*conj(Isg);
    Pin = real(Sin);
    Qin = imag(Sin);
    phi = -acos(Pin./(sqrt(Pin.^2+Qin.^2))).*sign(Qin./Pin); %acos(Pin./(sqrt(Pin.^2+Qin.^2))).*sign(Qin);
    
    % Internal voltage
    E = abs(Vin)+(Rs_pu+1i*Xq).*(I.*cos(phi)+1i*I.*sin(phi));
    Eq = real(E);
    Ed = imag(E);
    
    delta = atan(Ed./Eq); %rotor angle %atan((Xq*I*cos(phi)-Rs_pu*I*sin(phi)/(abs(Vin)+Rs_pu*I*cos(phi)+Xq*I*sin(phi)))); 
    delta_slk = delta + theta_in; %rotor angle + trafo angle


end