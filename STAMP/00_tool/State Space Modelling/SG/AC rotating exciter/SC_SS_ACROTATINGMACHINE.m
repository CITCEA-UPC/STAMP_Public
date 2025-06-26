function [ac_rotating_machine] = SC_SS_ACROTATINGMACHINE(KC,KD,KE,TE,IFD0,VE0,ac_rot,NAMEIN,NAMEOUT,NUMBER)

    substract1 = SS_SUBSTRACT(NAMEIN{1},'VFE','acrotatingmachine_error');

    %%%%
    % TE integrator:
        A     = 0;
        B     = 1/TE;
        C     = 1;
        D     = 0;
    
        TE_integrator = ss(A,B,C,D,'StateName',sprintf('SG%d.ACROTMACH_TE',NUMBER),'inputname','acrotatingmachine_error','outputname','VE'); 
    %%%%

    KE_gain = SS_GAIN('VE','KE_gain',KE);
    KD_gain = SS_GAIN(NAMEIN{2},'KD_gain',KD);
    Kline_gain = SS_GAIN('VE','Kline_gain',0.044/5.55);

    ADD3 = SS_ADD3('Kline_gain','KE_gain','KD_gain','VFE_pre');

    Gain_Kexc = SS_GAIN('VFE_pre','VFE',1);
   
    IN_CALCULATION = SS_IN_CALCULATION(KC,VE0,IFD0,{'VE' NAMEIN{2}},'IN');

    FEX_CALCULATION = SS_GAIN('IN','FEX',-0.577);

    EFD_CALCULATION = SS_EFD_CALCULATION(1,VE0,ac_rot,{'VE';'FEX'},NAMEOUT{1});

    ac_rotating_machine   = connect(Gain_Kexc,substract1,TE_integrator,KE_gain,KD_gain,Kline_gain,ADD3,IN_CALCULATION,FEX_CALCULATION,EFD_CALCULATION,NAMEIN,NAMEOUT);
end