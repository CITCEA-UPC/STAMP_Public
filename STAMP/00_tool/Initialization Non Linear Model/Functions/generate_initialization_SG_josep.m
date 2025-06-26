function [init_SG, initMachineBlocks] =  generate_initialization_SG(T_SG,T_global)
    
    init_SG = cell(1,height(T_SG));
    initMachineBlocks = cell(height(T_SG),13);

    for sg = 1:1:height(T_SG)  
               
        Ssg = T_SG.Sb(sg);       % SG rated power, SG power base  
        Vsg = T_SG.Vb(sg);
        Ibsg = Ssg/Vsg;
        Sb  = T_global.Sb(T_global.Area == T_SG.Area(sg)); % System power base
        Vb  = T_global.Vb(T_global.Area == T_SG.Area(sg));
        Ib = Sb/Vb;
    
        % SG parameters
        Rs_pu  = T_SG.Rs(sg);
        Rtr    = T_SG.Rtr(sg);
        Xtr    = T_SG.Xtr(sg);
        Rsnb   = T_SG.Rsnb(sg);
        Xq     = T_SG.Xq(sg);
        Xd     = T_SG.Xd(sg);
        Xd_tr  = T_SG.Xd_tr(sg);
        Lmd_pu = T_SG.Lmd_pu(sg);

        % Data from the power-flow 
        delta0   = T_SG.theta(sg)*pi/180;
        V        = T_SG.V(sg);          % PCC line-line voltage RMS
        Psg0     = T_SG.P(sg);
        Qsg0     = T_SG.Q(sg);
    
        % PF and Simulation is in pu base RMS-LL
        % SG is in pu base peak F-N
            % To go from pu base RMS-LL --> pu base peak F-N : x sqrt(3)/sqrt(2)
    
        % Kundur Section 3.6.2 : in steady-state analysis, we are
        % interested in RMS values rather tan peak. Thus, terminal voltage
        % Et (V) refers to RMS F-N voltage
            % Thus, equations P = VI* expect V in RMS,F-N:  x 1/sqrt(3) ??
        % In Example 3.2 they say "terminal voltage is rated voltage" and
        % set Et = 1pu. Thus, i leave it as it is..
                        
        % SG terminals voltage
        Itr = conj((Psg0+1i*Qsg0)./V);
        phi_tr = atan2(imag(Itr),real(Itr));   % angle of transformer current
        Vin = V + Itr*(Rtr+1i*Xtr);
        theta_in = atan(imag(Vin)/real(Vin));
       
        % Snubber current
        Isnb = Vin/(Rsnb);

        %SG current
        Isg = Isnb+Itr;
        I = abs(Isg);

        %Change to local variables:
        Vin = Vin*(Vb/(Vsg*sqrt(3)/sqrt(2)));
        I = I*(Ib/Ibsg);
        Isg = Isg*(Ib/Ibsg);
        
        % Aparent power (inside the transformer)
        Sin = Vin*conj(Isg);
        Pin = real(Sin);
        Qin = imag(Sin);
        %phi = -acos(Pin./(sqrt(Pin.^2+Qin.^2))).*sign(Qin./Pin);
        phi = -acos(Pin./(sqrt(Pin.^2+Qin.^2))).*sign(Qin);
        
        % Internal voltage
        E = abs(Vin)+(Rs_pu+1i*Xq)*(I.*cos(phi)+1i*I.*sin(phi));
        Eq = real(E);
        Ed = imag(E);
        
        Emag = abs(E);
        delta = atan(Ed./Eq); %rotor angle
        
        % qd currents
        Iq = I.*cos(-delta+phi); %local
        Id = -I.*sin(-delta+phi); %local
                
        % qd terminal voltage
        initSG.vsgq_g0 = abs(Vin).*cos(-delta); %local
        initSG.vsgd_g0 = -abs(Vin).*sin(-delta); %local
        
        delta_bus = delta0 + theta_in;
        
        % qd terminal voltage (REF: NET)
        initSG.Vq = abs(Vin).*cos(delta_bus)*sqrt(2/3); % global
        initSG.Vd = -abs(Vin).*sin(delta_bus)*sqrt(2/3);% global
        
        % Field voltage
        Eq_tr = Emag-Id*(Xq-Xd_tr);
        Efd = Eq_tr + (Xd-Xd_tr)*Id;
        initSG.Ifd = Efd/Lmd_pu;
               
        %% Calculate non-linear model initial values 
        
        % Initial values for: Syncronous Machine pu Fundamental
        % Initial conditions [dw(%) th(deg) ia,ib,ic(pu) pha,phb,phc(deg) Vf(pu)]
        initSG.dw = 0;
        initSG.th = (delta+delta_bus)*180/pi -90; 
        initSG.ia = I; 
        initSG.ib = I;
        initSG.ic = I; 
        initSG.pha = phi*180/pi +delta_bus*180/pi; 
        initSG.phb = initSG.pha - 120;
        initSG.phc = initSG.pha + 120;
    
        % Initial values for: Exciter
        initSG.Vf = Efd;
        initSG.Vref = sqrt(initSG.vsgq_g0^2 + initSG.vsgd_g0^2); 

        % Initial values for: Governor 
        initSG.Pm = Pin+(Iq.^2+Id.^2)*Rs_pu;  

        initSG.theta_in = theta_in*180/pi;

        % Ig transformer current in abc, REF:GLOBAL

        Itr_mag = abs(Itr);

        initSG.Itra = Itr_mag*sin(delta0 + phi_tr);
        initSG.Itrb = Itr_mag*sin(delta0 + phi_tr -2*pi/3);
        initSG.Itrc = Itr_mag*sin(delta0 + phi_tr +2*pi/3);
                    
        %% Initialize simulink blocks

        mech = T_SG.mech{sg};
        
        % Synchronous Machine pu Fundamental
        
        initMachineBlocks{sg,1} = [Ssg/Sb (Vsg*sqrt(3)/sqrt(2))/Vb  T_SG.fb(sg)];                    %grid in RMS,  L-L
        %initMachineBlocks{sg,1} = [Ssg/Sb sqrt(3)/sqrt(2)  T_SG.fb(sg)];     %grid in peak, F-N    
        initMachineBlocks{sg,2} = [T_SG.Rs(sg)  T_SG.Ll_pu(sg)  T_SG.Lmd_pu(sg)  T_SG.Lmq_pu(sg)];
        initMachineBlocks{sg,3} = [T_SG.Rf_pu(sg)  T_SG.Lfd_pu(sg)];
        initMachineBlocks{sg,4} = [T_SG.R1d_pu(sg)  T_SG.L1d_pu(sg)  T_SG.R1q_pu(sg)   T_SG.L1q_pu(sg)  T_SG.R2q_pu(sg)  T_SG.L2q_pu(sg)];
        initMachineBlocks{sg,6} = [initSG.dw initSG.th initSG.ia initSG.ib initSG.ic initSG.pha initSG.phb initSG.phc initSG.Vf];
        initMachineBlocks{sg,7} = [initSG.Pm initSG.th];

        % Mechanical    

        % Give initial values
        initMachineBlocks{sg,8}  = [0 0 0 0]; % Multi-mass time turbine constants T2, T3, T4, T5
        initMachineBlocks{sg,9}  = [0.3 0.3 0.2 0.2]; % Multi-mass steam fractions F2, F3, F4, F5
        initMachineBlocks{sg,10} = [1 1 1 1]; % Multi-mass inertia contsants H2, H3, H4, H5
        initMachineBlocks{sg,11} = [0 0 0 0]; % Multi-mass shaft stifnesses K12, K23, K34, K45
        initMachineBlocks{sg,12} = [0 0 0 0]; % Multi-mass damping coefficients D2, D3, D4, D5
        initMachineBlocks{sg,13} = [0 0];   % Single-mass turbine parameters K_hp, tau_lp
        initMachineBlocks{sg,14} = [0 0 0 0]; % Governor Type 1 - IEEEG1 parameters T1, T2, T3, Dt
        initMachineBlocks{sg,15} = [0 0 0 0 0 0 0 0 0 0 0 0]; % Turbine - IEEEG1 parameters K1, K3, K5, K7, K2, K4, K6, K8, T4, T5, T6, T7    
        initSG.delta1 = 0;
        initSG.delta2 = 0;
        initSG.delta3 = 0;
        initSG.delta4 = 0;
        initSG.delta5 = 0;
       
        switch T_SG.govturb{sg}
            case "no"
                initMachineBlocks{sg,5} = [T_SG.H(sg)  T_SG.D(sg) 1];

            case "TANDEM-SINGLE"
                initMachineBlocks{sg,5}  = [T_SG.H(sg)  T_SG.D(sg) 1];   
                initMachineBlocks{sg,13} = [mech.K_hp mech.tau_lp];  

            case "TANDEM-MULTI"
                initMachineBlocks{sg,5}  = [mech.H1    mech.D1   1];
                initMachineBlocks{sg,8}  = [mech.T2    mech.T3   mech.T4   mech.T5];
                initMachineBlocks{sg,9}  = [mech.F2    mech.F3   mech.F4   mech.F5];
                initMachineBlocks{sg,10} = [mech.H2    mech.H3   mech.H4   mech.H5];
                initMachineBlocks{sg,11} = [mech.K12   mech.K23  mech.K34  mech.K45];
                initMachineBlocks{sg,12} = [mech.D2    mech.D3   mech.D4   mech.D5];

                % Initialize Multi-mass shaft M2 to M5:
                Pm = initSG.Pm;
                initSG.delta1 = initSG.th*pi/180; % M1, unused
                initSG.delta2 = initSG.delta1 + Pm/mech.K12; %M2
                initSG.delta3 = Pm*(1-mech.F2)/mech.K23 + initSG.delta2; %M3
                initSG.delta4 = Pm*(1-mech.F2-mech.F3)/mech.K34 + initSG.delta3; %M4
                initSG.delta5 = Pm*(1-mech.F2-mech.F3-mech.F4)/mech.K45 + initSG.delta4; %M5

            case "IEEEG1"
                initMachineBlocks{sg,5} = [T_SG.H(sg)  T_SG.D(sg) 1];
                initMachineBlocks{sg,14} = [mech.T1 mech.T2 mech.T3 mech.Dt]; 
                initMachineBlocks{sg,15} = [mech.K1 mech.K3 mech.K5 mech.K7 mech.K2 mech.K4 mech.K6 mech.K8 mech.T4 mech.T5 mech.T6 mech.T7]; 

        end

        init_SG{sg} = initSG;
    
    end
end
