function [Load] = build_Load_in_PI(nodeAC,number,f,R,L)

    w=2*pi*f;
   
    Al = [0 -w; w 0];
    Bl = [1/L 0; 0 1/L];
    Cl = [1 0; 0 1];
    Dl = [0 0; 0 0];
    xl = {join(['Load',num2str(number),'.ilq']);...
          join(['Load',num2str(number),'.ild'])};
    ul = {join(['NET','.vn',num2str(nodeAC),'q'])  ;... 
          join(['NET','.vn',num2str(nodeAC),'d'])} ;
    yl = {join(['Load',num2str(number),'.ilq']);...
          join(['Load',num2str(number),'.ild'])};
    SS_l = ss(Al,Bl,Cl,Dl,'StateName',xl,'InputName',ul,'OutputName',yl);

    Ar = [0];
    Br = [0 0];
    Cr = [0;0];
    Dr = 1/R*[1 0 ; 0 1];
    ur = {join(['NET','.vn',num2str(nodeAC),'q']) ;... 
          join(['NET','.vn',num2str(nodeAC),'d'])};

    yr = {join(['Load',num2str(number),'.irq']) ;...
               join(['Load',num2str(number),'.ird'])};

    SS_r = ss(Ar,Br,Cr,Dr,'StateName','','InputName',ur,'OutputName',yr);

    Anus = [0];
    Bnus = [0 0 0 0];
    Cnus = [0 ; 0];
    Dnus = [-1 -1 0   0;...
            0   0 -1 -1];
    unus = {join(['Load',num2str(number),'.irq']) ;...
            join(['Load',num2str(number),'.ilq']) ;...
            join(['Load',num2str(number),'.ird']) ;...
            join(['Load',num2str(number),'.ild'])};
    ynus = {join(['Load',num2str(number),'.iq']) ;...
            join(['Load',num2str(number),'.id'])};
    
    SS_nus = ss(Anus,Bnus,Cnus,Dnus,'StateName','','InputName',unus,'OutputName',ynus);

    uLoad = {join(['NET','.vn',num2str(nodeAC),'q']) ;... 
              join(['NET','.vn',num2str(nodeAC),'d'])};

    yLoad = ynus;

    Load = connect(SS_r,SS_l,SS_nus,uLoad,yLoad);
    
end