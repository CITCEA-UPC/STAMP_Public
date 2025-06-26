function Pac_low_pass_filter = build_Pac_low_pass_filter(tau, uq_0, ud_0,iq_0,id_0,number,nodeAC)
    A = [-1/tau];
    B = 1/tau*[ (3/2*iq_0) (3/2*uq_0) (3/2*id_0) (3/2*ud_0)];
    C = 1;
    D = [0 0 0 0];
    
    x = join(['IPC',num2str(number),'.Filt_Pac',num2str(nodeAC)]);

    u = { join(['IPC',num2str(number),'.vn',num2str(nodeAC),'q_c',num2str(number)])  ; ...
          join(['IPC',num2str(number),'.idiffq_c',num2str(number)])                  ; ...
          join(['IPC',num2str(number),'.vn',num2str(nodeAC),'d_c',num2str(number)])  ; ...
          join(['IPC',num2str(number),'.idiffd_c',num2str(number)])}                 ;

    y = join(['IPC',num2str(number),'.Pac_filt']);

    Pac_low_pass_filter = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end