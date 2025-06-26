function is_current_control = build_is_current_control( kp, ki, Lc,La ,f, number,nodeAC)
    Leq = Lc + La/2;
    w_n = 2*pi*f;

    % AC_Current control
    A = [0 0;
         0 0];
    B = [1 0 -1 0 0 0;
         0 1 0 -1 0 0];
    C = [+ki 0;
         0 +ki];
    D = [+kp    0    -kp    +w_n*Leq  1 0;
          0    +kp -w_n*Leq   -kp     0 1];
        
    x = { join(['IPC',num2str(number),'.PI_idiffq']) ;...
          join(['IPC',num2str(number),'.PI_idiffd'])};

    u = { join(['IPC',num2str(number),'.idiffq_ref'])                               ;... 
          join(['IPC',num2str(number),'.idiffd_ref'])                               ;...
          join(['IPC',num2str(number),'.idiffq_c',num2str(number)])                 ;...
          join(['IPC',num2str(number),'.idiffd_c',num2str(number)])                 ;...
          join(['IPC',num2str(number),'.vn',num2str(nodeAC),'q_c',num2str(number)]) ;... 
          join(['IPC',num2str(number),'.vn',num2str(nodeAC),'d_c',num2str(number)])};
    
    y = {join( ['IPC',num2str(number),'.vdiff_q_c',num2str(number)] ) ; ...
         join( ['IPC',num2str(number),'.vdiff_d_c',num2str(number)] )};
    
    is_current_control = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end