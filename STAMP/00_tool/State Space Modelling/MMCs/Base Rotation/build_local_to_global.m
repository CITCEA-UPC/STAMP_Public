function local_to_global = build_local_to_global(etheta0_n, q_c, d_c, u , y )
    % Conversion vdiffc to vdiff
    Avdiffc_n1=[0];
    Bvdiffc_n1=[0 0 0];
    Cvdiffc_n1=[0
                0];
    Dvdiffc_n1=[cos(etheta0_n) sin(etheta0_n) -sin(etheta0_n)*q_c+cos(etheta0_n)*d_c;
                -sin(etheta0_n) cos(etheta0_n) -cos(etheta0_n)*q_c-sin(etheta0_n)*d_c];
    vdiffc_n1_x={''};
    
    %vdiffc_n1_u={'vdiff_qc_n1' 'vdiff_dc_n1' 'e_theta_n1'};
    %vdiffc_n1_y={'vdiff_q_n1' 'vdiff_d_n1'};
    
    local_to_global = ss(Avdiffc_n1,Bvdiffc_n1,Cvdiffc_n1,Dvdiffc_n1,'StateName',vdiffc_n1_x,'inputname',u,'outputname',y);
end