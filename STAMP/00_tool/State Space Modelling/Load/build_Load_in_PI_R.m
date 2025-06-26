function [Load] = build_Load_in_PI_R(nodeAC,number,R)


    Ar = [0];
    Br = [0 0];
    Cr = [0;0];
    Dr = 1/R*[-1 0 ; 0 -1];
    ur = {join(['NET','.vn',num2str(nodeAC),'q']) ;... 
          join(['NET','.vn',num2str(nodeAC),'d'])};

    yr = {join(['Load',num2str(number),'.iq']) ;...
          join(['Load',num2str(number),'.id'])};

    SS_r = ss(Ar,Br,Cr,Dr,'StateName','','InputName',ur,'OutputName',yr);

    Load = SS_r;
    
end