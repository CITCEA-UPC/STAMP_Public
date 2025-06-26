function total_energy = build_total_energy(idiffq0,idiffd0,vdiffq0,vdiffd0,isum0,vsum0, number)
    % MMC arm's capacitors (simplification to total energy dynamics Wt)
    A=[0];

    B=[-3*idiffq0/2 -3*idiffd0/2 -3*vdiffq0/2 -3*vdiffd0/2 3*isum0 3*vsum0];
    
    C=[1];
    D=[0 0 0 0 0 0];
    
    x={ join(['IPC',num2str(number),'.Et'])};

    u={ join( ['IPC',num2str(number),'.vdiff_q']) ; ...
        join( ['IPC',num2str(number),'.vdiff_d']) ; ...
        join(['IPC',num2str(number),'.idiffq'])   ;...
        join(['IPC',num2str(number),'.idiffd'])   ;...
        join( ['IPC',num2str(number),'.vsum0'])   ; ...
        join( ['IPC',num2str(number),'.isum0'])  };

    y={ join(['IPC',num2str(number),'.Et_predelay'])} ;
    
    total_energy = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end