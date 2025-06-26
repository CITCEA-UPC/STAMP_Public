%--------------------------------------------------------------------
% Synchronous generator
%--------------------------------------------------------------------
[Ng] = length(ng);
for ii = 1:Ng
    %ng = data.SG(ii,1);
    % Espacio de estados turbina
    Agov = [0 1;-1/(gov.T1*gov.T3) -(gov.T1+gov.T3)/(gov.T1*gov.T3)];
    Bgov = [0 0 0;1 1/gov.R -1/gov.R ];
    Cgov = [1/(gov.T1*gov.T3) gov.T2/(gov.T1*gov.T3)];
    Dgov = [0 gov.Dt -gov.Dt];
    
    gov_x={['SG',num2str(ng(ii)),'_Gov1'],['SG',num2str(ng(ii)),'_Gov2']};
    gov_u={['SG',num2str(ng(ii)),'_Pref'],['SG',num2str(ng(ii)),'_wref'],['SG',num2str(ng(ii)),'_w_pu']};
    gov_y={['SG',num2str(ng(ii)),'_Pm']};
    gov_ss = ss(Agov,Bgov,Cgov,Dgov,'StateName',gov_x,'inputname',gov_u,'outputname',gov_y);

    % Espacio de estados exciter
    s = tf('s');
    tfexc = ((Exc.TC*s+1)/(Exc.TB*s+1)*Exc.KA/(Exc.TA*s+1))*Rf_pu/Lmd_pu;
    [Aexc,Bexc,Cexc,Dexc] = tf2ss(tfexc.num{1,1},tfexc.den{1,1});
    exc_x={['SG',num2str(ng(ii)),'_Exc1'], ['SG',num2str(ng(ii)),'_Exc2']};
    exc_u={['SG',num2str(ng(ii)),'_er_vsg']};
    exc_y={['SG',num2str(ng(ii)),'_vfd']};
    exc_ss = ss(Aexc,Bexc,Cexc,Dexc,'StateName',exc_x,'inputname',exc_u,'outputname',exc_y);

    % Espacio de estados |Vsg|
    Avsg=[0];
    Bvsg=[0 0];
    Cvsg=[0];
    Dvsg=[vsgq_pu0(ii)/sqrt(vsgq_pu0(ii)^2+vsgd_pu0(ii)^2) vsgd_pu0(ii)/sqrt(vsgq_pu0(ii)^2+vsgd_pu0(ii)^2)];
    vsg_x={''};
    vsg_u={['SG',num2str(ng(ii)),'_vsgq_pu'],['SG',num2str(ng(ii)),'_vsgd_pu']};
    vsg_y={['SG',num2str(ng(ii)),'_Vsg_mag']};
    vsg = ss(Avsg,Bvsg,Cvsg,Dvsg,'StateName',vsg_x,'inputname',vsg_u,'outputname',vsg_y);

    % Espacio de estados |Vsg|
    Aevsg=[0];
    Bevsg=[0 0];
    Cevsg=[0];
    Devsg=[1 -1];
    evsg_x={''};
    evsg_u={['SG',num2str(ng(ii)),'_vpss'],['SG',num2str(ng(ii)),'_Vsg_mag']};
    evsg_y={['SG',num2str(ng(ii)),'_er_vsg']};
    evsg = ss(Aevsg,Bevsg,Cevsg,Devsg,'StateName',evsg_x,'inputname',evsg_u,'outputname',evsg_y);

    % Espacio de estados Vsg qd: real -> pu
    Avsg_pu=[0 0;0 0];
    Bvsg_pu=[0 0; 0 0];
    Cvsg_pu=[0 0;0 0];
    Dvsg_pu=[1/(Vn*sqrt(2/3)) 0; 0 1/(Vn*sqrt(2/3))];
    vsg_pu_x={''};
    if ng(ii)==n_slk
        vsg_pu_u={['vb',num2str(ng(ii)),'q'],['vb',num2str(ng(ii)),'d']};
    else
        vsg_pu_u={['vb',num2str(ng(ii)),'qg'],['vb',num2str(ng(ii)),'dg']};
    end
    vsg_pu_y={['SG',num2str(ng(ii)),'_vsgq_pu'],['SG',num2str(ng(ii)),'_vsgd_pu']};
    vsg_pu = ss(Avsg_pu,Bvsg_pu,Cvsg_pu,Dvsg_pu,'StateName',vsg_pu_x,'inputname',vsg_pu_u,'outputname',vsg_pu_y);

    % Espacio de estados generador síncrono
    R7 = [ -Rs_pu 0 0 0 0 0 0;
             0 -Rs_pu 0 0 0 0 0;
             0 0 Rf_pu 0 0 0 0;
             0 0 0 R1d_pu 0 0 0; 
             0 0 0 0 R1q_pu 0 0;
             0 0 0 0 0 R2q_pu 0;
             0 0 0 0 0 0 0];

     M7 = [-Ll_pu-Lmq_pu 0 0 0 Lmq_pu Lmq_pu; 
         0 -Ll_pu-Lmd_pu Lmd_pu Lmd_pu 0 0; 
         0 -Lmd_pu Lfd_pu+Lmd_pu Lmd_pu 0 0;
         0 -Lmd_pu Lmd_pu L1d_pu+Lmd_pu 0 0;
         -Lmq_pu 0 0 0 L1q_pu+Lmq_pu Lmq_pu;
         -Lmq_pu 0 0 0 Lmq_pu (L2q_pu+Lmq_pu)]/wn;

    M7inv = inv(M7);
    M7inv(:,7) = zeros(6,1);
    M7inv(7,:)= zeros(1,7); 

    N7 = [0 -w0_pu*(Ll_pu+Lmd_pu) w0_pu*Lmd_pu w0_pu*Lmd_pu 0 0 (-Ll_pu-Lmd_pu)*isd0(ii)+Lmd_pu*ifd0(ii);
          w0_pu*(Ll_pu+Lmq_pu) 0 0 0 -w0_pu*Lmq_pu -w0_pu*Lmq_pu (Ll_pu+Lmq_pu)*isq0(ii); 
          0 0 0 0 0 0 0;
          0 0 0 0 0 0 0;
          0 0 0 0 0 0 0;
          0 0 0 0 0 0 0;
          0 0 0 0 0 0 0];

    %To add the mechanical equation to the state space
    matA = [zeros(6,7);-(isd0(ii)*(Lmq_pu-Lmd_pu)+Lmd_pu*ifd0(ii)) -(isq0(ii)*(Lmq_pu-Lmd_pu)) -isq0(ii)*Lmd_pu -isq0(ii)*Lmd_pu isd0(ii)*Lmq_pu isd0(ii)*Lmq_pu -Pm0(ii)/(w0_pu^2)]/2/H;
    matB = [zeros(6,7);[zeros(1,6),1/(2*H*w0_pu)]];

    Asg = [-M7inv*(N7+R7)]+matA;
    Bsg = M7inv+matB;
    Csg = [eye(7);(isd0(ii)*(Lmq_pu-Lmd_pu)+Lmd_pu*ifd0(ii)) isq0(ii)*(Lmq_pu-Lmd_pu) isq0(ii)*Lmd_pu isq0(ii)*Lmd_pu -isd0(ii)*Lmq_pu -isd0(ii)*Lmq_pu 0];%;3/2*(isd0*(Lmq_pu-Lmd_pu)+Lmd_pu*ifd0+Lmd_pu*ikd0) 3/2*(isq0*(Lmq_pu-Lmd_pu)-ikq0*Lmq_pu) 3/2*isq0*Lmd_pu 3/2*isq0*Lmd_pu -3/2*isd0*Lmq_pu 0 0];
    Dsg = zeros(8,7);

    sg_x={['SG',num2str(ng(ii)),'_isq'],['SG',num2str(ng(ii)),'_isd'],['SG',num2str(ng(ii)),'_ifd'],['SG',num2str(ng(ii)),'_ikd'],['SG',num2str(ng(ii)),'_ikq1'],['SG',num2str(ng(ii)),'_ikq2'],['SG',num2str(ng(ii)),'_w']};
    sg_u={['SG',num2str(ng(ii)),'_vsgq_pu'],['SG',num2str(ng(ii)),'_vsgd_pu'],['SG',num2str(ng(ii)),'_vfd'],['SG',num2str(ng(ii)),'_vkd'],['SG',num2str(ng(ii)),'_vkq1'],['SG',num2str(ng(ii)),'_vkq2'],['SG',num2str(ng(ii)),'_Pm']};
    sg_y={['SG',num2str(ng(ii)),'_isqg_pu'],['SG',num2str(ng(ii)),'_isdg_pu'],['SG',num2str(ng(ii)),'_ifd'],['SG',num2str(ng(ii)),'_ikd'],['SG',num2str(ng(ii)),'_ikq1'],['SG',num2str(ng(ii)),'_ikq2'],['SG',num2str(ng(ii)),'_w_pu'],['SG',num2str(ng(ii)),'_Te']};
    sg = ss(Asg,Bsg,Csg,Dsg,'StateName',sg_x,'inputname',sg_u,'outputname',sg_y);

    % Espacio de estados Isg: pu -> real
    Aisg_pu=[0 0; 0 0];
    Bisg_pu=[0 0; 0 0];
    Cisg_pu=[0 0;0 0];
    Disg_pu=[In_sg(ii) 0; 0 In_sg(ii)];
    isg_pu_x={''};  
    if ng(ii)==n_slk
        isg_pu_u={['SG',num2str(ng(ii)),'_isqg_pu'],['SG',num2str(ng(ii)),'_isdg_pu']};
    else
        isg_pu_u={['SG',num2str(ng(ii)),'_isq_pu'],['SG',num2str(ng(ii)),'_isd_pu']};
    end
    isg_pu_y={['isg',num2str(ng(ii)),'q'],['isg',num2str(ng(ii)),'d']};
    isg_pu = ss(Aisg_pu,Bisg_pu,Cisg_pu,Disg_pu,'StateName',isg_pu_x,'inputname',isg_pu_u,'outputname',isg_pu_y);

    % Espacio de estados wsg: pu -> real
    Awsg_pu=[0];
    Bwsg_pu=[0];
    Cwsg_pu=[0];
    Dwsg_pu=[wn];
    wsg_pu_x={''};
    wsg_pu_u={['SG',num2str(ng(ii)),'_w_pu']};
    wsg_pu_y={['SG',num2str(ng(ii)),'_w']};
    wsg_pu = ss(Awsg_pu,Bwsg_pu,Cwsg_pu,Dwsg_pu,'StateName',wsg_pu_x,'inputname',wsg_pu_u,'outputname',wsg_pu_y);
    
    % Espacio de estados angulo 
    Aang=[0];
    Bang=[1];
    Cang=[1];
    Dang=[0];
    ang_x={['SG',num2str(ng(ii)),'_th']};
    ang_u={['SG',num2str(ng(ii)),'_w']};
    ang_y={['SG',num2str(ng(ii)),'_th']};
    ang = ss(Aang,Bang,Cang,Dang,'StateName',ang_x,'inputname',ang_u,'outputname',ang_y);

    % Espacio de estados PSS
    Gw1 = tf([Tw1 0],[Tw1 1]);
    Gw2 = tf([Tw2 0],[Tw2 1]);
    Gw3 = tf([Tw3 0],[Tw3 1]);
    Gw4 = tf([Tw4 0],[Tw4 1]);

    Gt6 = tf([1],[T6 1]);
    Gt7 = tf([Ks2],[T7 1]);
    Gt89 = tf([T8 1].^N,[T9 1].^(M*N));
    Gt12 = tf([T1 1],[T2 1]);
    Gt34 = tf([T3 1],[T4 1]);

    Gdw = Gw1*Gw2*Gt6*Gt89*Gt12*Gt34*Ks1;
    [Gdw_num, Gdw_den] = tfdata(Gdw, 'v');

    [A,B,C,D] = tf2ss(Gdw_num,Gdw_den);
    Apss=A;
    Bpss=B;
    Cpss=C;
    Dpss=D;
    pss_state = [];
    for jj = 1:length(A)
        pss_x(jj) = {['SG',num2str(ng(ii)),'_pssx',num2str(jj)]};
    end
    pss_u={['SG',num2str(ng(ii)),'_w_pu']};
    pss_y={['SG',num2str(ng(ii)),'_vpss']};
    pss_ss = ss(Apss,Bpss,Cpss,Dpss,'StateName',pss_x,'inputname',pss_u,'outputname',pss_y);
   
    if ng(ii)~=n_slk
            % Espacio de estados diferencia de angulo con slack (SG1) 
            Adang=[0];
            Bdang=[1 -1];
            Cdang=[1];
            Ddang=[0 0];
            dang_x={['SG',num2str(ng(ii)),'_e_th']};
            dang_u={['SG',num2str(ng(ii)),'_w'],['SG',num2str(n_slk),'_w']};
            dang_y={['SG',num2str(ng(ii)),'_e_th']};
            dang = ss(Adang,Bdang,Cdang,Ddang,'StateName',dang_x,'inputname',dang_u,'outputname',dang_y);
            
            % Espacio de estados transformada global -> local
            Avgx_g=[0];
            Bvgx_g=[0 0 0];
            Cvgx_g=[0;0];
            Dvgx_g=[cos(e_theta0(ii)) -sin(e_theta0(ii)) -sin(e_theta0(ii))*vb_q0(ng(ii))-cos(e_theta0(ii))*vb_d0(ng(ii));
                  sin(e_theta0(ii)) cos(e_theta0(ii)) cos(e_theta0(ii))*vb_q0(ng(ii))-sin(e_theta0(ii))*vb_d0(ng(ii))];
            vgx_g_x={};
            vgx_g_u={['vb',num2str(ng(ii)),'q'],['vb',num2str(ng(ii)),'d'],['SG',num2str(ng(ii)),'_e_th']};
            vgx_g_y={['vb',num2str(ng(ii)),'qg'],['vb',num2str(ng(ii)),'dg']};
            vgx_g = ss(Avgx_g,Bvgx_g,Cvgx_g,Dvgx_g,'StateName',vgx_g_x,'inputname',vgx_g_u,'outputname',vgx_g_y);

            % Espacio de estados antitransformada local -> global
            Aigx_g=[0];
            Bigx_g=[0 0 0];
            Cigx_g=[0;0];
            Digx_g=[cos(e_theta0(ii)) sin(e_theta0(ii)) -sin(e_theta0(ii))*isq0(ii)+cos(e_theta0(ii))*isd0(ii);
                  -sin(e_theta0(ii)) cos(e_theta0(ii)) -cos(e_theta0(ii))*isq0(ii)-sin(e_theta0(ii))*isd0(ii)];
            igx_g_x={''};
            igx_g_u={['SG',num2str(ng(ii)),'_isqg_pu'],['SG',num2str(ng(ii)),'_isdg_pu'],['SG',num2str(ng(ii)),'_e_th']};
            igx_g_y={['SG',num2str(ng(ii)),'_isq_pu'],['SG',num2str(ng(ii)),'_isd_pu']};
            igx_g = ss(Aigx_g,Bigx_g,Cigx_g,Digx_g,'StateName',igx_g_x,'inputname',igx_g_u,'outputname',igx_g_y);
    end

    %Complete model
    input_vars = {['vb',num2str(ng(ii)),'q'],['vb',num2str(ng(ii)),'d'],['SG',num2str(ng(ii)),'_Pref'],['SG',num2str(ng(ii)),'_wref'],['SG',num2str(ng(ii)),'_vkd'],['SG',num2str(ng(ii)),'_vkq1'],['SG',num2str(ng(ii)),'_vkq2']};
    output_vars = {['isg',num2str(ng(ii)),'q'],['isg',num2str(ng(ii)),'d'],['SG',num2str(ng(ii)),'_w'],['SG',num2str(ng(ii)),'_Te']};
    if ng(ii)==n_slk 
        eval(['SS_SG',num2str(ng(ii)),' = connect(gov_ss,exc_ss,pss_ss,evsg,vsg,sg,vsg_pu,isg_pu,wsg_pu,ang,input_vars,output_vars);']);
        disp(['State space of SG',num2str(ng(ii)),' - Completed'])
    else
        input_vars = {['vb',num2str(ng(ii)),'q'],['vb',num2str(ng(ii)),'d'],['SG',num2str(ng(ii)),'_Pref'],['SG',num2str(ng(ii)),'_wref'],['SG',num2str(ng(ii)),'_vkd'],['SG',num2str(ng(ii)),'_vkq1'],['SG',num2str(ng(ii)),'_vkq2'],['SG',num2str(n_slk),'_w']};
        output_vars = {['isg',num2str(ng(ii)),'q'],['isg',num2str(ng(ii)),'d'],['SG',num2str(ng(ii)),'_w'],['SG',num2str(ng(ii)),'_Te'],['SG',num2str(ng(ii)),'_e_th']};     
        eval(['SS_SG',num2str(ng(ii)),' = connect(gov_ss,exc_ss,pss_ss,evsg,vsg,sg,vsg_pu,isg_pu,wsg_pu,ang,dang,vgx_g,igx_g,input_vars,output_vars);']);
        disp(['State space of SG',num2str(ng(ii)),' - Completed'])
    end
end