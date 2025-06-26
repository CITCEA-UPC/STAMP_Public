function trafo = build_trafo(number,nodeA,nodeB,R,X,f)

L = X/2/pi/f;

%     if nodeA>nodeB
%         nodeB_previ=nodeB;
%         nodeB=nodeA;
%         nodeA=nodeB_previ;
%     end
    w_n=2*pi*f;
   % MMC electric squeme:
    A=[-R/L    -w_n       ;
        w_n         -R/L  ];

    B=[1/L      0             -1/L       0 ;
       0         1/L            0     -1/L];
    
    C=[-1  0;
       0  -1;
       1  0;
       0  1];
    
    D=[0 0 0 0;
       0 0 0 0; 
       0 0 0 0;
       0 0 0 0];
       
    x={ join(['Trafo',num2str(number),'.iq'])  ; ...
        join(['Trafo',num2str(number),'.id'])  };

    u={ join(['NET.vn',num2str(nodeA),'q'])     ; ...
        join(['NET.vn',num2str(nodeA),'d'])     ; ...
        join(['NET.vn',num2str(nodeB),'q'])     ; ...
        join(['NET.vn',num2str(nodeB),'d'])   } ;

    y={ join(['Trafo',num2str(number),'.iq',num2str(nodeA)])  ;...
        join(['Trafo',num2str(number),'.id',num2str(nodeA)])  ;...
        join(['Trafo',num2str(number),'.iq',num2str(nodeB)])  ;...
        join(['Trafo',num2str(number),'.id',num2str(nodeB)])  };
    
    trafo = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
end