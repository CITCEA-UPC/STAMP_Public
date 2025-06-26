function STATCOM_DC_CONTROL = STATCOM_SS_DC_CONTROL(kp, ki, number,y)
    A = [0];
    B = [1 -1];
    C = [-ki];
    D = [-kp +kp];

    x = { join(['STAT',num2str(number),'.PI_vdc'])};

    u = {join(['STAT',num2str(number),'.Vdc_ref'])  ; ... 
         join(['STAT',num2str(number),'.vdc'])     };

    

    STATCOM_DC_CONTROL = ss(A,B,C,D,'StateName',x,'InputName',u,'OutputName',y);
end