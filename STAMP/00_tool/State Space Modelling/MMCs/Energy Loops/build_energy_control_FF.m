function energy_control = build_energy_control_FF(kp, ki, idiffq0, vnq0, idiffd0, vnd0, number,nodeAC, vDC)
    A = [0];
    B = [1 -1 0 0 0 0];
    C = [ki];
    D = [kp -kp ((3/2)*idiffq0)/(3*vDC) ((3/2)*vnq0)/(3*vDC) ((3/2)*idiffd0)/(3*vDC) ((3/2)*vnd0)/(3*vDC)];

    x = { join(['IPC',num2str(number),'.PI_Et'])};

    u = {join(['IPC',num2str(number),'.Et_ref'])                                    ; ... 
         join(['IPC',num2str(number),'.Et'])                                        ; ...
         join(['IPC',num2str(number),'.vn',num2str(nodeAC),'q_c',num2str(number)])  ; ...
         join(['IPC',num2str(number),'.idiffq_c',num2str(number)])                  ; ...
         join(['IPC',num2str(number),'.vn',num2str(nodeAC),'d_c',num2str(number)])  ; ...
         join(['IPC',num2str(number),'.idiffd_c',num2str(number)])};

    y = {join(['IPC',num2str(number),'.isum0_ref'])};

    energy_control = ss(A,B,C,D,'StateName',x,'InputName',u,'OutputName',y);
end