 function ini_line = generate_initialization_line(T_NET,results)

ini_line = cell(1,height(T_NET));

    for n_line = 1:1:height(T_NET)
        node1 = T_NET.bus_from(n_line);
        node2 = T_NET.bus_to(n_line);
        
        Ini_PI_line.Va1 = results.bus.Vm(results.bus.bus ==node1)*sin(results.bus.theta(results.bus.bus ==node1)*pi/180)*sqrt(2/3);
        Ini_PI_line.Vb1 = results.bus.Vm(results.bus.bus ==node1)*sin(results.bus.theta(results.bus.bus ==node1)*pi/180-2*pi/3)*sqrt(2/3);
        Ini_PI_line.Vc1 = results.bus.Vm(results.bus.bus ==node1)*sin(results.bus.theta(results.bus.bus ==node1)*pi/180+2*pi/3)*sqrt(2/3);
    
        Ini_PI_line.Va2 = results.bus.Vm(results.bus.bus ==node2)*sin(results.bus.theta(results.bus.bus ==node2)*pi/180)*sqrt(2/3);
        Ini_PI_line.Vb2 = results.bus.Vm(results.bus.bus ==node2)*sin(results.bus.theta(results.bus.bus ==node2)*pi/180-2*pi/3)*sqrt(2/3);
        Ini_PI_line.Vc2 = results.bus.Vm(results.bus.bus ==node2)*sin(results.bus.theta(results.bus.bus ==node2)*pi/180+2*pi/3)*sqrt(2/3);
        
        R = T_NET(T_NET.number==n_line,:).R;
        if isempty(R)
           R = 0;
        end
        X = T_NET(T_NET.number==n_line,:).X;
        if isempty(X)
           X = 0;
        end
            
        Va1 = results.bus.Vm(results.bus.bus ==node1)*(cos(results.bus.theta(results.bus.bus ==node1)*pi/180)+1j*sin(results.bus.theta(results.bus.bus ==node1)*pi/180))*sqrt(2/3);
        Vb1 = results.bus.Vm(results.bus.bus ==node1)*(cos(results.bus.theta(results.bus.bus ==node1)*pi/180-2*pi/3)+1j*sin(results.bus.theta(results.bus.bus ==node1)*pi/180-2*pi/3))*sqrt(2/3);
        Vc1 = results.bus.Vm(results.bus.bus ==node1)*(cos(results.bus.theta(results.bus.bus ==node1)*pi/180+2*pi/3)+1j*sin(results.bus.theta(results.bus.bus ==node1)*pi/180+2*pi/3))*sqrt(2/3);
    
        Va2 = results.bus.Vm(results.bus.bus ==node2)*(cos(results.bus.theta(results.bus.bus ==node2)*pi/180)+1j*sin(results.bus.theta(results.bus.bus ==node2)*pi/180))*sqrt(2/3);
        Vb2 = results.bus.Vm(results.bus.bus ==node2)*(cos(results.bus.theta(results.bus.bus ==node2)*pi/180-2*pi/3)+1j*sin(results.bus.theta(results.bus.bus ==node2)*pi/180-2*pi/3))*sqrt(2/3);
        Vc2 = results.bus.Vm(results.bus.bus ==node2)*(cos(results.bus.theta(results.bus.bus ==node2)*pi/180+2*pi/3)+1j*sin(results.bus.theta(results.bus.bus ==node2)*pi/180+2*pi/3))*sqrt(2/3);
    
        Z = R + 1j*X;
        Ia = (Va1-Va2)/Z;
        Ib = (Vb1-Vb2)/Z;
        Ic = (Vc1-Vc2)/Z;
        
        Ini_PI_line.Ia = abs(Ia)*sin(angle(Ia));
        Ini_PI_line.Ib = abs(Ib)*sin(angle(Ib));
        Ini_PI_line.Ic = abs(Ic)*sin(angle(Ic));

        ini_line{n_line} = Ini_PI_line;
    end
end