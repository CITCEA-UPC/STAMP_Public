function vdc_control = build_vdc_control3(kp, ki, number)

    A = [0];
    B = [1 -1];
    C = [-ki];
    D = [-kp +kp];
    
    x = join(['IPC',num2str(number),'.PI_vDC']);

    u = { join(['IPC',num2str(number),'.vDC_ref'])      ; ... 
          join(['IPC',num2str(number),'.vDC_delay'])    }       ;

    y = join(['IPC',num2str(number),'.idiffq_ref']);

    vdc_control = ss(A,B,C,D,'StateName',x,'InputName',u,'OutputName',y);
end