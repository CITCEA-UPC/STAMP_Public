function change_pu = build_change_pu(Sbl2g,number)
    A = [0];

    B = [0 0 0];
    
    C = [0;0;0];

    D = [Sbl2g  0     0 ;...
          0   Sbl2g   0 ;...
          0     0   Sbl2g];
    
    x = {''};

    u = { join(['IPC',num2str(number),'.idiffq_local'])  ;...
          join(['IPC',num2str(number),'.idiffd_local'])  ;...
          join(['IPC',num2str(number),'.iDC_local'])};

    y = { join(['IPC',num2str(number),'.idiffq'])  ;...
          join(['IPC',num2str(number),'.idiffd'])  ;...
          join(['IPC',num2str(number),'.iDC'])};
    
    change_pu = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end