function vac_droop_control = build_vac_droop_control(kp, number, nodeAC)
    A= [0];
    B = [0 0];
    C = [0];
    D = [kp -kp];
    
    x = '';

    u = { join(['VSC',num2str(number),'.vn',num2str(nodeAC),'_ref'])  ;...
          join(['VSC',num2str(number),'.vn',num2str(nodeAC),'_filt'])};

    y = { join(['VSC',num2str(number),'.idiffd_ref'])};
    
    vac_droop_control = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end