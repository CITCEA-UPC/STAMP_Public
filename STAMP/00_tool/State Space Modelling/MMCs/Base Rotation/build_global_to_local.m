function global_to_local = build_global_to_local(etheta0_n, q_g, d_g , u , y)
    % Conversion is to isc
    Aisc_n1=[0];
    Bisc_n1=[0 0 0];
    Cisc_n1=[0
            0];
    Disc_n1=[cos(etheta0_n) -sin(etheta0_n) -sin(etheta0_n)*q_g-cos(etheta0_n)*d_g;
            sin(etheta0_n) cos(etheta0_n) cos(etheta0_n)*q_g-sin(etheta0_n)*d_g];
        
    isc_n1_x = {''};
    
    global_to_local = ss(Aisc_n1,Bisc_n1,Cisc_n1,Disc_n1,'StateName',isc_n1_x,'inputname',u,'outputname',y);
end