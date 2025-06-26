
V_bus = results.bus(:,8);
th_bus = results.bus(:,9)*pi/180;

[x_branch,y_branch]=size(results.branch);
results_branch = zeros(x_branch,6);
for ii = 1:x_branch
    results_branch(ii,1) = results.branch(ii,1);
    results_branch(ii,2) = results.branch(ii,2);
    Vi = V_bus(results.branch(ii,1))*cos(th_bus(results.branch(ii,1)))+i*V_bus(results.branch(ii,1))*sin(th_bus(results.branch(ii,1)));
    Vj = V_bus(results.branch(ii,2))*cos(th_bus(results.branch(ii,2)))+i*V_bus(results.branch(ii,2))*sin(th_bus(results.branch(ii,2)));
    Rij = results.branch(ii,3);
    Xij = results.branch(ii,4);
    Iij = (Vi-Vj)/(Rij+i*Xij);
    Si = Vi*conj(Iij);
    Sj = Vj*conj(Iij);
    results_branch(ii,3:4)= [real(Si),imag(Si)];
    results_branch(ii,5:6)= [real(-Sj),imag(-Sj)];   
end
