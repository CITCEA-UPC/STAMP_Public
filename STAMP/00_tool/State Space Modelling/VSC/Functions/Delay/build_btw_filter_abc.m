function btw_filter = build_btw_filter_abc(fc,x_q,x_d,u,y,q0,d0)
    if fc==-1
        
        A = [0];
        B = [0 0 0];
        C = [0;0];
        D = [1 0 0;0 1 0];
        x='';
        btw_filter = ss(A,B,C,D,'StateName',x,'inputname',u,'outputname',y);
    else
    
            wc = fc*2*pi;
            %q-component
            u_q = u{1};
            y_q = 'output_q';
            n = 2;

            [Ass,Bss,Css,Dss] = butter(n,wc,'low','s');
            btw_filter_q = ss(Ass,Bss,Css,Dss,'statename',x_q,'inputname',u_q,'outputname',y_q);

            %d-component
            u_d = u{2};
            y_d = 'output_d';
            n = 2;

            [Ass,Bss,Css,Dss] = butter(n,wc,'low','s');
            btw_filter_d = ss(Ass,Bss,Css,Dss,'statename',x_d,'inputname',u_d,'outputname',y_d);

            %rotation:
            [mag,phase,wout] = bode(btw_filter_q,2*pi*50);
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

            btw_filter = connect(btw_filter_q,btw_filter_d,rotation,{u_q;u_d;u{3}},out_rot);

    end
end