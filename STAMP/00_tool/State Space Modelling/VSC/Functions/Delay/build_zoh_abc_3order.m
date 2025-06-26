function zoh = build_zoh_abc_3order(x_q,x_d,u,y,tau,q0,d0)
    if tau==-1
        A = [0];
        B = [0 0 0];
        C = [0;0];
        D = [1 0 0;0 1 0];
        x='';
    
        zoh = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
    else
        %q-component
        u_q = u{1};
        y_q = 'output_q';

        a = [tau^2 0 120];
        b = [tau^3 +12*tau^2 +60*tau 120];
        [Ass,Bss,Css,Dss] = tf2ss(a,b);
        zoh_q = ss(Ass,Bss,Css,Dss,'statename',x_q,'inputname',u_q,'outputname',y_q);

        %d-component
        u_d = u{2};
        y_d = 'output_d';

        a = [tau^2 0 120];
        b = [tau^3 +12*tau^2 +60*tau 120];
        [Ass,Bss,Css,Dss] = tf2ss(a,b);
        zoh_d = ss(Ass,Bss,Css,Dss,'statename',x_d,'inputname',u_d,'outputname',y_d);

        %rotation:
        [mag,phase,wout] = bode(zoh_q,2*pi*50);
        phase = -phase*pi/180;

        A = [0];
        B = [0 0 0];
        C = [0;0];
        D = mag*[cos(phase) -sin(phase) sin(phase)*0-cos(phase)*0;...
                 sin(phase) cos(phase)  cos(phase)*0-sin(phase)*0];
        % D = mag*[1 0 0;...
        %          0 1 0];
        in_rot = {y_q,y_d,u{3}};
        out_rot = y;

        rotation = ss(A,B,C,D,'statename','','inputname',in_rot,'outputname',out_rot);

        zoh = connect(zoh_q,zoh_d,rotation,{u_q;u_d;u{3}},out_rot);
        
    end
    
end