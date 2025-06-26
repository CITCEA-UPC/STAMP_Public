function vdc_control = build_vdc_control2(k,kp, ki, uq_0,iq_0,ud_0,id_0, number,nodeAC)
    %Droop Control
    Ad = [0];
    Bd = [0 0];
    Cd = [0];
    Dd = [-k +k];

    xd = '';
    ud = { join(['IPC',num2str(number),'.vDC_ref'])        ;...
           join(['IPC',num2str(number),'.vDC_delay'])};
    yd = {join(['IPC',num2str(number),'.Pac_ref_total'])};
    
    vDC_droop = ss(Ad,Bd,Cd,Dd,'StateName',xd,'InputName',ud,'OutputName',yd);

    %Active Power Controller
    API = [0];
    BPI = [1 1 (-3/2*iq_0) (-3/2*uq_0) (-3/2*id_0) (-3/2*ud_0)];
    CPI = [ki];
    DPIU = kp*[1 1 (-3/2*iq_0) (-3/2*uq_0) (-3/2*id_0) (-3/2*ud_0)];
    
    xPI = join(['IPC',num2str(number),'PI_Pac']);

    uPI = { join(['IPC',num2str(number),'.Pac_ref'])                                   ; ... 
            join(['IPC',num2str(number),'.Pac_ref_total'])                             ; ... 
            join(['IPC',num2str(number),'.vn',num2str(nodeAC),'q_c',num2str(number)])  ; ...
            join(['IPC',num2str(number),'.idiffq_c',num2str(number)])                  ; ...
            join(['IPC',num2str(number),'.vn',num2str(nodeAC),'d_c',num2str(number)])  ; ...
            join(['IPC',num2str(number),'.idiffd_c',num2str(number)])                  };

    yPI = join(['IPC',num2str(number),'.idiffq_ref']);

    Pac_control = ss(API,BPI,CPI,DPIU,'StateName',xPI,'InputName',uPI,'OutputName',yPI);

    u = { join(['IPC',num2str(number),'.Pac_ref'])                                   ; ... 
          join(['IPC',num2str(number),'.vDC_ref'])                                   ; ... 
          join(['IPC',num2str(number),'.vDC_delay'])                                 ;...
          join(['IPC',num2str(number),'.vn',num2str(nodeAC),'q_c',num2str(number)])  ; ...
          join(['IPC',num2str(number),'.idiffq_c',num2str(number)])                  ; ...
          join(['IPC',num2str(number),'.vn',num2str(nodeAC),'d_c',num2str(number)])  ; ...
          join(['IPC',num2str(number),'.idiffd_c',num2str(number)])                  };

    y = join(['IPC',num2str(number),'.idiffq_ref']);

    vdc_control = connect(vDC_droop,Pac_control,u,y);
end