function ini_load = generate_initialization_Load(T_load,results)
    
ini_load = cell(1,height(T_load));

    for load = 1:1:height(T_load)

        if T_load.Q(load) ~= 0
            
            Vrms = results.bus.Vm(results.bus.bus == T_load(T_load.number==load,:).bus);
            theta = results.bus.theta(results.bus.bus == T_load(T_load.number==load,:).bus);
            Q = T_load.Q(load);
    
            Vpeak=Vrms*sqrt(2)/sqrt(3); %peak phase to ground
            theta=theta*pi/180;
            Rotation = [cos(theta) sin(theta); -sin(theta) cos(theta)];
    
            iqc = 0;
            idc = -abs((2*Q)/(3*abs(Vpeak)));
    
            Ith = Rotation*[iqc;idc];
    
            Ith = Ith(1)-1j*Ith(2);
            Ithmag = abs(Ith);
            Ithangle = angle(Ith);
    
            Load_ref.Ia = Ithmag*sin(Ithangle);
            Load_ref.Ib = Ithmag*sin(Ithangle-2*pi/3);
            Load_ref.Ic = Ithmag*sin(Ithangle+2*pi/3);      

            Load_ref.Va = results.bus.Vm(results.bus.bus == T_load(T_load.number==load,:).bus)*sin(theta)*sqrt(2/3);
            Load_ref.Vb = results.bus.Vm(results.bus.bus == T_load(T_load.number==load,:).bus)*sin(theta-2*pi/3)*sqrt(2/3);
            Load_ref.Vc = results.bus.Vm(results.bus.bus == T_load(T_load.number==load,:).bus)*sin(theta+2*pi/3)*sqrt(2/3);

            %Load_ref.Ia = Ithmag*sin(Ithangle)*sqrt(2);
            %Load_ref.Ib = Ithmag*sin(Ithangle-2*pi/3)*sqrt(2);
            %Load_ref.Ic = Ithmag*sin(Ithangle+2*pi/3)*sqrt(2);
    
            ini_load{load} = Load_ref;

        else
            ini_load{load} = [];
        end
    end
end