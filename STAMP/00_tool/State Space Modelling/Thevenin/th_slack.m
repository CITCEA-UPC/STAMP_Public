%% GFOR as slack

function delta_slk = th_slack(T_XX, Sb)

    Sth  = T_XX.Sn;       % TH rated power, TH power base  
              
    R = T_XX.R;
    X = T_XX.X;

    %Data from the power-flow
    Vg       = T_XX.V/sqrt(3);
    Pth    = T_XX.P*(Sb/Sth);
    Qth    = T_XX.Q*(Sb/Sth);
        
    % Calculation of voltages and currents (REF: NET-POC)
    Ig       = conj((Pth+1i*Qth)./(3*Vg)); % Transformer current
    U        = (Vg + Ig*(R+1i*X))*sqrt(2); % Voltage at capacitor bus
    theta_in = atan2(imag(U),real(U)); % angle between POC and capacitor bus
    
    % Calculate angles
    delta_slk = theta_in; 


    % Z = R+1i*X;
    % %Operator a:
    % a=cos(2*pi/3) + 1i*sin(2*pi/3);
    % 
    % %Initial value calculation:
    % [U_PCC_r,U_PCC_i]   = pol2cart(0, T_XX.V/sqrt(3)); % phase-to-ground RMS
    % U_PCC_vec           = U_PCC_r+1i*U_PCC_i;
    % S_TH                = Pth+1i*Qth;
    % Is_Th               = conj(S_TH/(3*U_PCC_vec)); % phase current rms
    % 
    % % Phase-to-ground peak
    % Vtha = (U_PCC_vec+Z*Is_Th)*sqrt(2);
    % Vthb = (U_PCC_vec+Z*Is_Th)*sqrt(2)*a^2;
    % Vthc = (U_PCC_vec+Z*Is_Th)*sqrt(2)*a;
    % 
    % angle(Vtha);


end