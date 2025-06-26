function [T_SG, T_Rsnub] = generate_SS_SG(T_SG, lp_SG, Connectivity_Matrix)

    for sg = 1:1:size(T_SG.bus,1) 
        %% GET LINEARIZATION POINT

        we_0     = 1; %T_SG.wn(sg);    
        is_q0    = lp_SG{sg}.isq0; 
        is_d0    = lp_SG{sg}.isd0; 
        ik1_q0   = lp_SG{sg}.ikq10; 
        ik2_q0   = lp_SG{sg}.ikq20;   
        ik_d0    = lp_SG{sg}.ikd0;           
        if_d0    = lp_SG{sg}.ifd0;              
        %Te_0    = initSG{sg}.Pm;    
        v_q0     = lp_SG{sg}.vsgq_pu0; 
        v_d0     = lp_SG{sg}.vsgd_pu0;      
        etheta_0 = lp_SG{sg}.etheta0; 

        vnXq0 = lp_SG{sg}.vq0; 
        vnXd0 = lp_SG{sg}.vd0; 

        %% SET VARIABLES NAMES

        SGnum   = T_SG.number(sg);
        bus  = T_SG.bus(sg);
        % Exciter
        v_q     = ['SG' num2str(SGnum) '.v_q'];
        v_d     = ['SG' num2str(SGnum) '.v_d'];
        kv      = ['SG' num2str(SGnum) '.kv'];
        v       = ['SG' num2str(SGnum) '.v'];
        v_ref   = ['SG' num2str(SGnum) '.v_ref'];
        vf_d    = ['SG' num2str(SGnum) '.vf_d'];
        ev      = ['SG' num2str(SGnum) '.ev'];

        % Governor
        w_ref   = ['SG' num2str(SGnum) '.w_ref'];
        w_kref  = ['SG' num2str(SGnum) '.w_kref'];
        we      = ['SG' num2str(SGnum) '.we'];
        kwe     = ['SG' num2str(SGnum) '.kwe'];
        P_err   = ['SG' num2str(SGnum) '.P_err'];
        p_ref   = ['SG' num2str(SGnum) '.p_ref'];
        p_kref  = ['SG' num2str(SGnum) '.p_kref'];
        deltaY  = ['SG' num2str(SGnum) '.deltaY'];

        % Turbine   
            % single-mass
            if (T_SG.genType{sg} == 0)  
                Tm_0    =  lp_SG.Pm(sg);
                Pm      = ['SG' num2str(SGnum) '.Pm'];
            % multi-mass
            elseif (T_SG.genType{sg} == 1)
                Yturb_5 = ['SG' num2str(SGnum) '.Yturb_5'];
                Yturb_4 = ['SG' num2str(SGnum) '.Yturb_4'];
                Yturb_3 = ['SG' num2str(SGnum) '.Yturb_3'];
                Tt_2    = ['SG' num2str(SGnum) '.Tt_2'];
                Tt_3    = ['SG' num2str(SGnum) '.Tt_3'];
                Tt_4    = ['SG' num2str(SGnum) '.Tt_4'];
                Tt_5    = ['SG' num2str(SGnum) '.Tt_5'];
            end

        % Electrical
        is_q    = ['SG' num2str(SGnum) '.is_q'];
        is_d    = ['SG' num2str(SGnum) '.is_d'];
        dthetae = ['SG' num2str(SGnum) '.dthetae'];
        Te      = ['SG' num2str(SGnum) '.Te'];
        ik1_q   = ['SG' num2str(SGnum) '.ik1_q']; 
        ik2_q   = ['SG' num2str(SGnum) '.ik2_q'];   
        ik_d    = ['SG' num2str(SGnum) '.ik_d'];           
        if_d    = ['SG' num2str(SGnum) '.if_d'];   
        vk_d    = ['SG' num2str(SGnum) '.vk_d']; 
        vk1_q   = ['SG' num2str(SGnum) '.vk1_q']; 
        vk2_q   = ['SG' num2str(SGnum) '.vk2_q']; 


        % voltages & currents in grid (global) ref
        vnXq = ['NET.vn' num2str(bus) 'q'];    %'NET.vs1_q' 
        vnXd = ['NET.vn' num2str(bus) 'd'];    %'NET.vs1_d'
        iq   = ['SG' num2str(SGnum) '.iq'];      %'NET.is1_q'
        id   = ['SG' num2str(SGnum) '.id'];      %'NET.is1_d'


        %%  EXCITER

        %  Voltage magnitude
        ss_V     = SS_MOD(v_q, v_q0, v_d, v_d0, v);
        ss_kV    = SS_GAIN(v, kv, 1/sqrt(v_q0^2+v_d0^2));
        ss_v     = connect(ss_V, ss_kV, {v_q v_d}, {kv});

        %  Voltage error
        ss_ev    = SS_ERROR(v_ref, kv, ev);

        %  Exciter control  
        Kexc     = T_SG.Rf_pu(sg)/T_SG.Lmd_pu(sg);
        ss_exc   = SS_EXC(T_SG.KA(sg), T_SG.TA(sg), T_SG.TB(sg), T_SG.TC(sg), Kexc, SGnum, {ev}, {vf_d});

        exc_in            = {v_q, v_d, v_ref};
        exc_out           = {vf_d};
        T_SG.ss_exciter{sg} = connect(ss_v, ss_ev, ss_exc, exc_in, exc_out);


        %%   GOVERNOR

        % Droop control to error P
        ss_kwref    = SS_GAIN(w_ref, w_kref, 1/T_SG.R(sg));
        ss_kwe      = SS_GAIN(we, kwe, 1/T_SG.R(sg));   
        ss_kew      = SS_ERROR(w_kref, kwe, P_err);

        ss_eP       = connect(ss_kwref, ss_kwe, ss_kew, {w_ref we}, {P_err});

        % add Pref   
        ss_kpref    = SS_GAIN(p_ref, p_kref,-1);
        ss_kwp      = SS_ERROR(P_err, p_kref, deltaY);
        ss_addp     = connect(ss_kpref, ss_kwp,{P_err p_ref}, {deltaY});

        gov_in        = {w_ref, we, p_ref};
        gov_out       = {deltaY};
        T_SG.ss_gov{sg} = connect(ss_eP, ss_addp, gov_in, gov_out);

        %%  TURBINES & ROTOR SHAFT

        % single-mass
        if (T_SG.genType{sg} == 0)
            T_SG.ss_turb{sg}   = SS_TURBSM(T_SG.K_hp(sg), T_SG.tau_lp(sg), deltaY, Pm, SGnum);
            T_SG.ss_shaft{sg}  = SS_SHFT(T_SG.H(sg), T_SG.D1(sg), we_0, T_SG.wn(sg), Tm_0, SGnum);

        % multi-mass
        elseif (T_SG.genType{sg} == 1)      
            ss_turb5         = SS_TURB(T_SG.T5(sg), T_SG.F5(sg), deltaY, 5, SGnum);  % STEAM CHEST (#5)     
            ss_turb4         = SS_TURB(T_SG.T4(sg), T_SG.F4(sg), Yturb_5, 4, SGnum); % REHEATER    (#4)      
            ss_turb3         = SS_TURB(T_SG.T3(sg), T_SG.F3(sg), Yturb_4, 3, SGnum); % REHEATER    (#3)       
            ss_turb2         = SS_TURB(T_SG.T2(sg), T_SG.F2(sg), Yturb_3, 2, SGnum); % REHEATER    (#2)

            turb_in          = {deltaY};
            turb_out         = {Tt_2, Tt_3, Tt_4, Tt_5};
            T_SG.ss_turb{sg}   = connect(ss_turb5, ss_turb4, ss_turb3, ss_turb2, turb_in, turb_out);

            T_SG.ss_shaft{sg}  = SS_SHFTMM(T_SG.H1(sg),T_SG.H2(sg),T_SG.H3(sg),T_SG.H4(sg),T_SG.H5(sg),T_SG.K12(sg),T_SG.K23(sg),T_SG.K34(sg),T_SG.K45(sg),T_SG.D1(sg),T_SG.D2(sg),T_SG.D3(sg),T_SG.D4(sg),T_SG.D5(sg),T_SG.wn(sg),SGnum);
            T_SG.ss_dtheta{sg} = SS_DTHETA(T_SG.wn(sg),SGnum); 
        end

        %%  ELECTRIC CIRCUIT 

        sem_u = {v_d  vk_d  vf_d  v_q  vk1_q  vk2_q  we};
        sem_y = {is_d  ik_d  if_d  is_q  ik1_q  ik2_q  Te};
        T_SG.ss_sem{sg} = SS_SEM(T_SG,we_0, is_q0, is_d0, ik1_q0, ik2_q0, if_d0, ik_d0, T_SG.wn(sg), sg, SGnum, sem_u, sem_y);

        %%  GLOBAL TO LOCAL ROTATION - POC voltage

        vst_u         = {vnXq, vnXd, dthetae}; 
        vst_y         = {v_q, v_d};
        T_SG.ss_vst{sg} = SS_ROTATE(etheta_0, vnXq0, vnXd0, T_SG.Vbpubase(sg), "glob2loc", vst_u, vst_y);

        %%  LOCAL TO GLOBAL ROTATION (INV) - POC current

        isit_u         = {is_q, is_d, dthetae};
        isit_y         = {iq, id};
        T_SG.ss_isit{sg} = SS_ROTATE(etheta_0, is_q0, is_d0, T_SG.Ibpubase(sg), "loc2glob", isit_u, isit_y);

        %% SG FULL STATE-SPACE 

        in = [{v_ref} {p_ref} {w_ref} vnXq vnXd];
        out = {is_d ik_d if_d is_q ik1_q ik2_q Te we iq id};
        
        % single-mass
        if (T_SG.genType{sg} == 0)
            T_SG.ss{sg} = connect(T_SG.ss_exciter{sg}, T_SG.ss_gov{sg}, T_SG.ss_turb{sg}, T_SG.ss_shaft{sg}, T_SG.ss_sem{sg}, T_SG.ss_vst{sg}, T_SG.ss_isit{sg}, in, out);   
        % multi-mass
        elseif (T_SG.genType{sg} == 1) 
            T_SG.ss{sg} = connect(T_SG.ss_exciter{sg}, T_SG.ss_gov{sg}, T_SG.ss_turb{sg}, T_SG.ss_shaft{sg}, T_SG.ss_dtheta{sg}, T_SG.ss_sem{sg}, T_SG.ss_vst{sg}, T_SG.ss_isit{sg}, in, out);         
        end

    end

    %%  R SNUBBER

    [T_Rsnub] = SS_RSNUB_MULT(T_SG, Connectivity_Matrix);

end