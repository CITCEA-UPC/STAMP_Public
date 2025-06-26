function mpc_dc = parse_excel2mpc_dc()
    % Import global variables names
    setup_globals; 
    % Generate MATACDC mpc from Excel file
    % Given DATA
    nb = height(T_PF_DC);
    %% system MVA base
    %--- TO BE CHANGED!!!!!!!!!!!!
    baseMVAac = T_global.Sb_MVA(1);
    baseMVAdc = T_global.Sb_MVA(1);

    %% dc grid topology
    pol = 1;  % numbers of poles (1=monopolar grid, 2=bipolar grid)

    %% Bus data
    %   busdc_i busac_i grid    Pdc     Vdc     basekVdc    Vdcmax  Vdcmin  Cdc 
    busdc = zeros(nb,9); 
    busdc(:,1) = T_IPC.busdc; %busdc_i
    busdc(:,2) = T_IPC.bus; %busac_i
    busdc(:,3) = T_IPC.AreaDC; % DC area
    busdc(:,4) = zeros(nb,1); %Not sure why this is used! Pdc
    busdc(:,5) = ones(nb,1); %Not sure why this is used! Vdc
    busdc(:,6) = ones(nb,1).*T_IPC.Vdcn; %baseKVdc
    busdc(:,7) = 2*ones(nb,1); %Vdcmax
    busdc(:,8) = zeros(nb,1); %Vdcmin
    busdc(:,9) = zeros(nb,1); %Cdc (not used in the pf...)

    %% IPCs
    % %   busdc_i type_dc type_ac P_g   Q_g   Vtar    rtf     xtf     bf     rc     xc     basekVac    Vmmax   Vmmin   Imax    status   LossA LossB  LossCrec LossCinv  
    nipc = height(T_IPC);
    convdc = zeros(nipc,20);
    
    convdc(:,1) = T_IPC.busdc; %busdc_i
    convdc(:,2) = T_IPC.typedc; %typedc
    convdc(:,3) = T_IPC.type; %typeac
    convdc(:,4) = T_IPC.P*baseMVAac; %P_g
    convdc(:,5) = T_IPC.Q*baseMVAac; %Q_g;
    convdc(:,6) = T_IPC.V; %Vtar
    convdc(:,7) = zeros(nipc,1); %rtf not specified in the excel yet (transformer resistance).
    convdc(:,8) = zeros(nipc,1); %xtf not specified in the excel yet (transformer impedance).
    convdc(:,9) = zeros(nipc,1); %bf not specified in the excel yet (filter susceptance).
    convdc(:,10) = T_IPC.Rc + T_IPC.Ra/2; %rc for MATACDC
    convdc(:,11) = T_IPC.Xc + T_IPC.Xa/2; %Xc for MATACDC
    convdc(:,12) = T_IPC.Vn/1e3; %basekVAC;
    convdc(:,13) = 100*ones(nipc,1); %Vmmax;
    convdc(:,14) = 100*ones(nipc,1); %Vmmin;
    convdc(:,15) = 100*ones(nipc,1); %Imax;
    convdc(:,16) = ones(nipc,1); %status;
    convdc(:,17) = T_IPC.Rc + T_IPC.Ra/2; %LossA
    convdc(:,18) = zeros(nipc,1); %LossB
    %baseKA = baseMVAac/(sqrt(3)*0.280);
    convdc(:,19) = 2*T_IPC.Ra; %LossCrec
    convdc(:,20) = 2*T_IPC.Ra; %Locc Cinv



    %% Branches
    %   fbusdc  tbusdc  r      l    c   rateA   rateB   rateC   status
    %l and c not used in the pf...
    nbranch = height(T_DC_NET);
    branchdc = zeros(nbranch,9);
    
    branchdc(:,1) = T_DC_NET.bus_from;
    branchdc(:,2) = T_DC_NET.bus_to;
    branchdc(:,3) = 1./(1./T_DC_NET.Ra+1./T_DC_NET.Rb+1./T_DC_NET.Rc); %calculate equivalent resistance 3 in parallel
    branchdc(:,4) = zeros(nbranch,1); %not used in power flow
    branchdc(:,5) = zeros(nbranch,1); %not used in power flow
    branchdc(:,6) = 100*ones(nbranch,1); %?
    branchdc(:,7) = 100*ones(nbranch,1); %?
    branchdc(:,8) = 100*ones(nbranch,1); %?
    branchdc(:,9) = ones(nbranch,1); %?

    % ---------------------------------------------------------------------
    % Generate mpc_dc struct
    % ---------------------------------------------------------------------
    mpc_dc = struct('baseMVAac', baseMVAac, 'baseMVAdc', baseMVAdc, 'pol', pol ,'busdc', busdc, 'convdc', convdc, 'branchdc', branchdc);

end