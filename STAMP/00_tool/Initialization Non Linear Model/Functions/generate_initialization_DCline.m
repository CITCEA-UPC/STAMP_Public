function ini_DCline = generate_initialization_DCline(T_DC_NET,results)
    ini_DCline = cell(1,height(T_DC_NET));

    for n_line = 1:1:height(T_DC_NET)
        node1 = T_DC_NET(T_DC_NET.number==n_line,:).bus_from;
        node2 = T_DC_NET(T_DC_NET.number==n_line,:).bus_to;
    
        Va1 = results.busdc.Vm(node1);
        Vb1 = results.busdc.Vm(node1);
        Vc1 = results.busdc.Vm(node1);

        Va2 = results.busdc.Vm(node2);
        Vb2 = results.busdc.Vm(node2);
        Vc2 = results.busdc.Vm(node2);
    
        Ra = T_DC_NET(T_DC_NET.number==n_line,:).Ra;
        Rb = T_DC_NET(T_DC_NET.number==n_line,:).Rb;
        Rc = T_DC_NET(T_DC_NET.number==n_line,:).Rc;

        Za = Ra;
        Zb = Rb;
        Zc = Rc;
   
        Ia = (Va1-Va2)/Za;
        Ib = (Vb1-Vb2)/Zb;
        Ic = (Vc1-Vc2)/Zc;
    
        ini_line.Ia = Ia;
        ini_line.Ib = Ib;
        ini_line.Ic = Ic;

        ini_line.V1 = abs(Va1);
        ini_line.V2 = abs(Va2);

        ini_DCline{n_line} = ini_line;
    end

end