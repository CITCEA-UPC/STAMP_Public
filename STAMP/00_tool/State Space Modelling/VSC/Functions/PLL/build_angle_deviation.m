function angle_deviation = build_angle_deviation(x,u1,u2,y,num,num_slk,element_slk,area)
    if ~(num==num_slk(area) && element_slk{area} == "GFOR")
       % Angle deviation from system reference
       A = [0];
       B = [1 -1];
       C = [1];
       D = [0 0];

       angle_deviation = ss(A,B,C,D,'StateName',x,'inputname',u1,'outputname',y);
    else
       % Angle deviation from system reference (if slack)
       A = [0];
       B = [1];
       C = [0];
       D = [0];

       angle_deviation = ss(A,B,C,D,'StateName',x,'inputname',u2,'outputname',y);
    end
end