classdef Parser
    properties
        Y       = [];
        Vm      = [];
        theta   = [];
        S       = [];
        
        pq      = [];
        pv      = [];
        pqpv    = [];
        slack   = [];
        bus     = [];
       
        
        Vb      = 0;
        Sb      = 0;
        fref    = 0;
        
        nb      = 0;
        nl      = 0;

        bus_vsc   = [];
        bus_sg    = [];
        bus_stat   = [];
        bus_th    = [];
        bus_user    = [];
        bus_pq    = [];
        bus_rx    = [];

        n_vsc   = 0;
        n_sg    = 0;
        n_stat  = 0;
        n_th    = 0;
        n_user  = 0;
        n_pq    = 0;
        n_rx    = 0;
        n_b2b   = 0;
        
        r_rx    = [];
        x_rx    = [];
        
        P_pq    = [];
        Q_pq    = [];
        Sload   = [];
                
        S_nob2b = [];
        bus1_b2b = [];
        bus2_b2b = [];
        Vdc
        Rdc
        Z1
        Z2
        Vdc1
        Vdc2
        Idc
        
        glob
        branch
        load
        th
        sg
        stat
        vsc
        b2b
        user
    end
    
end
