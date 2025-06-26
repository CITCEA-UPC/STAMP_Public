function vdc_control = build_vdc_control(kp, ki, isum0,vdc0, number)

    A = [0];
    B = [1 -1 0];
    C = [-ki];
    D = [-kp +kp+(2)*isum0 +(2)*vdc0];
    
    x = join(['IPC',num2str(number),'.PI_vDC']);

    u = { join(['IPC',num2str(number),'.vDC_ref'])      ; ... 
          join(['IPC',num2str(number),'.vDC_delay'])    ; ...
          join(['IPC',num2str(number),'.isum0_delay'])}       ;

    y = join(['IPC',num2str(number),'.idiffq_ref']);

    vdc_control = ss(A,B,C,D,'StateName',x,'InputName',u,'OutputName',y);
end