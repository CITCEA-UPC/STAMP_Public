% AC side voltage control:
function AC_voltage_control = build_AC_voltage_control( kp, ki , f , Ccable , nodeAC ,number)
    w_n = 2*pi*f;
    
    A= [0 0;
       0 0];
    B = [1 -1 0 0;
         0 0 1 -1];
    C = [+ki 0;
         0 +ki];
    D = [+kp        -kp       0  +w_n*Ccable ;
         0     -w_n*Ccable    kp   -kp ];
        
    x =   {join(['IPC',num2str(number),'PI_vnq']) ;...
           join(['IPC',num2str(number),'PI_vnd'])  };

    u = { join(['IPC',num2str(number),'.vnq',num2str(nodeAC),'_ref'])                     ;...
          join(['IPC',num2str(number),'.vn',num2str(nodeAC),'q_c',num2str(number)]) ;...
          join(['IPC',num2str(number),'.vnd',num2str(nodeAC),'_ref'])                     ;...
          join(['IPC',num2str(number),'.vn',num2str(nodeAC),'d_c',num2str(number)])};

    y = { join(['IPC',num2str(number),'.idiffq_ref']) ;...
          join(['IPC',num2str(number),'.idiffd_ref']) };
    AC_voltage_control = ss(A , B , C , D,'StateName',x,'inputname',u,'outputname',y);
end