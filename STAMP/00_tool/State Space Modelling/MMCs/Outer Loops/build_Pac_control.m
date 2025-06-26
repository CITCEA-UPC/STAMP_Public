function Pac_control = build_Pac_control(kp, ki, iq_0,id_0,uq_0,ud_0, number, nodeAC)

    A = [0];
    B = [1 (-3/2*iq_0) (-3/2*uq_0) (-3/2*id_0) (-3/2*ud_0)];
    C = [ki];
    D = kp*[1 (-3/2*iq_0) (-3/2*uq_0) (-3/2*id_0) (-3/2*ud_0)];
    
    x = join(['IPC',num2str(number),'.PI_Pac']);

    u = { join(['IPC',num2str(number),'.Pac_ref'])                                   ; ... 
          join(['IPC',num2str(number),'.vn',num2str(nodeAC),'q_c',num2str(number)])  ; ...
          join(['IPC',num2str(number),'.idiffq_c',num2str(number)])                  ; ...
          join(['IPC',num2str(number),'.vn',num2str(nodeAC),'d_c',num2str(number)])  ; ...
          join(['IPC',num2str(number),'.idiffd_c',num2str(number)])}                 ;

    y = join(['IPC',num2str(number),'.idiffq_ref']);

    Pac_control = ss(A,B,C,D,'StateName',x,'InputName',u,'OutputName',y);
end