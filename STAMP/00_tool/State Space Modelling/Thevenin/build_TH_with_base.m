function ss_Th = build_TH_with_base(NodeAC,Number,f,R,L)
    NodeA=Number;
    NodeB=NodeAC;

    if L ~= 0
        A = [-R/L -2*pi*f; 2*pi*f -R/L];
        B = [1/L 0 -1/L 0; 0 1/L 0 -1/L];
        C = [1 0; 0 1];
        D = [0 0 0 0; 0 0 0 0];
        ss_Th = ss(A,B,C,D,'StateName',{join(['TH','.iq_',num2str(NodeA),'_',num2str(NodeB)]) ; join(['TH','.id_',num2str(NodeA),'_',num2str(NodeB)])},...
            'inputname',{join(['TH',num2str(NodeA),'.vnq']);join(['TH',num2str(NodeA),'.vnd']);...
                         join(['NET','.vn',num2str(NodeB),'q']);join(['NET','.vn',num2str(NodeB),'d'])},...
            'outputname',{join(['TH',num2str(NodeA),'.iq']) ; join(['TH',num2str(NodeA),'.id'])});
    elseif L == 0
        A = [0];
        B = [0 0 0 0; 0 0 0 0];
        C = [0];
        D = (1/R)*[1 0 -1 0; 0 1 0 -1];
        ss_Th = ss(A,B,C,D,'StateName',{''},...
            'inputname',{join(['TH',num2str(NodeA),'.vnq']);join(['TH',num2str(NodeA),'.vnd']);...
                         join(['NET','.vn',num2str(NodeB),'q']);join(['NET','.vn',num2str(NodeB),'d'])},...
            'outputname',{join(['TH',num2str(NodeA),'.iq']) ; join(['TH',num2str(NodeA),'.id'])});
    end
end