%% GFOR as slack

function delta_slk = gfor_slack(T_XX, Sb)

    Svsc  = T_XX.Sb;       % SG rated power, SG power base  
              
    Rtr = T_XX.Rtr;
    Xtr = T_XX.Xtr;

    %Data from the power-flow
    Vg       = T_XX.V/sqrt(3)/T_XX.Vbpu_l2g; % PCC line-neutral voltage RMS 
    Pvsc0    = T_XX.P*(Sb/Svsc);
    Qvsc0    = T_XX.Q*(Sb/Svsc);
        
    % Calculation of voltages and currents (REF: NET-POC)
    Ig       = conj((Pvsc0+1i*Qvsc0)./(3*Vg)); % Transformer current
    U        = Vg + Ig*(Rtr+1i*Xtr); % Voltage at capacitor bus
    theta_in = atan2(imag(U),real(U)); % angle between POC and capacitor bus
    
    % Calculate angles
    delta_slk = theta_in; 

end