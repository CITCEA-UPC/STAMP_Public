function vac_low_pass_filter = build_vac_low_pass_filter(tau, uq0, ud0, number,nodeAC)
    A = [-1/tau];
    B = 1/tau*[ ( uq0 / sqrt( uq0^2 + ud0^2) ) ( ud0 / sqrt( uq0^2 + ud0^2) )];
    C = 1;
    D = [0 0];
    
    x = join(['VSC',num2str(number),'.Filt_vn',num2str(nodeAC)]);

    u = { join(['VSC',num2str(number),'.vn',num2str(nodeAC),'q_c',num2str(number)]);
          join(['VSC',num2str(number),'.vn',num2str(nodeAC),'d_c',num2str(number)])};

    y = join(['VSC',num2str(number),'.vn',num2str(nodeAC),'_filt']);

    vac_low_pass_filter = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end