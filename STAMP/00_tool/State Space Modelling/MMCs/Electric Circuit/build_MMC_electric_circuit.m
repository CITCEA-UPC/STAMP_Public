function MMC_electric_circuit = build_MMC_electric_circuit(number,nodeAC,nodeDC,Rc,Ra,Lc,La,f)
    w_n=2*pi*f;
    Req = Rc+Ra/2;
    Leq = Lc+La/2;
   % MMC electric squeme:
    A=[-Req/Leq    -w_n       0;
        w_n         -Req/Leq  0;
        0               0     -Ra/La];

    B=[1/Leq      0       0       -1/Leq     0          0;
       0         1/Leq    0          0     -1/Leq       0;
       0            0  -1/(2*La)     0         0     +1/(2*La)];

    C=[1 0 0;
       0 1 0;
       0 0 1;
       0 0 -3];
    
    D=[0 0 0 0 0 0;
       0 0 0 0 0 0;
       0 0 0 0 0 0;
       0 0 0 0 0 0];
       
    x={ join(['IPC',num2str(number),'.idiffq'])  ; ...
        join(['IPC',num2str(number),'.idiffd'])  ; ...
        join(['IPC',num2str(number),'.isum0'])   };

    u={ join(['IPC',num2str(number),'.vdiff_q'])  ; ...
        join(['IPC',num2str(number),'.vdiff_d'])  ; ...
        join(['IPC',num2str(number),'.vsum0'])    ; ...
        join(['NET','.vn',num2str(nodeAC),'q'])   ; ...
        join(['NET','.vn',num2str(nodeAC),'d'])   ; ...
        join(['DC_NET.v',num2str(nodeDC),'DC'])} ;

    y={ join(['IPC',num2str(number),'.idiffq_local'])  ;...
        join(['IPC',num2str(number),'.idiffd_local'])  ;...
        join(['IPC',num2str(number),'.isum0'])   ;...
        join(['IPC',num2str(number),'.iDC_local'])};
    
    MMC_electric_circuit = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end